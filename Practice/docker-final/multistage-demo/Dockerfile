FROM alpine:3.22 AS builder

WORKDIR /app

COPY src/index.html ./index.html

RUN mkdir -p /app/dist && \
    cp /app/index.html /app/dist/index.html

FROM nginx:alpine AS runtime

COPY --from=builder /app/dist/index.html /usr/share/nginx/html/index.html

EXPOSE 80

