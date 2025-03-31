// src/templates/mod.rs
use maud::{DOCTYPE, Markup, html};

pub fn base_layout(title: &str, content: Markup, app_name: &str) -> Markup {
    html! {
        (DOCTYPE)
        html lang="en" {
            head {
                meta charset="utf-8";
                meta name="viewport" content="width=device-width, initial-scale=1";
                title { (app_name) " - " (title) }

                // Link to embedded static CSS
                link rel="stylesheet" href="/static/css/water.min.css";

                // Include embedded static JS libraries
                script src="/static/js/htmx.min.js" {}
                script src="/static/js/chart.min.js" {}
            }
            body hx-boost="true" {
                header {
                    h1 { (app_name) }
                }
                main {
                    (content)
                }
                footer {
                    p { "Momentum App - " (chrono::Local::now().format("%Y-%m-%d")) }
                }
            }
        }
    }
}

pub fn hello_world() -> Markup {
    html! {
        div {
            h2 { "Hello, Momentum!" }
            p { "This is the bare minimum setup to get started." }

            // Add a simple HTMX example
            button hx-post="/echo" hx-swap="outerHTML" {
                "Click me (HTMX test)"
            }
        }
    }
}
