parse_interval <- function(interval) {
  out <- vapply(
    interval,
    function(x) {
      if (is.null(x)) {
        x <- NA_character_
      }
      if (inherits(x, "POSIXt")) {
        x <- format(x, format = "%FT%T")
        x
      }
      x
    },
    character(1)
  )
  out <- as.POSIXct(
    out,
    tz = "UTC",
    format = "%FT%T"
  )
  setNames(out, NULL)
}

none_to_null <- function(x) {
  if (length(x) == 0) {
    return(NULL)
  }
  x
}
