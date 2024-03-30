use crate::models::article::Article;
use futures::TryStreamExt;
use mongodb::{
    bson::{doc, oid::ObjectId, Document},
    error::Error,
    options::{ClientOptions, FindOptions},
    Client, Collection, Database,
};
use std::{str::FromStr, time::Duration};

pub struct MongoDB {
    db: Database,
}

impl MongoDB {
    /// Returns a database instance
    pub async fn init(uri: &str) -> Result<MongoDB, Error> {
        let mut client_options = ClientOptions::parse(uri)
            .await
            .expect("Failed to parse mongo uri");

        // Set a timeout for the connection attempt
        client_options.server_selection_timeout = Some(Duration::from_secs(10));
        let client = match Client::with_options(client_options) {
            Ok(client) => client,
            Err(e) => return Err(e),
        };
        let db = match client.default_database() {
            Some(db) => db,
            None => return Err(Error::custom("No db specified in mongo uri")),
        };

        // Attempt to ping the database to ensure connectivity
        match db.run_command(doc! { "ping": 1 }, None).await {
            Ok(_) => Ok(MongoDB { db }),
            Err(e) => Err(e),
        }
    }
    /// returns a filter as bson::Document from the given <category> and a handle to the <collection> in the database.
    /// uses last_id as an offset to enable pagination
    async fn get_filter_collection(
        &self,
        collection: &str,
        category: String,
        offset: Option<&str>,
    ) -> (Document, Collection<Article>) {
        let mut filter = doc! { "category": &category };

        if let Some(offset) = offset {
            if let Ok(last_id) = ObjectId::from_str(offset) {
                filter.insert("_id", doc! { "$gt": last_id });
            }
        }
        (filter, self.db.collection::<Article>(collection))
    }

    /// returns a list of articles from a specific category
    /// optional offset can be used to enable pagination, where @offset is the id of the last article
    pub async fn get_articles(
        &self,
        category: String,
        offset: Option<&str>,
        limit: i64,
    ) -> Option<Vec<Article>> {
        let (filter, collection) = self
            .get_filter_collection("articles", category, offset)
            .await;
        collection
            .find(filter, FindOptions::builder().limit(limit).build())
            .await
            .unwrap()
            .try_collect()
            .await
            .ok()
    }
    /// returns a list of breaking from a specific category
    /// optional offset can be used to enable pagination, where @offset is the id of the last article
    pub async fn get_breaking_news(
        &self,
        category: String,
        offset: Option<&str>,
        limit: i64,
    ) -> Option<Vec<Article>> {
        let (filter, collection) = self
            .get_filter_collection("breaking_news", category, offset)
            .await;
        collection
            .find(filter, FindOptions::builder().limit(limit).build())
            .await
            .unwrap()
            .try_collect()
            .await
            .ok()
    }
}
