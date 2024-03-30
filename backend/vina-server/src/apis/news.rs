use crate::interfaces::database::MongoDB;
use actix_web::{
    get,
    web::{Data, Path, Query},
    HttpResponse,
};
use serde::Deserialize;

#[derive(Deserialize)]
struct RequestParams {
    offset: Option<String>,
    limit: Option<i64>,
}

// http://127.0.0.1:8080/articles/<CATEGORY>?limit=<LIMIT>&offset=<OFFSET>
#[get("/articles/{category}")]
async fn get_articles(
    db: Data<MongoDB>,
    category: Path<String>,
    params: Query<RequestParams>,
) -> HttpResponse {
    let category = category.into_inner();
    let limit = params.limit.unwrap_or(10).max(0).min(20);
    let offset = params.offset.as_deref();
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
    let offset = params.offset.as_deref();
    let limit = params.limit.unwrap_or(10).max(0).min(20);
    match db.get_breaking_news(category, offset, limit).await {
        Some(a) => HttpResponse::Ok().json(a),
        None => HttpResponse::NotFound().into(),
    }
}
