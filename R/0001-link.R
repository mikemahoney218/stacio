Link <- S7::new_class(
  name = "Link",
  properties = list(
    href = S7::new_property(
      class = S7::class_character
    ),
    rel = S7::new_property(
      class = S7::class_character
    ),
    type = S7::new_property(
      class = NULL | S7::class_character
    ),
    title = S7::new_property(
      class = NULL | S7::class_character
    ),
    method = S7::new_property(
      class = NULL | S7::class_character
    ),
    headers = S7::new_property(
      class = NULL | S7::class_environment
    ),
    body = S7::new_property(
      class = NULL | S7::class_environment
    ),
    merge = S7::new_property(
      class = NULL | S7::class_logical
    ),
    additional_fields = S7::new_property(
      class = S7::class_environment
    )
  ),
  constructor = function(
    href = character(0),
    rel = character(0),
    type = NULL,
    title = NULL,
    method = NULL,
    headers = NULL,
    body = NULL,
    merge = NULL,
    additional_fields = new.env(parent = emptyenv()),
    ...
  ) {
    additional_fields <- list2env(list(...), additional_fields)
    class(additional_fields) <- c("additional_fields", class(additional_fields))
    S7::new_object(
      S7::S7_object(),
      href = href,
      rel = rel,
      type = type,
      title = title,
      method = method,
      headers = headers,
      body = body,
      merge = merge,
      additional_fields = additional_fields
    )
  }
)

link_property <- S7::new_property(
  class = S7::new_S3_class("links_list"),
  getter = function(self) {
    links <- lapply(
      rust_get_links(self@externalptr),
      do.call,
      what = Link
    )
    class(links) <- "links_list"
    links
  },
  validator = function(value) {
    if (
      !all(vapply(
        value,
        \(x) S7::S7_inherits(x, Link),
        logical(1)
      ))
    ) {
      "All elements of links must be stacio::Link objects"
    }
  }
)

link_msg <- function(x, ...) {
  msg <- paste0(
    "<stacio::Link> (rel: ",
    x@rel,
    ")"
  )

  if (!is.null(x@title)) {
    msg <- paste0(
      msg,
      ": ",
      x@title
    )
  }

  if (!is.null(x@type)) {
    msg <- paste0(
      msg,
      " (type: ",
      x@type,
      ")"
    )
  }

  msg
}

S7::method(print, Link) <- function(x, ...) {
  msg <- link_msg(x)
  cat(msg)

  if (length(ls(x@additional_fields))) {
    cat("\nWith additional fields:", ls(x@additional_fields))
  }
  invisible(x)
}
