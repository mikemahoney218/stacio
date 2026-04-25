Properties <- S7::new_class(
  name = "Properties",
  properties = list(
    datetime = S7::new_property(
      # TODO: confirm this is the right posix class
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
      class = NULL | S7::class_character
    ),
    updated = S7::new_property(
      class = NULL | S7::class_character
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
      datetime = datetime,
      start_datetime = start_datetime,
      end_datetime = end_datetime,
      title = title,
      description = description,
      created = created,
      updated = updated,
      additional_fields = list2env(list(...), additional_fields)
    )
  }
)
