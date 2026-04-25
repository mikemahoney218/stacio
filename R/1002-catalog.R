Catalog <- S7::new_class(
  "Catalog",
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
    links = link_property,
    additional_fields = S7::new_property(
      class = S7::class_environment,
      getter = function(self) {
        list2env(rust_get_additional_fields(self@externalptr))
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
    links,
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
        links = links,
        additional_fields = list2env(list(...), additional_fields)
      )
    }
  }
)
