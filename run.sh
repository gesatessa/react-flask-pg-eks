#!/bin/bash

# Get the public IP (fallback to hostname if not available)
PUBLIC_IP=$(curl -s ident.me || hostname -I | awk '{print $1}')
API_HOST="http://${PUBLIC_IP}:5000"

echo "Using API_HOST=${API_HOST}"

API_HOST=$API_HOST docker compose up --build

echo "API_HOST=${API_HOST}" > .env
#docker compose --env-file .env up --build


#curl http://169.254.169.254/latest/meta-data/public-ipv4 only works if the EC2 instance has a public IP assigned and instance metadata is accessible.

#hostname -I gives the private IP, which works for internal communication but not for accessing from a browser over the internet.

#curl ident.me gives the public IP visible externally, and is often the most reliable for automation in public-facing apps.
