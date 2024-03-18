mod apis;
mod interfaces;
mod models;
mod tests;
use std::env;

use actix_web::{middleware::Logger, web::Data, App, HttpServer};
use apis::{articles::*, healthz::healthz};
use interfaces::database::MongoDB;

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    env::set_var("RUST_LOG", "debug");
    env::set_var("RUST_BACKTRACE", "1");

    // we want to panic if credentials aren't set anyway
    let username = env::var("MONGO_USERNAME").unwrap();
    let password = env::var("MONGO_PASSWORD").unwrap();
    let port = env::var("MONGO_PORT").unwrap();
    env::set_var(
        "MONGO_URI",
        format!("mongodb://{}:{}@vina-db:{}", username, password, port),
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
            .service(healthz)
    })
    .bind(("0.0.0.0", 8080))?
    .run()
    .await
}
