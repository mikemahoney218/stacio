ItemCollection <- S7::new_class(
  "ItemCollection",
  properties = list(
    items = S7::new_property(
      class = S7::class_list,
      validator = function(value) {
        if (!all(vapply(value, S7::S7_inherits, character(1), Item))) {
          "@items must be a list of stacio::Item objects"
        }
      }
    ),
    links = link_property,
    additional_fields = S7::new_property(
      class = S7::class_environment,
      getter = function(self) rust_get_additional_fields(self@externalptr)
    ),
    externalptr = S7::new_property(
      class = NULL | S7::new_S3_class("externalptr")
    )
  ),
  constructor = function(
    items,
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
        items = items,
        links = links,
        additional_fields = list2env(list(...), additional_fields)
      )
    }
  }
)
