#!/bin/bash
# Script to download required static assets

set -e  # Exit immediately if a command exits with non-zero status

mkdir -p static/css
mkdir -p static/js

# Download Water.css
if curl -f -s -S -L https://cdn.jsdelivr.net/npm/water.css@2/out/water.min.css -o static/css/water.min.css; then
  echo "Water.css downloaded successfully"
else
  echo "Failed to download Water.css" >&2
  exit 1
fi

# Download HTMX
if curl -f -s -S -L https://unpkg.com/htmx.org@2.0.4/dist/htmx.min.js -o static/js/htmx.min.js; then
  echo "HTMX downloaded successfully"
else
  echo "Failed to download HTMX" >&2
  exit 1
fi

# Download Chart.js (for later use)
if curl -f -s -S -L https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.min.js -o static/js/chart.min.js; then
  echo "Chart.js downloaded successfully"
else
  echo "Failed to download Chart.js" >&2
  exit 1
fi

echo "All static files downloaded successfully!"
