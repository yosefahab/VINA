mod apis;
mod interfaces;
mod models;
mod tests;
use std::env;

use actix_files::Files;
use actix_governor::{Governor, GovernorConfigBuilder};
use actix_web::{middleware::Logger, web::Data, App, HttpServer};
use apis::{healthz::healthz, news::*};
use interfaces::database::MongoDB;

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    env::set_var("RUST_LOG", "debug");
    env::set_var("RUST_BACKTRACE", "1");
    env_logger::init();

    // we want to panic if credentials aren't set anyway
    let username = env::var("MONGO_USERNAME").expect("Missing env var: MONGO_USERNAME");
    let password = env::var("MONGO_PASSWORD").expect("Missing env var: MONGO_PASSWORD");
    let port = env::var("MONGO_PORT").expect("Missing env var: MONGO_PORT");
    let db_name = env::var("MONGO_DB").expect("Missing env var: Mongo_DB");
    let db_hostname = env::var("MONGO_HOSTNAME").expect("Missing env var: MONGO_HOSTNAME");

    let uri = format!(
        "mongodb://{}:{}@{}:{}/{}",
        username, password, db_hostname, port, db_name
    );
    let db = Data::new(
        MongoDB::init(&uri)
            .await
            .expect("Error initializing MongoDB"),
    );

    let governor = GovernorConfigBuilder::default()
        .per_second(2)
        .burst_size(10)
        .finish()
        .expect("Error initializing Governor");
    HttpServer::new(move || {
        let logger = Logger::default();
        App::new()
            .app_data(db.clone())
            .wrap(logger)
            .wrap(Governor::new(&governor))
            .service(get_articles)
            .service(get_breaking_news)
            .service(healthz)
            .service(Files::new("/", "./public").index_file("index.html"))
    })
    .bind(("0.0.0.0", 8080))?
    .run()
    .await
}
