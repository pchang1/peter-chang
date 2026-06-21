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

# 3) Run the production container on host port 2080 using scripts
./deploy.sh                          # → http://localhost:2080
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
| `deploy.sh` | One-click deployment script (checks port, daemon, and starts docker compose). |
| `update.sh` | One-click update script (pulls git updates if available, rebuilds and restarts container). |
| `stop.sh` | One-click stop script (stops and removes container). |
| `Dockerfile` / `docker-compose.yml` / `nginx.conf` | Containerized nginx deployment. |

## Run locally

It's a static site — just open `index.html`, or serve the folder:

```bash
python3 -m http.server 2080   # then visit http://localhost:2080
```

## Deploy with Docker

The site is served by nginx inside the container (port `80`), **mapped to host port `2080`**.

### Using the Operations Scripts (Recommended)

Three executable scripts are provided for easy management:

- **Deploy (One-click)**:
  ```bash
  ./deploy.sh
  ```
  This will check Docker availability, check if port `2080` is free, build the image, start the container, and wait for the healthcheck to pass.

- **Update (One-click)**:
  ```bash
  ./update.sh
  ```
  This will pull the latest changes from the Git remote (stashing local edits if necessary), rebuild the Docker image, and restart the container cleanly.

- **Stop (One-click)**:
  ```bash
  ./stop.sh
  ```
  This will stop the running container and remove its networks.

### Manual docker compose

```bash
docker compose up -d --build
```

Visit **http://localhost:2080**. Stop with `docker compose down`.

### plain docker

```bash
docker build -t peter-chang-site:latest .
docker run -d --name peter-chang-site -p 2080:80 --restart unless-stopped peter-chang-site:latest
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
