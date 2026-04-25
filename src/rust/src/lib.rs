use extendr_api::prelude::*;
use extendr_api::serializer::to_robj;
use geo_types::{
    GeometryCollection, LineString, MultiLineString, MultiPoint, MultiPolygon, Point, Polygon,
};
use geojson;
use serde::{Serialize, Deserialize};
use serde_json;
use stac::{Catalog, Collection, Item, ItemCollection, Value};
use stac_io;
use std::string::String;
use wkt::ToWkt;

#[extendr]
#[derive(Clone, Serialize, Deserialize)]
struct WktGeometry {
    bbox: Option<Vec<f64>>,
    value: String,
    foreign_members: Option<serde_json::Map<String, serde_json::Value>>,
}

fn rust_convert_geometry(geometry: geojson::GeometryValue) -> String {
    match geometry {
        geojson::GeometryValue::Point { coordinates: _ } => {
            let geom: Point = geometry.try_into().unwrap();
            geom.wkt_string()
        }
        geojson::GeometryValue::MultiPoint { coordinates: _ } => {
            let geom: MultiPoint = geometry.try_into().unwrap();
            geom.wkt_string()
        }
        geojson::GeometryValue::LineString { coordinates: _ } => {
            let geom: LineString = geometry.try_into().unwrap();
            geom.wkt_string()
        }
        geojson::GeometryValue::MultiLineString { coordinates: _ } => {
            let geom: MultiLineString = geometry.try_into().unwrap();
            geom.wkt_string()
        }
        geojson::GeometryValue::Polygon { coordinates: _ } => {
            let geom: Polygon = geometry.try_into().unwrap();
            geom.wkt_string()
        }
        geojson::GeometryValue::MultiPolygon { coordinates: _ } => {
            let geom: MultiPolygon = geometry.try_into().unwrap();
            geom.wkt_string()
        }
        geojson::GeometryValue::GeometryCollection { geometries: _ } => {
            let geom: GeometryCollection = geometry.try_into().unwrap();
            geom.wkt_string()
        }
    }
}

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
fn rust_get_type_name(value: ExternalPtr<StacObject>) -> &'static str {
    value.rust_get_type_name()
}

#[derive(Clone, Debug)]
enum StacObject {
    Item(Item),
    Catalog(Catalog),
    Collection(Collection),
    ItemCollection(ItemCollection),
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

impl StacObject {
    fn rust_clone_pointer(&self) -> ExternalPtr<StacObject> {
        ExternalPtr::new(self.clone())
    }

    fn rust_get_links(&self) -> Robj {
        match self {
            StacObject::Item(item) => to_robj(&item.links).unwrap(),
            StacObject::Catalog(catalog) => to_robj(&catalog.links).unwrap(),
            StacObject::Collection(collection) => to_robj(&collection.links).unwrap(),
            StacObject::ItemCollection(itemcollection) => to_robj(&itemcollection.links).unwrap(),
        }
    }

    fn rust_get_version(&self) -> Result<String, String> {
        match self {
            StacObject::Item(item) => Ok(item.version.to_string()),
            StacObject::Catalog(catalog) => Ok(catalog.version.to_string()),
            StacObject::Collection(collection) => Ok(collection.version.to_string()),
            StacObject::ItemCollection(_) => Err("ItemCollection objects are not part of the STAC specification and do not have a version.".to_string())
        }
    }

    fn rust_get_extensions(&self) -> Result<Vec<String>, String> {
        match self {
            StacObject::Item(item) => Ok(item.extensions.clone()),
            StacObject::Catalog(catalog) => Ok(catalog.extensions.clone()),
            StacObject::Collection(collection) => Ok(collection.extensions.clone()),
            StacObject::ItemCollection(_) => Err("ItemCollection objects are not part of the STAC specification and do not have extensions.".to_string())
        }
    }

    fn rust_get_id(&self) -> Result<String, String> {
        match self {
            StacObject::Item(item) => Ok(item.id.clone()),
            StacObject::Catalog(catalog) => Ok(catalog.id.clone()),
            StacObject::Collection(collection) => Ok(collection.id.clone()),
            StacObject::ItemCollection(_) => Err("ItemCollection objects are not part of the STAC specification and do not have IDs.".to_string())
        }
    }

    fn rust_get_properties(&self) -> Result<Robj, String> {
        match self {
            StacObject::Item(item) => Ok(to_robj(&item.properties).unwrap()),
            StacObject::Catalog(_) => Err("Catalog objects do not have properties.".to_string()),
            StacObject::Collection(_) => {
                Err("Collection objects do not have properties.".to_string())
            }
            StacObject::ItemCollection(_) => {
                Err("ItemCollection objects do not have properties.".to_string())
            }
        }
    }

    fn rust_get_assets(&self) -> Result<Robj, String> {
        match self {
            StacObject::Item(item) => Ok(to_robj(&item.assets).unwrap()),
            StacObject::Catalog(_) => Err("Catalog objects do not have properties.".to_string()),
            StacObject::Collection(collection) => Ok(to_robj(&collection.item_assets).unwrap()),
            StacObject::ItemCollection(_) => {
                Err("ItemCollection objects do not have properties.".to_string())
            }
        }
    }

    fn rust_get_additional_fields(&self) -> Robj {
        match self {
            StacObject::Item(item) => to_robj(&item.additional_fields).unwrap(),
            StacObject::Catalog(catalog) => to_robj(&catalog.additional_fields).unwrap(),
            StacObject::Collection(collection) => to_robj(&collection.additional_fields).unwrap(),
            StacObject::ItemCollection(itemcollection) => {
                to_robj(&itemcollection.additional_fields).unwrap()
            }
        }
    }

    fn rust_get_bbox(&self) -> Result<Robj, String> {
        match self {
            StacObject::Item(item) => Ok(to_robj(&item.bbox).unwrap()),
            StacObject::Catalog(_) => Err("Catalog objects do not have properties.".to_string()),
            StacObject::Collection(collection) => {
                Ok(to_robj(&collection.extent.spatial.bbox).unwrap())
            }
            StacObject::ItemCollection(_) => {
                Err("ItemCollection objects do not have a bbox.".to_string())
            }
        }
    }

    fn rust_get_collection(&self) -> Result<Robj, String> {
        match self {
            StacObject::Item(item) => Ok(to_robj(&item.collection).unwrap()),
            StacObject::Catalog(_) => Err("Catalog objects do not have a collection.".to_string()),
            StacObject::Collection(_) => {
                Err("Collection objects do not have a collection.".to_string())
            }
            StacObject::ItemCollection(_) => {
                Err("ItemCollection objects do not have a collection.".to_string())
            }
        }
    }

    fn rust_get_type_name(&self) -> &'static str {
        match self {
            StacObject::Item(_) => "Item",
            StacObject::Collection(_) => "Collection",
            StacObject::Catalog(_) => "Catalog",
            StacObject::ItemCollection(_) => "ItemCollection",
        }
    }

    fn rust_get_geometry(&self) -> Result<Robj, String> {
        match self {
            StacObject::Item(item) => match item.geometry.clone() {
                Some(geom) => {
                    let out = WktGeometry {
                        bbox: geom.bbox,
                        value: rust_convert_geometry(geom.value),
                        foreign_members: geom.foreign_members,
                    };
                    Ok(to_robj(&out).unwrap())
                },
                _ => Err("Item did not have a geometry".to_string()),
            },
            StacObject::Catalog(_) => {
                Err("Catalog objects do not have a geometry field.".to_string())
            }
            StacObject::Collection(_) => {
                Err("Collection objects do not have a geometry field.".to_string())
            }
            StacObject::ItemCollection(_) => {
                Err("ItemCollection objects do not have a a geometry field.".to_string())
            }
        }
    }

    fn rust_get_title(&self) -> Result<String, String> {
        match self {
            StacObject::Item(_) => Err("Item objects do not have titles".to_string()),
            StacObject::Catalog(catalog) => {
                match &catalog.title {
                    Some(title) => Ok(title.clone()),
                    _ => Err("Catalog did not have a title".to_string()),
                }
            },
            StacObject::Collection(collection) => {
                match &collection.title {
                    Some(title) => Ok(title.clone()),
                    _ => Err("Collection did not have a title".to_string()),
                }
            },
            StacObject::ItemCollection(_) => {
                Err("ItemCollection objects do not have titles".to_string())
            }
        }
    }

    fn rust_get_description(&self) -> Result<String, String> {
        match self {
            StacObject::Item(_) => Err("Item objects do not have descriptions".to_string()),
            StacObject::Catalog(catalog) => Ok(catalog.description.clone()),
            StacObject::Collection(collection) => Ok(collection.description.clone()),
            StacObject::ItemCollection(_) => {
                Err("ItemCollection objects do not have descriptions".to_string())
            }
        }
    }

    fn rust_get_keywords(&self) -> Result<Vec<String>, String> {
        match self {
            StacObject::Item(_) => Err("Item objects do not have keywords".to_string()),
            StacObject::Catalog(_) => Err("Catalog objects do not have keywords".to_string()),
            StacObject::Collection(collection) => {
                match &collection.keywords {
                    Some(keywords) => Ok(keywords.clone()),
                    _ => Err("Collection did not have keywords".to_string()),
                }
            },
            StacObject::ItemCollection(_) => {
                Err("ItemCollection objects do not have keywords".to_string())
            }
        }
    }

    fn rust_get_license(&self) -> Result<String, String> {
        match self {
            StacObject::Item(_) => Err("Item objects do not have a license".to_string()),
            StacObject::Catalog(_) => Err("Catalog objects do not have a license".to_string()),
            StacObject::Collection(collection) => Ok(collection.license.clone()),
            StacObject::ItemCollection(_) => {
                Err("ItemCollection objects do not have a license".to_string())
            }
        }
    }

    fn rust_get_providers(&self) -> Result<Robj, String> {
        match self {
            StacObject::Item(_) => Err("Item objects do not have a license".to_string()),
            StacObject::Catalog(_) => Err("Catalog objects do not have a license".to_string()),
            StacObject::Collection(collection) => {
                match &collection.providers {
                    Some(providers) => Ok(to_robj(&providers).unwrap()),
                    _ => Err("Collection did not have any providers".to_string())
                }
            },
            StacObject::ItemCollection(_) => {
                Err("ItemCollection objects do not have a license".to_string())
            }
        }
    }

    fn rust_get_summaries(&self) -> Result<Robj, String> {
        match self {
            StacObject::Item(_) => Err("Item objects do not have summaries".to_string()),
            StacObject::Catalog(_) => Err("Catalog objects do not have summaries".to_string()),
            StacObject::Collection(collection) => {
                match &collection.summaries {
                    Some(summaries) => Ok(to_robj(&summaries).unwrap()),
                    _ => Err("Collection did not have any summaries".to_string())
                }
            },
            StacObject::ItemCollection(_) => {
                Err("ItemCollection objects do not have summaries".to_string())
            }
        }
    }

    fn rust_get_extent(&self) -> Result<Robj, String> {
        match self {
            StacObject::Item(_) => Err("Item objects do not have an extent".to_string()),
            StacObject::Catalog(_) => Err("Catalog objects do not have an extent".to_string()),
            StacObject::Collection(collection) => Ok(to_robj(&collection.extent).unwrap()),
            StacObject::ItemCollection(_) => {
                Err("ItemCollection objects do not have an extent".to_string())
            }
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
get_stac_object!(rust_get_additional_fields, Robj);
get_stac_object!(rust_get_bbox, Result<Robj, String>);
get_stac_object!(rust_get_collection, Result<Robj, String>);
get_stac_object!(rust_get_geometry, Result<Robj, String>);
get_stac_object!(rust_get_title, Result<String, String>);
get_stac_object!(rust_get_description, Result<String, String>);
get_stac_object!(rust_get_keywords, Result<Vec<String>, String>);
get_stac_object!(rust_get_license, Result<String, String>);
get_stac_object!(rust_get_providers, Result<Robj, String>);
get_stac_object!(rust_get_summaries, Result<Robj, String>);
get_stac_object!(rust_get_extent, Result<Robj, String>);

// Macro to generate exports.
// This ensures exported functions are registered with R.
// See corresponding C code in `entrypoint.c`.
extendr_module! {
    mod stacio;
    fn rust_read_stac;
    fn rust_get_type_name;
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
    fn rust_get_geometry;
    fn rust_get_title;
    fn rust_get_description;
    fn rust_get_keywords;
    fn rust_get_license;
    fn rust_get_providers;
    fn rust_get_summaries;
    fn rust_get_extent;
}
