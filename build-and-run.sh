#!/bin/bash

set -e

echo "📡 Fetching EC2 Public IP..."

# Try using IMDSv2 to get EC2 public IP
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 60" || true)

if [ -n "$TOKEN" ]; then
  EC2_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
    http://169.254.169.254/latest/meta-data/public-ipv4)
fi

# Fallback if metadata fails
if [ -z "$EC2_IP" ]; then
  echo "⚠️ Metadata fetch failed. Falling back to external IP service..."
  EC2_IP=$(curl -s ifconfig.me)
fi

# Exit if still blank
if [ -z "$EC2_IP" ]; then
  echo "❌ Failed to determine EC2 public IP. Aborting."
  exit 1
fi

echo "✅ Using EC2 IP: $EC2_IP"

# Set API URL
VITE_API_URL="http://$EC2_IP:5000"

echo "🔧 Building frontend with VITE_API_URL=$VITE_API_URL"
docker build --build-arg VITE_API_URL=$VITE_API_URL -t my-frontend ./frontend

echo "🚀 Starting app with docker-compose"
docker compose up --build
