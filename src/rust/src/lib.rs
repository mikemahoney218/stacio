use extendr_api::prelude::*;
use extendr_api::serializer::to_robj;
use stac::{Value, Catalog, Collection, ItemCollection, Item};
use stac_io;
use std::string::String;

#[extendr]
fn rust_read_stac(file: String) -> ExternalPtr<StacObject> {
    let out: Value = stac_io::read(file).unwrap();
    return ExternalPtr::new(out.into());
}

/// Get the STAC type of a Value
///
/// @param value The Value to get the type of
///
/// @return An external pointer
#[extendr]
fn get_stac_type(value: ExternalPtr<Value>) -> &'static str {
    value.type_name()
}

#[extendr]
#[derive(Clone, Debug)]
enum StacObject {
    Item(Item),
    Catalog(Catalog),
    Collection(Collection),
    ItemCollection(ItemCollection)
}

impl From<stac::Item> for StacObject {
    fn from(item: stac::Item) -> Self {
        StacObject::Item(item)
    }
}

impl From<stac::Catalog> for StacObject {
    fn from(catalog: stac::Catalog) -> Self {
        StacObject::Catalog(catalog)
    }
}

impl From<stac::Collection> for StacObject {
    fn from(collection: stac::Collection) -> Self {
        StacObject::Collection(collection)
    }
}

impl From<stac::ItemCollection> for StacObject {
    fn from(item_collection: stac::ItemCollection) -> Self {
        StacObject::ItemCollection(item_collection)
    }
}

impl From<stac::Value> for StacObject {
    fn from(value: stac::Value) -> Self {
        match value {
            Value::Catalog(catalog) => catalog.into(),
            Value::Collection(collection) => collection.into(),
            Value::Item(item) => item.into(),
            Value::ItemCollection(item_collection) => item_collection.into(),
        }
    }
}

#[extendr]
impl StacObject {
    fn rust_clone_pointer(&self) -> ExternalPtr<StacObject> {
        ExternalPtr::new(self.clone())
    }

    fn rust_get_links(&self) -> Robj {
        match self {
            StacObject::Item(item) => to_robj(&item.links).unwrap(),
            StacObject::Catalog(catalog) => to_robj(&catalog.links).unwrap(),
            StacObject::Collection(collection) => to_robj(&collection.links).unwrap(),
            StacObject::ItemCollection(itemcollection) => to_robj(&itemcollection.links).unwrap()
        }
    }

    fn rust_get_version(&self) -> Result<String, String> {
        match self {
            StacObject::Item(item) => Ok(item.version.to_string()),
            StacObject::Catalog(catalog) => Ok(catalog.version.to_string()),
            StacObject::Collection(collection) => Ok(collection.version.to_string()),
            StacObject::ItemCollection(_itemcollection) => Err("ItemCollection objects are not part of the STAC specification and do not have a version.".to_string())
        }
    }

    fn rust_get_extensions(&self) -> Result<Vec<String>, String> {
        match self {
            StacObject::Item(item) => Ok(item.extensions.clone()),
            StacObject::Catalog(catalog) => Ok(catalog.extensions.clone()),
            StacObject::Collection(collection) => Ok(collection.extensions.clone()),
            StacObject::ItemCollection(_itemcollection) => Err("ItemCollection objects are not part of the STAC specification and do not have extensions.".to_string())
        }
    }

    fn rust_get_id(&self) -> Result<String, String> {
        match self {
            StacObject::Item(item) => Ok(item.id.clone()),
            StacObject::Catalog(catalog) => Ok(catalog.id.clone()),
            StacObject::Collection(collection) => Ok(collection.id.clone()),
            StacObject::ItemCollection(_itemcollection) => Err("ItemCollection objects are not part of the STAC specification and do not have IDs.".to_string())
        }
    }

    fn rust_get_properties(&self) -> Result<Robj, String> {
        match self {
            StacObject::Item(item) => Ok(to_robj(&item.properties).unwrap()),
            StacObject::Catalog(_catalog) => Err("Catalog objects do not have properties.".to_string()),
            StacObject::Collection(_collection) => Err("Collection objects do not have properties.".to_string()),
            StacObject::ItemCollection(_itemcollection) => Err("ItemCollection objects do not have properties.".to_string())
        }
    }

    fn rust_get_assets(&self) -> Result<Robj, String> {
        match self {
            StacObject::Item(item) => Ok(to_robj(&item.assets).unwrap()),
            StacObject::Catalog(_catalog) => Err("Catalog objects do not have properties.".to_string()),
            StacObject::Collection(collection) => Ok(to_robj(&collection.item_assets).unwrap()),
            StacObject::ItemCollection(_itemcollection) => Err("ItemCollection objects do not have properties.".to_string())
        }
    }

    fn rust_get_additional_fields(&self) -> Result<Robj, String> {
        match self {
            StacObject::Item(item) => Ok(to_robj(&item.additional_fields).unwrap()),
            StacObject::Catalog(catalog) => Ok(to_robj(&catalog.additional_fields).unwrap()),
            StacObject::Collection(collection) => Ok(to_robj(&collection.additional_fields).unwrap()),
            StacObject::ItemCollection(itemcollection) => Ok(to_robj(&itemcollection.additional_fields).unwrap())
        }
    }

    fn rust_get_bbox(&self) -> Result<Robj, String> {
        match self {
            StacObject::Item(item) => Ok(to_robj(&item.bbox).unwrap()),
            StacObject::Catalog(_catalog) => Err("Catalog objects do not have properties.".to_string()),
            StacObject::Collection(collection) => Ok(to_robj(&collection.extent.spatial.bbox).unwrap()),
            StacObject::ItemCollection(_itemcollection) => Err("ItemCollection objects do not have a bbox.".to_string())
        }
    }

    fn rust_get_collection(&self) -> Result<Robj, String> {
        match self {
            StacObject::Item(item) => Ok(to_robj(&item.collection).unwrap()),
            StacObject::Catalog(_catalog) => Err("Catalog objects do not have properties.".to_string()),
            StacObject::Collection(_collection) => Err("Collection objects do not have properties.".to_string()),
            StacObject::ItemCollection(_itemcollection) => Err("ItemCollection objects do not have a bbox.".to_string())
        }
    }
}

macro_rules! get_stac_object {
    ($func:ident, $ret:ty) => {
        #[extendr]
        fn $func(value: ExternalPtr<StacObject>) -> $ret {
            value.$func()
        }
    };
}

get_stac_object!(rust_get_links, Robj);
get_stac_object!(rust_get_version, Result<String, String>);
get_stac_object!(rust_get_extensions, Result<Vec<String>, String>);
get_stac_object!(rust_get_id, Result<String, String>);
get_stac_object!(rust_get_properties, Result<Robj, String>);
get_stac_object!(rust_get_assets, Result<Robj, String>);
get_stac_object!(rust_clone_pointer, ExternalPtr<StacObject>);
get_stac_object!(rust_get_additional_fields, Result<Robj, String>);
get_stac_object!(rust_get_bbox, Result<Robj, String>);
get_stac_object!(rust_get_collection, Result<Robj, String>);

// getters needed:
// geometry
// bbox
// collection
// additional_fields

// Macro to generate exports.
// This ensures exported functions are registered with R.
// See corresponding C code in `entrypoint.c`.
extendr_module! {
    mod stacio;
    fn rust_read_stac;
    fn get_stac_type;
    fn rust_get_links;
    fn rust_get_version;
    fn rust_get_extensions;
    fn rust_get_id;
    fn rust_get_properties;
    fn rust_get_assets;
    fn rust_clone_pointer;
    fn rust_get_additional_fields;
    fn rust_get_bbox;
    fn rust_get_collection;
    impl StacObject;
}
