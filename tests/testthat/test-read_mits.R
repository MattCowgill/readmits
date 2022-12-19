test_that("read_mits() works", {
  df <- read_mits()
  expect_s3_class(df, "tbl_df")
  expect_length(df, 4)
  expect_gt(nrow(df), 13000)
})
