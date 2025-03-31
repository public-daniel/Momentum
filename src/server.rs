// src/server.rs
use crate::config::Config;
use crate::static_files;
use crate::templates;
use actix_web::{App, HttpResponse, HttpServer, Responder, web};
use sqlx::SqlitePool;

// Simple echo handler for HTMX demo
async fn echo() -> impl Responder {
    HttpResponse::Ok().body("<div>It works! HTMX successfully sent a request.</div>")
}

// Home page handler
async fn index(config: web::Data<Config>) -> impl Responder {
    let content = templates::hello_world();
    let html = templates::base_layout("Home", content, &config.application.name);
    HttpResponse::Ok().body(html.into_string())
}

// Consolidated Health check endpoint
async fn health_check(db: web::Data<SqlitePool>) -> impl Responder {
    // Use query_scalar with the correct expected type (e.g., i32) for `SELECT 1`
    match sqlx::query_scalar::<_, i32>("SELECT 1")
        .fetch_one(db.get_ref())
        .await
    {
        Ok(_) => HttpResponse::Ok()
            .content_type("application/json")
            .body(r#"{"status":"ok","database":"up"}"#),
        Err(e) => {
            // Log the error for server-side diagnostics
            eprintln!("Health check database error: {}", e);
            HttpResponse::ServiceUnavailable()
                .content_type("application/json")
                .body(
                    // Keep the message generic for the client, or specific if needed
                    r#"{{"status":"error","database":"down","message":"Database connection failed"}}"#, // Alternatively, include the specific error if useful for the client:
                                                                                                        // r#"{{"status":"error","database":"down","message":"{}"}}"#, e
                )
        }
    }
}

pub async fn run_server(config: Config, db_pool: SqlitePool) -> std::io::Result<()> {
    let host = config.server.host.clone();
    let port = config.server.port;
    let config_data = web::Data::new(config); // Renamed to avoid shadowing
    let db_pool_data = web::Data::new(db_pool); // Renamed for clarity

    println!("Starting server at http://{}:{}", host, port);

    HttpServer::new(move || {
        App::new()
            .app_data(config_data.clone())
            .app_data(db_pool_data.clone())
            .route("/", web::get().to(index))
            .route("/echo", web::post().to(echo))
            // Removed the /db-test route
            .route("/health", web::get().to(health_check))
            .route(
                "/static/{filename:.*}",
                web::get().to(static_files::serve_static),
            )
    })
    .bind(format!("{}:{}", host, port))?
    .run()
    .await
}
