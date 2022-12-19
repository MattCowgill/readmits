create_driver <- function(download_dir = getwd(),
                          port = netstat::free_port()) {
  fprof <- RSelenium::makeFirefoxProfile(list(browser.download.manager.showWhenStarting=FALSE,
                                              browser.download.dir = download_dir,
                                              browser.helperApps.neverAsk.saveToDisk="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                                              browser.download.folderList = 2L)
  )

  driver <- suppressMessages(RSelenium::rsDriver(browser = "firefox",
                                                 verbose = FALSE,
                                port = port,
                                extraCapabilities = list(firefox_profile = fprof$firefox_profile,
                                                         "moz:firefoxOptions" = list(args = list('--headless')))))

  driver
}


dl_id <- function(dr, id) {

  drop <- dr$findElement(using = "xpath",
                             value = paste0("//select[@id='ctl00_MainContent_ddlSubscriptionList']/option[@value='",
                                                   id,
                                                   "']"))

  drop$clickElement()

  dl_link <- dr$findElement(using = "id",
                                value = "ctl00_MainContent_uctReportsAndReleaseScheduleBySeriesYearIDCtl_grdAvailableReportList_ctl02_btnDownloadReport")

  dl_link$clickElement()
}

dl_wage <- function(driver) {
  dl_id(driver, '1684')
}

dl_unemp <- function(driver) {
  dl_id(driver, '1683')
}

