#!/bin/bash

# Oliva Clinic Backend Deployment Script
echo "🚀 Starting Oliva Clinic Backend Deployment..."

# Check if flyctl is installed
if ! command -v flyctl &> /dev/null; then
    echo "❌ flyctl is not installed. Please install it first:"
    echo "curl -L https://fly.io/install.sh | sh"
    exit 1
fi

# Check if user is logged in
if ! flyctl auth whoami &> /dev/null; then
    echo "❌ Not logged in to Fly.io. Please run: flyctl auth login"
    exit 1
fi

# Check if app exists
if ! flyctl apps list | grep -q "oliva-clinic-backend"; then
    echo "📱 Creating new Fly.io app..."
    flyctl launch --name oliva-clinic-backend --region bom --no-deploy
else
    echo "📱 App already exists, proceeding with deployment..."
fi

# Set environment variables
echo "🔧 Setting environment variables..."
echo "Please enter your Neon database URL:"
read -p "DATABASE_URL: " DATABASE_URL

echo "Please enter your secret key:"
read -p "SECRET_KEY: " SECRET_KEY

# Set secrets
flyctl secrets set DATABASE_URL="$DATABASE_URL"
flyctl secrets set SECRET_KEY="$SECRET_KEY"
flyctl secrets set ALGORITHM="HS256"
flyctl secrets set ACCESS_TOKEN_EXPIRE_MINUTES="30"

echo "✅ Environment variables set successfully!"

# Deploy the app
echo "🚀 Deploying to Fly.io..."
flyctl deploy

# Check deployment status
echo "📊 Checking deployment status..."
flyctl status

echo "🎉 Deployment completed!"
echo "Your app is available at: https://oliva-clinic-backend.fly.dev"
echo "Health check: https://oliva-clinic-backend.fly.dev/health"
echo "API docs: https://oliva-clinic-backend.fly.dev/docs"

# Open the app in browser
echo "🌐 Opening app in browser..."
flyctl open 