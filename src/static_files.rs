// src/static_files.rs
use actix_web::{HttpResponse, Responder, web};
use rust_embed::RustEmbed;

#[derive(RustEmbed)]
#[folder = "static/"]
pub struct Asset;

pub async fn serve_static(path: web::Path<String>) -> impl Responder {
    let path = path.into_inner();

    // Handle nested paths (e.g., css/water.min.css)
    match Asset::get(&path) {
        Some(content) => {
            let mime = mime_guess::from_path(&path).first_or_octet_stream();
            HttpResponse::Ok()
                .content_type(mime.as_ref())
                .body(content.data)
        }
        None => HttpResponse::NotFound().body("Static file not found"),
    }
}
