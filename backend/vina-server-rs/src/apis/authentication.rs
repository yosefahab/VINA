use actix_web::{post, web};

#[derive(serde::Deserialize)]
struct LoginForm {
    username: String,
    password: String,
}

#[post("/login")]
async fn login(form: web::Form<LoginForm>) -> String {
    format!("Welcome, {}!", form.username)
}
