Band <- S7::new_class(
  name = "Band",
  properties = list(
    name = S7::new_property(
      class = NULL | S7::class_character
    ),
    description = S7::new_property(
      class = NULL | S7::class_character
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
    name = NULL,
    description = NULL,
    nodata = NULL,
    data_type = NULL,
    statistics = NULL,
    unit = NULL,
    additional_fields = new.env(parent = emptyenv()),
    ...
  ) {
    S7::new_object(
      S7::S7_object(),
      name = name,
      description = description,
      nodata = nodata,
      data_type = data_type,
      statistics = statistics,
      unit = unit,
      additional_fields = list2env(list(...), additional_fields)
    )
  }
)
