validate_datatype <- function(value) {
  if (is.null(value)) {
    return(NULL)
  }

  allowed_dtypes <- c(
    "Int8",
    "Int16",
    "Int32",
    "Int64",
    "UInt8",
    "UInt16",
    "UInt32",
    "UInt64",
    "Float16",
    "Float32",
    "Float64",
    "CInt16",
    "CInt32",
    "CFloat32",
    "CFloat64",
    "Other"
  )

  if (!(tolower(value) %in% tolower(allowed_dtypes))) {
    return(paste("@data_type must be one of", allowed_dtypes))
  }

  NULL
}

data_type_property <- S7::new_property(
  class = NULL | S7::class_character,
  validator = validate_datatype
)
