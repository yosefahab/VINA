use serde::{Deserialize, Serialize};

#[derive(Debug, Deserialize, Serialize)]
pub struct Article {
    title: String,
    summary: String,
    url: String,
    date: String,
    category: String,
}

impl Article {
    #[allow(unused)]
    pub fn dummy() -> Self {
        Self {
            title: "Dummy title".to_string(),
            summary: "Some Dummy Summary".to_string(),
            url: "www.Dummy.com".to_string(),
            date: "10/5/2023".to_string(),
            category: "Dummy".to_string(),
        }
    }
}
