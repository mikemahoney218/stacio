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
statistics_property <- S7::new_property(
  class = NULL | Statistics
)

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
      additional_fields = list2env(rlang::list2(...), additional_fields)
    )
  }
)

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
      additional_fields = list2env(rlang::list2(...), additional_fields)
    )
  }
)

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
      # TODO: implement GeometryValue -> SFC conversion
      # This can't actually be NULL
      class = NULL | S7::new_S3_class("sfc")
    ),
    foreign_members = S7::new_property(
      class = NULL | S7::class_environment
    )
  )
)

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
      additional_fields = list2env(rlang::list2(...), additional_fields)
    )
  }
)

Link <- S7::new_class(
  name = "Link",
  properties = list(
    href = S7::new_property(
      class = S7::class_character
    ),
    rel = S7::new_property(
      class = S7::class_character
    ),
    type = S7::new_property(
      class = NULL | S7::class_character
    ),
    title = S7::new_property(
      class = NULL | S7::class_character
    ),
    method = S7::new_property(
      class = NULL | S7::class_character
    ),
    headers = S7::new_property(
      class = NULL | S7::class_environment
    ),
    body = S7::new_property(
      class = NULL | S7::class_environment
    ),
    merge = S7::new_property(
      class = NULL | S7::class_logical
    ),
    additional_fields = S7::new_property(
      S7::class_environment
    )
  ),
  constructor = function(
    href = character(0),
    rel = character(0),
    type = NULL,
    title = NULL,
    method = NULL,
    headers = NULL,
    body = NULL,
    merge = NULL,
    additional_fields = new.env(parent = emptyenv()),
    ...
  ) {
    S7::new_object(
      S7::S7_object(),
      href = href,
      rel = rel,
      type = type,
      title = title,
      method = method,
      headers = headers,
      body = body,
      merge = merge,
      additional_fields = list2env(rlang::list2(...), additional_fields)
    )
  }
)

Item <- S7::new_class(
  name = "Item",
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
      getter = function(self) rust_get_id(self@externalptr),
    ),
    geometry = S7::new_property(
      # TODO: geometry getter
      class = NULL | Geometry
    ),
    bbox = S7::new_property(
      class = NULL | S7::class_numeric,
      getter = function(self) rust_get_bbox(self@externalptr),
      validator = bbox_validator
    ),
    properties = S7::new_property(
      class = Properties,
      getter = function(self) rust_get_properties(self@externalptr)
    ),
    links = S7::new_property(
      class = S7::class_list,
      getter = function(self) {
        lapply(
          rust_get_links(self@externalptr),
          do.call,
          what = Link
        )
      },
      validator = function(value) {
        if (
          !all(vapply(
            value,
            \(x) S7::S7_inherits(x, Link),
            logical(1)
          ))
        ) {
          "All elements of bands must be stacio::Link objects"
        }
      }
    ),
    assets = S7::new_property(
      class = S7::class_environment,
      getter = function(self) {
        rust_get_assets(self@externalptr) |>
          lapply(do.call, what = Asset) |>
          list2env()
      }
    ),
    collection = S7::new_property(
      class = NULL | S7::class_character,
      getter = function(self) rust_get_collection(self@externalptr),
      setter = function(self, value) {
        if (length(value) > 0) {
          set_item_collection(self@externalptr)
        }
        self
      }
    ),
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
    geometry,
    bbox,
    properties,
    links,
    assets,
    collection,
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
        id,
        geometry,
        bbox,
        properties,
        links,
        assets,
        collection,
        additional_fields = list2env(rlang::list2(...), additional_fields)
      )
    }
  }
)

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
      getter = function(self) rust_get_id(self@externalptr),
      setter = function(self, value) {
        if (length(value) > 0) {
          set_item_id(self@externalptr, value)
        }
        self
      }
    ),
    title = S7::new_property(
      class = NULL | S7::class_character
    ),
    description = S7::new_property(
      class = NULL | S7::class_character
    ),
    links = S7::new_property(
      class = S7::class_list,
      getter = function(self) {
        lapply(
          rust_get_links(self@externalptr),
          do.call,
          what = Link
        )
      },
      validator = function(value) {
        if (
          !all(vapply(
            value,
            \(x) S7::S7_inherits(x, Link),
            logical(1)
          ))
        ) {
          "All elements of bands must be stacio::Link objects"
        }
      }
    ),
    additional_fields = S7::new_property(
      class = S7::class_environment,
      getter = function(self) {
        list2env(rust_get_additional_fields(self@externalptr))
      }
    ),
    externalptr = S7::new_property(
      class = NULL | S7::new_S3_class("externalptr")
    )
  )
)
