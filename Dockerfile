# peter-chang.net — static personal site served by nginx
FROM nginx:1.27-alpine

# Custom nginx config (gzip, cache headers, SPA-safe fallback)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Static assets
WORKDIR /usr/share/nginx/html
RUN rm -rf ./*
COPY index.html ./
COPY peter-portrait.png via-icon.png ./
COPY Peter_Chang_Resume.pdf ./
COPY resume-print.html ./
RUN ln -sf via-icon.png AppIcon.png && ln -sf via-icon.png apple-touch-icon.png && ln -sf via-icon.png apple-touch-icon-precomposed.png && ln -sf via-icon.png favicon.ico

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://localhost/ >/dev/null 2>&1 || exit 1
