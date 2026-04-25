Asset <- S7::new_class(
  name = "Asset",
  properties = list(
    href = S7::new_property(
      class = S7::class_character
    ),
    title = S7::new_property(
      class = NULL | S7::class_character
    ),
    description = S7::new_property(
      class = NULL | S7::class_character
    ),
    type = S7::new_property(
      class = NULL | S7::class_character
    ),
    roles = S7::new_property(
      class = S7::class_character,
      setter = function(self, value) {
        self@roles <- as.character(value)
        self
      }
    ),
    created = S7::new_property(
      class = NULL | S7::class_character
    ),
    updated = S7::new_property(
      class = NULL | S7::class_character
    ),
    bands = S7::new_property(
      class = NULL | S7::class_list,
      setter = function(self, value) {
        self@bands <- lapply(value, do.call, what = Band)
        self
      },
      validator = function(value) {
        if (
          !all(vapply(
            value,
            \(x) S7::S7_inherits(x, Band),
            logical(1)
          ))
        ) {
          "All elements of bands must be stacio::Band objects"
        }
      }
    ),
    nodata = S7::new_property(
      class = NULL | S7::class_numeric
    ),
    data_type = data_type_property,
    statistics = statistics_property,
    unit = S7::new_property(
      class = NULL | S7::class_character
    ),
    additional_fields = S7::new_property(
      class = S7::class_environment
    )
  ),
  constructor = function(
    href = character(0),
    title = NULL,
    description = NULL,
    type = NULL,
    roles = character(0),
    created = NULL,
    updated = NULL,
    bands = NULL,
    nodata = NULL,
    data_type = NULL,
    statistics = NULL,
    unit = NULL,
    additional_fields = new.env(parent = emptyenv()),
    ...
  ) {
    S7::new_object(
      S7::S7_object(),
      href = href,
      title = title,
      description = description,
      type = type,
      roles = roles,
      created = created,
      updated = updated,
      bands = bands,
      nodata = nodata,
      data_type = data_type,
      statistics = statistics,
      unit = unit,
      additional_fields = list2env(list(...), additional_fields)
    )
  }
)
