Provider <- S7::new_class(
  "Provider",
  properties = list(
    name = S7::new_property(
      class = S7::class_character
    ),
    description = S7::new_property(
      class = NULL | S7::class_character
    ),
    roles = S7::new_property(
      class = NULL | S7::class_character
    ),
    url = S7::new_property(
      class = NULL | S7::class_character
    ),
    additional_fields = S7::new_property(
      class = S7::class_environment
    )
  )
)
