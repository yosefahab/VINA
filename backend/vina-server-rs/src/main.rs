mod apis;
mod interfaces;
mod models;
mod tests;
use actix_web::{middleware::Logger, web::Data, App, HttpServer};
use apis::articles::*;
use interfaces::database::MongoDB;

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    std::env::set_var("RUST_LOG", "debug");
    std::env::set_var("RUST_BACKTRACE", "1");

    // we want to panic if credentials aren't set anyway
    let username = std::env::var("MONGO_USERNAME").unwrap();
    let password = std::env::var("MONGO_PASSWORD").unwrap();
    std::env::set_var(
        "MONGOURI",
        format!("mongodb://{}:{}@localhost:27017", username, password),
    );
    // "mongodb+srv://<YOUR USERNAME HERE>:<YOUR PASSWORD HERE>@cluster0.e5akf.mongodb.net/<DB_NAME>?w=majority"

    let db = Data::new(MongoDB::init().await);
    env_logger::init();
    HttpServer::new(move || {
        let logger = Logger::default();
        App::new()
            .app_data(db.clone())
            .wrap(logger)
            .service(get_article)
            .service(get_breaking_news)
    })
    .bind(("127.0.0.1", 8080))?
    .run()
    .await
}