tidy_mits <- function(path) {
  base_file <- basename(path)

  tidier_fn <- switch(substr(tolower(base_file), 1, 5),
    "unemp" = tidy_mits_unemp,
    "wages" = tidy_mits_wages,
    stop(
      "Currently unable to tidy files like ",
      path
    )
  )

  tidier_fn(path)
}

tidy_mits_unemp <- function(path) {
  raw_unemp <- readxl::read_excel(path,
    .name_repair = "unique_quiet",
    sheet = "Unemployment"
  )

  names(raw_unemp)[1] <- "date"

  raw_unemp %>%
    dplyr::mutate(date = as.Date(date)) %>%
    tidyr::pivot_longer(
      cols = !tidyr::one_of("date"),
      names_to = "series",
      values_to = "value"
    ) %>%
    dplyr::mutate(
      series = gsub(" ", " ", .data$series),
      value = as.numeric(.data$value),
      table = "Unemployment expectations"
    ) %>%
    dplyr::filter(!is.na(.data$value))
}

#' @importFrom rlang .data
tidy_mits_wages <- function(path) {
  raw_wages <- readxl::read_excel(path,
    .name_repair = "unique_quiet",
    sheet = "WAGE",
    skip = 1
  )

  names(raw_wages)[1] <- "date"

  names(raw_wages)[2:8] <- paste0(
    c(
      rep("Expected Wage Growth: ", 3),
      rep("Actual Wage Growth: ", 4)
    ),
    names(raw_wages)[2:8]
  )

  names(raw_wages) <- gsub("\\..*", "", names(raw_wages))

  raw_wages %>%
    dplyr::mutate(date = as.Date(.data$date)) %>%
    tidyr::pivot_longer(
      cols = !dplyr::one_of("date"),
      names_to = "series"
    ) %>%
    dplyr::mutate(
      table = "Wages growth",
      value = as.numeric(.data$value)
    ) %>%
    dplyr::filter(!is.na(.data$value))
}
