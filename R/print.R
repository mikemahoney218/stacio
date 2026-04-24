S7::method(print, Link) <- function(x, ...) {
  cat(
    "<stacio::Link> (rel: ",
    x@rel,
    "): ",
    x@title,
    " (type: ",
    x@type,
    ")",
    sep = ""
  )
  if (length(ls(x@additional_fields))) {
    cat("With additional fields:", ls(x@additional_fields))
  }
  invisible(x)
}
