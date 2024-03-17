use actix_web::get;
use actix_web::{HttpResponse, Responder};

#[get("/healthz")]
async fn healthz() -> impl Responder {
    HttpResponse::Ok()
}
