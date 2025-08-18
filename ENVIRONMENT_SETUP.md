# Environment Setup Guide

This guide will help you set up all environment variables to replace hardcoded secrets and API keys.

## 🚨 Security Notice

All sensitive data has been moved to environment variables. Never commit actual API keys or passwords to the repository.

## 📁 Backend Environment Setup

### 1. Create `.env` file in `BackendMobileAPP/` directory

Copy the contents from `BackendMobileAPP/env_example.txt` and create a `.env` file:

```bash
# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=oliva_clinic
DB_USER=postgres
DB_PASSWORD=your_actual_db_password

# Application Secrets
SECRET_KEY=your_actual_secret_key_here
ACCESS_TOKEN_EXPIRE_MINUTES=30

# Email Configuration
SENDGRID_API_KEY=your_actual_sendgrid_api_key
SENDER_PASSWORD=your_actual_sender_password
AZURE_MAIL_PASSWORD=your_actual_azure_mail_password

# OAuth Configuration
AZURE_CLIENT_SECRET=your_actual_azure_client_secret
GOOGLE_CLIENT_SECRET=your_actual_google_client_secret

# SMS Configuration
TWILIO_AUTH_TOKEN=your_actual_twilio_auth_token

# Shopify Configuration
SHOPIFY_ACCESS_TOKEN=your_actual_shopify_access_token

# Zenoti Configuration
ZENOTI_API_KEY=your_actual_zenoti_api_key
ZENOTI_PASSWORD=your_actual_zenoti_password
ZENOTI_DB_PASSWORD=your_actual_zenoti_db_password

# Gmail Configuration (for video backend)
GMAIL_PASSWORD=your_actual_gmail_password
CUSTOM_JITSI_PASSWORD=your_actual_jitsi_password
```

### 2. Create `.env` file in `vedio/backend/` directory

```bash
# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=oliva_clinic
DB_USER=postgres
DB_PASSWORD=your_actual_db_password

# Email Configuration
SENDGRID_API_KEY=your_actual_sendgrid_api_key
SENDER_PASSWORD=your_actual_sender_password
AZURE_MAIL_PASSWORD=your_actual_azure_mail_password

# OAuth Configuration
AZURE_CLIENT_SECRET=your_actual_azure_client_secret

# Gmail Configuration
GMAIL_PASSWORD=your_actual_gmail_password
CUSTOM_JITSI_PASSWORD=your_actual_jitsi_password
```

## 📱 Flutter Environment Setup

### 1. For Development

Create a `.env` file in the `frontend/` directory:

```bash
# API Configuration
API_BASE_URL=http://localhost:8000

# Shopify Configuration
SHOPIFY_ACCESS_TOKEN=your_actual_shopify_access_token
SHOPIFY_BASE_URL=https://oliva-clinic.myshopify.com

# Payment Configuration
PAYMENT_API_KEY=your_actual_payment_api_key
PAYMENT_SECRET_KEY=your_actual_payment_secret_key

# Email Configuration
SENDGRID_API_KEY=your_actual_sendgrid_api_key

# SMS Configuration
TWILIO_AUTH_TOKEN=your_actual_twilio_auth_token

# Video Call Configuration
JITSI_PASSWORD=your_actual_jitsi_password

# Feature Flags
ENABLE_VIDEO_CALLS=true
ENABLE_PAYMENTS=true
ENABLE_SHOPIFY=true
```

### 2. For Production Build

Use `--dart-define` flags when building:

```bash
flutter build apk --dart-define=API_BASE_URL=https://your-production-api.com \
                 --dart-define=SHOPIFY_ACCESS_TOKEN=your_actual_token \
                 --dart-define=PAYMENT_API_KEY=your_actual_key \
                 --dart-define=SENDGRID_API_KEY=your_actual_key
```

## 🔧 How to Load Environment Variables

### Backend (Python)

The backend automatically loads environment variables from `.env` files using `python-dotenv`.

### Flutter

Environment variables are accessed through the `Env` class in `lib/config/env.dart`.

## 🛡️ Security Best Practices

1. **Never commit `.env` files** - They should be in `.gitignore`
2. **Use strong, unique passwords** for each service
3. **Rotate API keys regularly**
4. **Use environment-specific configurations**
5. **Validate environment variables on startup**

## 📋 Required Environment Variables

### Backend Required Variables:
- `DB_PASSWORD` - Database password
- `SECRET_KEY` - JWT secret key
- `SENDGRID_API_KEY` - For email sending
- `SHOPIFY_ACCESS_TOKEN` - For Shopify integration
- `TWILIO_AUTH_TOKEN` - For SMS functionality

### Flutter Required Variables:
- `API_BASE_URL` - Backend API URL
- `SHOPIFY_ACCESS_TOKEN` - For Shopify integration
- `PAYMENT_API_KEY` - For payment processing

## 🚀 Quick Start

1. Copy `BackendMobileAPP/env_example.txt` to `BackendMobileAPP/.env`
2. Fill in your actual values
3. Copy the Flutter environment template to `frontend/.env`
4. Fill in your actual values
5. Start the backend and Flutter app

## 🔍 Troubleshooting

If you get "environment variable not found" errors:
1. Check that `.env` files exist
2. Verify variable names match exactly
3. Restart the application after changing environment variables
4. Check file permissions on `.env` files
