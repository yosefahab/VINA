use crate::interfaces::database::MongoDB;
use actix_web::web::Data;
use actix_web::HttpResponse;
use actix_web::{
    get,
    web::{Path, Query},
};
use serde::Deserialize;

#[derive(Deserialize)]
struct RequestParams {
    offset: Option<i64>,
    limit: Option<i64>,
}

// http://127.0.0.1:8080/articles/<{category}><?limit=LIMIT&offset=OFFSET>
#[get("/articles/{category}")]
async fn get_article(
    db: Data<MongoDB>,
    category: Path<String>,
    params: Query<RequestParams>,
) -> HttpResponse {
    let category = category.into_inner();
    let offset = params.offset.unwrap_or(0).max(0);
    let limit = params.limit.unwrap_or(10).max(0).min(20);
    match db.get_articles(category, offset, limit).await {
        Some(a) => HttpResponse::Ok().json(a),
        None => HttpResponse::NotFound().into(),
    }
}
#[get("/breaking_news/{category}")]
async fn get_breaking_news(
    db: Data<MongoDB>,
    category: Path<String>,
    params: Query<RequestParams>,
) -> HttpResponse {
    let category = category.into_inner();
    let offset = params.offset.unwrap_or(0).max(0);
    let limit = params.limit.unwrap_or(10).max(0).min(20);
    match db.get_breaking_news(category, offset, limit).await {
        Some(a) => HttpResponse::Ok().json(a),
        None => HttpResponse::NotFound().into(),
    }
}
