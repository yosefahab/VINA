use mongodb::bson::oid::ObjectId;
use serde::{Deserialize, Serialize, Serializer};

#[derive(Debug, Deserialize, Serialize)]
pub struct Article {
    #[serde(
        alias = "_id",
        skip_serializing_if = "Option::is_none",
        serialize_with = "serialize_object_id"
    )]
    id: Option<ObjectId>,
    title: String,
    summary: String,
    url: String,
    date: String,
    category: String,
}
/// used to flatten the bson::ObjectId
/// from: "_id": { "$oid": "<id>" }
/// to: "_id": "<id>"
pub fn serialize_object_id<S>(
    object_id: &Option<ObjectId>,
    serializer: S,
) -> Result<S::Ok, S::Error>
where
    S: Serializer,
{
    match object_id {
        Some(ref object_id) => serializer.serialize_some(object_id.to_string().as_str()),
        None => serializer.serialize_none(),
    }
}
