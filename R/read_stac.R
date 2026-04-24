#' Read STAC object
#' @export
read_stac <- function(file) {
  val <- rust_read_stac(file)
  switch(
    get_stac_type(val),
    "Catalog" = {
      val
    },
    "Collection" = {
      val
    },
    "ItemCollection" = {
      val
    },
    "Item" = {
      Item(externalptr = val)
    },
    rlang::abort("Unrecognized STAC object type")
  )
}
