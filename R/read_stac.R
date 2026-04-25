#' Read STAC object
#' @export
read_stac <- function(file) {
  val <- rust_read_stac(file)
  switch(
    rust_get_type_name(val),
    "Catalog" = {
      Catalog(externalptr = val)
    },
    "Collection" = {
      Collection(externalptr = val)
    },
    "ItemCollection" = {
      ItemCollection(externalptr = val)
    },
    "Item" = {
      Item(externalptr = val)
    },
    stop("Unrecognized STAC object type")
  )
}
