read_mits <- function(download_dir = tempdir(),
                      ids = c('1683', '1684'),
                      # ids = '1683',
                      username = Sys.getenv("R_READMITS_USERNAME"),
                      password = Sys.getenv("R_READMITS_PASSWORD"),
                      port = netstat::free_port()) {

  raw_driver <- create_driver(download_dir = download_dir,
                          port = port)

  driver <- raw_driver[["client"]]

  driver$navigate("https://www.online.fbe.unimelb.edu.au/miss/Login.aspx")


  ## Log in ----
  username_box <- driver$findElement(using = "id",
                                     value = "ctl00_MainContent_txtUserName")

  username_box$clearElement()

  username_box$sendKeysToElement(list(username))

  password_box <- driver$findElement(using = "id",
                                     value = "ctl00_MainContent_txtPassword")
  password_box$clearElement()
  password_box$sendKeysToElement(list(password)) #, "\uE007"))

  login_button <- driver$findElement(using = "id",
                                     value = "ctl00_MainContent_imbLogin")

  login_button$clickElement()

  # Download files ----
  get_id <- function(id, driver) {
    existing_files <- list.files(download_dir,
                                 pattern = ".xlsx")

    dl_id(driver, id)

    files <- list.files(download_dir,
                        pattern = ".xlsx")

    new_file <- files[!files %in% existing_files]
    new_file
    }

  files_downloaded <- purrr::map_chr(ids,
                                     get_id,
                                     driver = driver)

  # Tidy files ----

  tidy_df <- purrr::map_dfr(file.path(download_dir,
                                      files_downloaded),
                            tidy_mits)

  tidy_df
}

