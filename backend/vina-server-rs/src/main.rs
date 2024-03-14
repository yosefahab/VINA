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

    let env_path = env::current_dir().map(|a| a.join("../sql/.env")).unwrap();
    dotenv::from_path(env_path.as_path()).unwrap();
    // we want to panic if credentials aren't set anyway
    let username = env::var("MONGO_USERNAME").unwrap();
    let password = env::var("MONGO_PASSWORD").unwrap();
    env::set_var(
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
            .service(healthz)
    })
    .bind(("127.0.0.1", 8080))?
    .run()
    .await
}
