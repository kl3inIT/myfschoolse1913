# syntax=docker/dockerfile:1.7

FROM node:24-alpine AS builder

RUN corepack enable && corepack prepare pnpm@11.9.0 --activate
WORKDIR /app

COPY package.json pnpm-lock.yaml ./
RUN --mount=type=cache,id=myfschool-pnpm-store,target=/pnpm-store \
    pnpm config set store-dir /pnpm-store \
    && pnpm install --frozen-lockfile

COPY . .
RUN pnpm build

FROM nginx:1.29-alpine

RUN apk add --no-cache curl

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/dist /usr/share/nginx/html

RUN addgroup -g 1655 -S appgroup \
    && adduser -u 1655 -S appuser -G appgroup \
    && sed -i '/^user /d' /etc/nginx/nginx.conf \
    && sed -i -E 's|pid\s+/(var/)?run/nginx.pid;|pid /tmp/nginx.pid;|' /etc/nginx/nginx.conf \
    && chown -R 1655:1655 /var/cache/nginx /var/log/nginx /usr/share/nginx/html

USER 1655:1655
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -fsS http://localhost:8080/healthz || exit 1

CMD ["nginx", "-g", "daemon off;"]
