testthat::test_that("print methods return the object unchanged", {
  stac_objs <- lapply(
    list.files(
      system.file("spec-examples", package = "stacio"),
      recursive = TRUE,
      full.names = TRUE
    ),
    read_stac
  )

  for (obj in stac_objs) {
    testthat::expect_identical(
      print(obj),
      obj
    )
  }
})
