use crate::models::article::Article;
use futures::TryStreamExt;
use mongodb::{
    bson::{doc, Document},
    options::FindOptions,
    Client, Collection, Database,
};

pub struct MongoDB {
    db: Database,
}

impl MongoDB {
    /// Returns a database instance
    pub async fn init() -> MongoDB {
        let uri = match std::env::var("MONGO_URI") {
            Ok(uri) => uri,
            Err(_) => unreachable!(), // impossible case, as we set the env variable before calling
                                      // this function.
        };
        let client = Client::with_uri_str(uri)
            .await
            .expect("Failed to instantiate database client"); // we want this to crash if we cannot
                                                              // connect anyway
        let db = match std::env::var("MONGO_DB") {
            Ok(table) => table,
            Err(_) => unreachable!(),
        };

        MongoDB {
            db: client.database(&db),
        }
    }

    /// returns a filter as bson::Document from the given <category> and a handle to the <collection> in the database.
    async fn get_filter_collection(
        &self,
        collection: &str,
        category: Option<String>,
        _last_id: i64,
    ) -> (Option<Document>, Collection<Article>) {
        let filter: Option<Document> = category.as_ref().map(|v| {
            doc! {
                "category": v,
                // TODO: use previous id to enable pagination
                // "_id": { "$gt": last_id },
            }
        });
        (filter, self.db.collection::<Article>(collection))
    }

    pub async fn get_articles(
        &self,
        category: String,
        offset: i64,
        limit: i64,
    ) -> Option<Vec<Article>> {
        let (filter, collection) = self
            .get_filter_collection("articles", Some(category), offset)
            .await;
        // collection.find_one(filter, None).await.unwrap()
        collection
            .find(filter, FindOptions::builder().limit(limit).build())
            .await
            .unwrap()
            .try_collect()
            .await
            .ok()
    }
    pub async fn get_breaking_news(
        &self,
        category: String,
        offset: i64,
        limit: i64,
    ) -> Option<Vec<Article>> {
        let (filter, collection) = self
            .get_filter_collection("breaking_news", Some(category), offset)
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
