Statistics <- S7::new_class(
  name = "Statistics",
  properties = list(
    mean = S7::new_property(
      class = NULL | S7::class_numeric
    ),
    minimum = S7::new_property(
      class = NULL | S7::class_numeric
    ),
    maximum = S7::new_property(
      class = NULL | S7::class_numeric
    ),
    stddev = S7::new_property(
      class = NULL | S7::class_numeric
    ),
    valid_percent = S7::new_property(
      class = NULL | S7::class_numeric
    )
  )
)

statistics_property <- S7::new_property(
  class = NULL | Statistics
)
