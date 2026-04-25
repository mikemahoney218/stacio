Item <- S7::new_class(
  name = "Item",
  properties = list(
    version = S7::new_property(
      class = S7::class_character,
      getter = function(self) {
        rust_get_version(self@externalptr)
      }
    ),
    extensions = S7::new_property(
      class = S7::class_character,
      getter = function(self) rust_get_extensions(self@externalptr)
    ),
    id = S7::new_property(
      class = S7::class_character,
      getter = function(self) rust_get_id(self@externalptr),
    ),
    geometry = S7::new_property(
      # TODO: geometry getter
      class = NULL | Geometry,
      getter = function(self) {
        tryCatch(rust_get_geometry(self@externalptr), error = function(e) NULL)
      }
    ),
    bbox = S7::new_property(
      class = NULL | S7::class_numeric,
      getter = function(self) {
        tryCatch(
          as.numeric(rust_get_bbox(self@externalptr)),
          error = function(e) NULL
        )
      },
      validator = bbox_validator
    ),
    properties = S7::new_property(
      class = Properties,
      getter = function(self) {
        do.call(Properties, rust_get_properties(self@externalptr))
      }
    ),
    links = link_property,
    assets = S7::new_property(
      class = S7::class_environment,
      getter = function(self) {
        rust_get_assets(self@externalptr) |>
          lapply(do.call, what = Asset) |>
          list2env()
      }
    ),
    collection = S7::new_property(
      class = NULL | S7::class_character,
      getter = function(self) {
        tryCatch(rust_get_collection(self@externalptr), error = function(e) {
          NULL
        })
      },
      setter = function(self, value) {
        if (length(value) > 0) {
          set_item_collection(self@externalptr)
        }
        self
      }
    ),
    additional_fields = S7::new_property(
      class = S7::class_environment,
      getter = function(self) {
        af <- list2env(rust_get_additional_fields(self@externalptr))
        class(af) <- "additional_fields"
        af
      }
    ),
    externalptr = S7::new_property(
      class = NULL | S7::new_S3_class("externalptr")
    )
  ),
  constructor = function(
    version,
    extensions,
    id,
    geometry,
    bbox,
    properties,
    links,
    assets,
    collection,
    additional_fields,
    externalptr
  ) {
    if (!missing(externalptr)) {
      S7::new_object(
        S7::S7_object(),
        externalptr = rust_clone_pointer(externalptr)
      )
    } else {
      S7::new_object(
        S7::S7_object(),
        version = version,
        extensions = extensions,
        id,
        geometry,
        bbox,
        properties,
        links,
        assets,
        collection,
        additional_fields = list2env(list(...), additional_fields)
      )
    }
  }
)

S7::method(print, Item) <- function(x, ...) {
  cli::cli_text(
    "STAC Item (version {x@version})"
  )
  if (!is.null(x@collection)) {
    cli::cli_text(
      "Collection: {x@collection}"
    )
  }
  if (!is.null(x@bbox)) {
    cli::cli_text(
      "Bounding box: {cli::cli_vec(x@bbox, style = list('vec-last' = ', '))}"
    )
  }
  if (length(x@extensions)) {
    cli::cli_text("Using extensions:")
    cli::cli_ul()
    cli::cli_li(x@extensions)
    cli::cli_end()
  }
  print(x@properties)
  if (length(x@links)) {
    cli::cli_text("With links:")
    cli::cli_ul()
    lapply(
      x@links,
      \(l) {
        ifelse(
          is.null(l@title),
          cli::cli_li("??? (rel: {l@rel})"),
          cli::cli_li("{l@title} (rel: {l@rel})")
        )
      }
    )
    cli::cli_end()
  }
  if (length(ls(x@assets))) {
    cli::cli_text("With assets:")
    cli::cli_ul()
    cli::cli_li(ls(x@assets))
    cli::cli_end()
  }
  if (length(ls(x@additional_fields))) {
    cli::cli_text("With additional fields:")
    cli::cli_ul()
    cli::cli_li(ls(x@additional_fields))
    cli::cli_end()
  }
  invisible(x)
}
