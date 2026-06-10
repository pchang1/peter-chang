# peter-chang.net

Personal website & résumé for **Peter Chang** — Senior Director, Head of Marketplace Engineering.

A single-page, dependency-free site (editorial / engineering-at-scale aesthetic: deep-navy type on white, cobalt accents, Bricolage Grotesque · Schibsted Grotesk · IBM Plex Mono) plus a matching, design-consistent **Letter-size PDF résumé**.

## Quick start

Pick whichever fits — no build step or dependencies required:

```bash
# 1) Just view it — open the file directly in a browser
open index.html                       # macOS  (Linux: xdg-open / Windows: start)

# 2) Serve the folder locally (recommended — fonts & PDF behave like production)
python3 -m http.server 8000           # → http://localhost:8000

# 3) Run the production container on host port 777
docker compose up -d --build          # → http://localhost:777
```

See [Run locally](#run-locally) and [Deploy with Docker](#deploy-with-docker) below for details.

## Contents

| File | Purpose |
|------|---------|
| `index.html` | The homepage — self-contained (inline CSS/JS, Google Fonts via CDN). |
| `peter-portrait.png` | Hero portrait. |
| `via-icon.png` | Via Journal app icon. |
| `resume-print.html` | Print-tailored résumé source used to generate the PDF. |
| `Peter_Chang_Resume.pdf` | Styled, Letter-size (8.5×11″) résumé — served by the "Download CV" button. |
| `Dockerfile` / `docker-compose.yml` / `nginx.conf` | Containerized nginx deployment. |

## Run locally

It's a static site — just open `index.html`, or serve the folder:

```bash
python3 -m http.server 8000   # then visit http://localhost:8000
```

## Deploy with Docker

The site is served by nginx inside the container (port `80`), **mapped to host port `777`**.

### docker compose (recommended)

```bash
docker compose up -d --build
```

Visit **http://localhost:777**. Stop with `docker compose down`.

### plain docker

```bash
docker build -t peter-chang-site:latest .
docker run -d --name peter-chang-site -p 777:80 --restart unless-stopped peter-chang-site:latest
```

The container includes a healthcheck and serves the résumé PDF with a
`Content-Disposition: attachment` header so it downloads cleanly.

## Regenerating the PDF

After editing `resume-print.html`, re-render the Letter-size PDF with headless Chrome:

```bash
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless=new --disable-gpu --no-pdf-header-footer \
  --print-to-pdf=Peter_Chang_Resume.pdf --virtual-time-budget=8000 \
  "file://$(pwd)/resume-print.html"
```

Then rebuild the image so the container picks up the new PDF.
