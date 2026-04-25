Collection <- S7::new_class(
  "Collection",
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
      getter = function(self) rust_get_id(self@externalptr)
    ),
    title = S7::new_property(
      class = NULL | S7::class_character,
      getter = function(self) {
        tryCatch(
          rust_get_title(self@externalptr),
          error = function(e) NULL
        )
      }
    ),
    description = S7::new_property(
      class = S7::class_character,
      getter = function(self) rust_get_description(self@externalptr)
    ),
    keywords = S7::new_property(
      class = S7::class_character,
      getter = function(self) rust_get_keywords(self@externalptr)
    ),
    license = S7::new_property(
      class = S7::class_character,
      getter = function(self) rust_get_license(self@externalptr)
    ),
    providers = S7::new_property(
      class = NULL | S7::class_list,
      getter = function(self) {
        tryCatch(
          {
            out <- rust_get_providers(self@externalptr)
            lapply(
              out,
              function(x) {
                Provider(
                  name = x$name,
                  description = x$description,
                  roles = unlist(x$roles),
                  url = x$url,
                  additional_fields = x$additional_fields
                )
              }
            )
          },
          error = function(e) NULL
        )
      },
      validator = function(value) {
        if (
          !all(vapply(
            value,
            \(x) S7::S7_inherits(x, Provider),
            logical(1)
          ))
        ) {
          "All elements of providers must be stacio::Provider objects"
        }
      }
    ),
    # TODO: get extent
    extent = S7::new_property(
      class = Extent,
      getter = function(self) rust_get_extent(self@externalptr)
    ),
    summaries = S7::new_property(
      class = NULL | S7::class_environment,
      getter = function(self) {
        tryCatch(
          list2env(rust_get_summaries(self@externalptr)),
          error = function(e) NULL
        )
      }
    ),
    links = link_property,
    additional_fields = S7::new_property(
      class = S7::class_environment,
      getter = function(self) {
        list2env(rust_get_additional_fields(self@externalptr))
      }
    ),
    assets = S7::new_property(
      class = S7::class_environment,
      getter = function(self) {
        rust_get_assets(self@externalptr) |>
          lapply(do.call, what = Asset) |>
          list2env()
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
    title,
    description,
    keywords,
    license,
    providers,
    extent,
    summaries,
    links,
    assets,
    item_assets,
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
        id = id,
        title = title,
        description = description,
        keywords = keywords,
        license = license,
        providers = providers,
        extent = extent,
        summaries = summaries,
        links = links,
        assets = assets,
        item_assets = item_assets,
        additional_fields = list2env(list(...), additional_fields)
      )
    }
  }
)
