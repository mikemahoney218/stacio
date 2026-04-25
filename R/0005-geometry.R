bbox_validator <- function(value) {
  if (!is.null(value) && !length(value) %in% c(4, 6)) {
    "@bbox must have either 4 (for 2-dimensional bounding boxes) or 6 (for 3-dimensional bounding boxes) values"
  }
}

Geometry <- S7::new_class(
  name = "Geometry",
  properties = list(
    bbox = S7::new_property(
      class = NULL | S7::class_numeric,
      validator = bbox_validator
    ),
    value = S7::new_property(
      class = NULL | S7::class_character
    ),
    foreign_members = S7::new_property(
      class = NULL | S7::class_environment
    )
  )
)
