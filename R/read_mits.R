#' Download and import tidy data from the Melbourne Institute Time Series
#' collection
#'
#' `read_mits()` establishes a headless browser session using `RSelenium`. Note
#' that this requires that Firefox is installed on your system.
#'
#' @param tables Vector of table(s) to download from the MITS site; currently
#' supported options are "unemp" (Unemployment expectations table) and
#' "wages" (Wages growth table)
#' @param download_dir Path to directory to which .xlsx file(s)
#' should be downloaded
#' @param username Your username for the Melbourne Institute Subscriber
#' Services website. See @details.
#' @param password Your password for the Melbourne Institute Subscriber
#' Services website. See @details.
#' @param port Port to use to connect to the Melbourne Institute website. If
#' left `NULL` (the default), an empty port will be identified
#' using `netstat::free_port()`.
#' @return A tidy tbl_df
#'
#' @details
#' By default, `read_mits()` will look for your username and password stored
#' as environmental variables. You can set these in an individual R session
#' `Sys.setenv("R_READMITS_USERNAME" = <your-username>)` and
#' `Sys.setenv("R_READMITS_PASSWORD" = <your-password>)`.
#'
#' You can set these
#' variables in a persistent way (across multiple R sessions) by editing your
#' `.Renviron` file. The `usethis::edit_r_environ()` function provides a
#' convient way of opening this file. Add the following lines to this file:
#'
#' `R_READMITS_USERNAME=<your-username>`
#' `R_READMITS_PASSWORD=<your-password>`
#'
#' You can also supply the username and password directly when
#' calling `read_mits()`.
#'
#' @examples
#' \dontrun{
#' read_mits()
#' }
#'
#' @export

read_mits <- function(tables = c("unemp", "wages"),
                      download_dir = tempdir(),
                      username = Sys.getenv("R_READMITS_USERNAME"),
                      password = Sys.getenv("R_READMITS_PASSWORD"),
                      port = NULL) {
  stopifnot(
    "read_mits() can currently only import 'unemp' and 'wages' series" =
      all(tables %in% c("unemp", "wages"))
  )


  if (is.null(port)) {
    port <- netstat::free_port()
  }

  ## Connect ----
  raw_driver <- create_driver(
    download_dir = download_dir,
    port = port
  )

  driver <- raw_driver[["client"]]

  driver$navigate("https://www.online.fbe.unimelb.edu.au/miss/Login.aspx")


  ## Log in ----
  username_box <- driver$findElement(
    using = "id",
    value = "ctl00_MainContent_txtUserName"
  )

  username_box$clearElement()

  username_box$sendKeysToElement(list(username))

  password_box <- driver$findElement(
    using = "id",
    value = "ctl00_MainContent_txtPassword"
  )
  password_box$clearElement()
  password_box$sendKeysToElement(list(password)) # , "\uE007"))

  login_button <- driver$findElement(
    using = "id",
    value = "ctl00_MainContent_imbLogin"
  )

  login_button$clickElement()

  # Download files ----

  ids <- dplyr::case_when(
    tables == "unemp" ~ "1683",
    tables == "wages" ~ "1684"
  )

  get_id <- function(id, driver) {
    existing_files <- list.files(download_dir,
      pattern = ".xlsx"
    )

    dl_id(driver, id)

    files <- list.files(download_dir,
      pattern = ".xlsx"
    )

    new_file <- files[!files %in% existing_files]
    new_file
  }

  files_downloaded <- purrr::map_chr(ids,
    get_id,
    driver = driver
  )

  # Tidy files ----

  tidy_df <- purrr::map_dfr(
    file.path(
      download_dir,
      files_downloaded
    ),
    tidy_mits
  )

  tidy_df
}
