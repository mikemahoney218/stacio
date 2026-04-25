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
  class = S7::class_list,
  getter = function(self) {
    lapply(
      rust_get_links(self@externalptr),
      do.call,
      what = Link
    )
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

S7::method(print, Link) <- function(x, ...) {
  cli::cli_text(
    "{ifelse(is.null(x@title), '???', x@title)} (rel: {x@rel})"
  )

  if (length(ls(x@additional_fields))) {
    cli::cli_text("With additional fields: {ls(x@additional_fields)}")
  }

  cli::cli_text("{.url {x@href}}")

  invisible(x)
}
