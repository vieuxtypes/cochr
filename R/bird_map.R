#' Create a leaflet map from eBird observations
#'
#' @param ebird_file Path to a MyEBirdData CSV file.
#'
#' @return A leaflet map.
#' @export
#'
#' @importFrom rlang .data
#'
#' @examples
#' \dontrun{
#' bird_map("data/MyEBirdData.csv")
#' }
bird_map <- function(ebird_file) {

  utils::data("bird_dictionary", package = "cochr", envir = environment())
  dico <- get("bird_dictionary", envir = environment())

  ebird <- readr::read_delim(
    ebird_file,
    show_col_types = FALSE,
    lazy = FALSE
  ) |>
    dplyr::mutate(
      Longitude = round(.data$Longitude, 5),
      Latitude  = round(.data$Latitude, 5),
      Date = as.Date(.data$Date)
    )

  prime <- ebird |>
    dplyr::left_join(
      dico,
      by = c("Scientific Name" = "X2")
    ) |>
    dplyr::group_by(.data$`Scientific Name`) |>
    dplyr::filter(.data$Date == min(.data$Date, na.rm = TRUE)) |>
    dplyr::ungroup() |>
    dplyr::distinct(.data$X3, .keep_all = TRUE) |>
    dplyr::rename(
      Nom = .data$X3,
      Name = .data$X1,
      Statut = .data$X4
    ) |>
    dplyr::group_by(
      .data$Latitude,
      .data$Longitude,
      .data$Date,
      .data$Location
    ) |>
    dplyr::summarise(
      Nom = paste(unique(.data$Nom), collapse = "<br>"),
      oiseaux = paste(unique(.data$Nom), collapse = "<br> "),
      .groups = "drop"
    ) |>
    dplyr::mutate(
      bloc = paste0(
        "<b>", .data$Date, "</b><br>",
        "<i>", .data$Location, "</i><br>",
        .data$oiseaux
      )
    ) |>
    dplyr::group_by(
      .data$Latitude,
      .data$Longitude
    ) |>
    dplyr::summarise(
      Nom = paste(unique(.data$Nom), collapse = "<br>"),
      popup_txt = paste(.data$bloc, collapse = "<br><br>"),
      .groups = "drop"
    ) |>
    sf::st_as_sf(
      coords = c("Longitude", "Latitude"),
      crs = 4326,
      remove = FALSE
    )

  leaflet::leaflet(prime) |>
    leaflet::addProviderTiles(
      leaflet::providers$OpenStreetMap
    ) |>
    leaflet::addCircleMarkers(
      lng = ~Longitude,
      lat = ~Latitude,
      radius = 3,
      stroke = FALSE,
      fillOpacity = 0.8,
      color = "black",
      fillColor = "black",
      popup = ~lapply(popup_txt, htmltools::HTML),
      group = "points_click"
    ) |>
    leaflet::addCircleMarkers(
      radius = 6,
      stroke = FALSE,
      fillOpacity = 0,
      popup = ~lapply(popup_txt, htmltools::HTML),
      group = "points_click"
    ) |>
    leaflet::addLabelOnlyMarkers(
      label = ~lapply(Nom, htmltools::HTML),
      labelOptions = leaflet::labelOptions(
        noHide = TRUE,
        direction = "bottom",
        textOnly = TRUE,
        offset = c(0, -4),
        style = list(
          "font-size" = "14px")
      ),
      group = "labels"
    ) |>
    leaflet::groupOptions(
      group = "labels",
      zoomLevels = 10:20
    )
}



