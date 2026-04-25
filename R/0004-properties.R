Properties <- S7::new_class(
  name = "Properties",
  properties = list(
    datetime = S7::new_property(
      class = NULL | S7::new_S3_class("POSIXct")
    ),
    start_datetime = S7::new_property(
      class = NULL | S7::new_S3_class("POSIXct")
    ),
    end_datetime = S7::new_property(
      class = NULL | S7::new_S3_class("POSIXct")
    ),
    title = S7::new_property(
      class = NULL | S7::class_character
    ),
    description = S7::new_property(
      class = NULL | S7::class_character
    ),
    created = S7::new_property(
      class = NULL | S7::new_S3_class("POSIXct")
    ),
    updated = S7::new_property(
      class = NULL | S7::new_S3_class("POSIXct")
    ),
    additional_fields = S7::new_property(
      class = S7::class_environment
    )
  ),
  constructor = function(
    datetime = NULL,
    start_datetime = NULL,
    end_datetime = NULL,
    title = NULL,
    description = NULL,
    created = NULL,
    updated = NULL,
    additional_fields = new.env(parent = emptyenv()),
    ...
  ) {
    S7::new_object(
      S7::S7_object(),
      datetime = none_to_null(parse_interval(datetime)),
      start_datetime = none_to_null(parse_interval(start_datetime)),
      end_datetime = none_to_null(parse_interval(end_datetime)),
      title = title,
      description = description,
      created = none_to_null(parse_interval(created)),
      updated = none_to_null(parse_interval(updated)),
      additional_fields = list2env(list(...), additional_fields)
    )
  }
)

S7::method(print, Properties) <- function(x, ...) {
  cli::cli_text("Properties:")
  cli::cli_ul()

  for (prp in setdiff(S7::prop_names(x), "additional_fields")) {
    if (!is.null(S7::prop(x, prp))) {
      cli::cli_li("{prp}: {S7::prop(x, prp)}")
    }
  }

  if (length(ls(x@additional_fields))) {
    cli::cli_text("And additional fields:")
    cli::cli_li(ls(x@additional_fields))
  }

  cli::cli_end()
  invisible(x)
}
