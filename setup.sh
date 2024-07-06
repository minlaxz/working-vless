#!/bin/sh
set -e

echo "Generating a self-signed certificate for 'google.com'..."
openssl req -new -newkey rsa:4096 -days 36500 -nodes -x509 \
    -subj "/C=GB/ST=London/L=London/O=Global Security/OU=R&D Department/CN=google.com" \
    -keyout certs/google.com.key.pem -out certs/google.com.cert.pem
echo "Certificate generated."

docker network inspect proxy-net > /dev/null 2>&1 || docker network create proxy-net

echo "Enter your default host for nginx proxy server (e.g. anything.example.com):"
read DEFAULT_HOST
yq w -i ./docker-compose-nginx.yml services.nginx-proxy.environment[1] "DEFAULT_HOST=$DEFAULT_HOST"
docker compose -f docker-compose.nginx.yml up -d

docker run --rm ghcr.io/sagernet/sing-box generate reality-keypair

docker run --rm  ghcr.io/sagernet/sing-box generate rand --base64 16

docker run --rm ghcr.io/sagernet/sing-box generate rand 8 --hex

docker run --rm ghcr.io/sagernet/sing-box generate uuid

mv .env.sample .env

echo "Check and update .env file and run docker compose up -d"
