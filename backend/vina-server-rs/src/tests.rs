#[cfg(test)]
mod mongotests {
    use mongodb::bson::{doc, Document};
    use mongodb::error::Result;
    use mongodb::options::ClientOptions;
    use mongodb::{Client, Collection};

    use chrono::Utc;
    async fn insert_articles(collection: Collection<Document>, n: i32) -> Result<()> {
        let today = Utc::now().naive_utc();
        let formatted_datetime = today.format("%d/%m/%Y").to_string();

        let documents = (0..n)
        .map(|i| {
            doc! { "_id": i,
                "title": format!("Article{}", i),
                "summary": format!("News article{} summary, it should be long as you know, but this is for testing purposes, and i don't have time to write stuff", i),
                "date": formatted_datetime.clone(),
                "category": "science",
                "url": "https://testing.fakeURL.com/science"
            }
        })
        .collect::<Vec<_>>();
        collection.insert_many(documents, None).await?;
        println!("{n} items inserted successfully!");
        Ok(())
    }

    #[actix_web::test]
    async fn insert_20() {
        let username = std::env::var("MONGO_USERNAME").expect("Failed to read MONGO_USERNAME");
        let password = std::env::var("MONGO_PASSWORD").expect("Failed to read MONGO_PASSWORD");
        let client_options = ClientOptions::parse(format!(
            "mongodb://{}:{}@localhost:27017",
            username, password
        ))
        .await
        .expect("Failed to connect to Mongo");
        let client = Client::with_options(client_options).expect("Failed to crate a Client");
        let database = client.database("news");
        let collection = database.collection("dummy"); // Replace with your collection name
        insert_articles(collection, 20)
            .await
            .expect("Failed to insert articles");
    }
}
