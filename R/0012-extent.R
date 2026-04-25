Extent <- S7::new_class(
  "Extent",
  properties = list(
    spatial = S7::new_property(
      class = S7::class_list,
      validator = function(value) {
        out <- unlist(lapply(value, bbox_validator))
        if (!is.null(out)) {
          "@spatial must be a list of bounding boxes with either 4 (for 2-dimensional bounding boxes) or 6 (for 3-dimensional bounding boxes) values"
        }
      }
    ),
    temporal = S7::new_property(
      class = S7::class_list,
      validator = function(value) {
        if (any(vapply(value, function(x) length(x) != 2, logical(1L)))) {
          "@temporal must be a list of temporal extents each containing two POSIXct values"
        }
      }
    ),
    additional_fields = S7::new_property(
      class = S7::class_environment
    )
  )
)
