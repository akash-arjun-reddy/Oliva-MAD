# SMS Setup Guide

This guide explains how to set up SMS functionality for OTP delivery in the application.

## Overview

The application supports multiple SMS providers:
- **Development Mode**: Prints OTP to console (for testing)
- **Twilio**: Production SMS service (recommended)

## Quick Setup

### 1. Development Mode (Default)

For testing and development, the app runs in development mode by default. OTPs will be printed to the console.

```bash
# No additional setup required
python test_sms.py
```

### 2. Twilio Setup (Production)

#### Step 1: Get Twilio Account
1. Sign up at [Twilio.com](https://www.twilio.com)
2. Get your Account SID and Auth Token
3. Get a Twilio phone number

#### Step 2: Set Environment Variables

Create a `.env` file in the backend directory:

```env
# SMS Configuration
SMS_PROVIDER=twilio
TWILIO_ACCOUNT_SID=your_account_sid_here
TWILIO_AUTH_TOKEN=your_auth_token_here
TWILIO_FROM_NUMBER=+1234567890

# OTP Configuration
OTP_LENGTH=6
OTP_EXPIRY_MINUTES=10
```

#### Step 3: Test Twilio Setup

```bash
python test_sms.py
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `SMS_PROVIDER` | SMS provider (development/twilio) | `development` |
| `TWILIO_ACCOUNT_SID` | Twilio Account SID | - |
| `TWILIO_AUTH_TOKEN` | Twilio Auth Token | - |
| `TWILIO_FROM_NUMBER` | Twilio phone number | - |
| `OTP_LENGTH` | Length of OTP code | `6` |
| `OTP_EXPIRY_MINUTES` | OTP expiry time in minutes | `10` |
| `DEV_MODE_ENABLED` | Enable development mode | `true` |
| `DEV_PHONE_NUMBER` | Test phone number for dev mode | `+1234567890` |

## Testing

### Test SMS Functionality

```bash
cd BackendMobileAPP
python test_sms.py
```

### Test via API

```bash
# Send OTP
curl -X POST "http://localhost:8000/auth/send-otp" \
  -H "Content-Type: application/json" \
  -d '{"contact_number": "+1234567890"}'

# Verify OTP
curl -X POST "http://localhost:8000/auth/verify-otp" \
  -H "Content-Type: application/json" \
  -d '{"contact_number": "+1234567890", "otp_code": "123456"}'
```

## Troubleshooting

### Common Issues

1. **"Failed to send OTP" Error**
   - Check Twilio credentials
   - Verify phone number format (+1234567890)
   - Check network connectivity

2. **Twilio Authentication Error**
   - Verify Account SID and Auth Token
   - Check if Twilio account is active
   - Ensure sufficient credits

3. **Phone Number Format Error**
   - Use international format: +1234567890
   - Remove spaces and special characters

### Debug Steps

1. **Check Configuration**
   ```bash
   python test_sms.py
   ```

2. **Check Logs**
   ```bash
   # Look for SMS-related logs in your application
   grep -i "sms\|otp" logs/app.log
   ```

3. **Test Twilio Credentials**
   ```python
   from twilio.rest import Client
   client = Client('your_sid', 'your_token')
   messages = client.messages.list(limit=1)
   print("Twilio connection successful")
   ```

## Security Considerations

1. **Environment Variables**: Never commit Twilio credentials to version control
2. **Phone Number Validation**: Validate phone numbers before sending SMS
3. **Rate Limiting**: Implement rate limiting for OTP requests
4. **OTP Expiry**: Set appropriate expiry times (10 minutes recommended)

## Cost Considerations

### Twilio Pricing (as of 2024)
- **SMS**: ~$0.0079 per message (US)
- **International**: Varies by country
- **Free Trial**: $15-20 credit for new accounts

### Development Mode
- **Cost**: Free
- **Use Case**: Testing and development
- **Limitation**: OTPs only printed to console

## Alternative SMS Providers

You can extend the SMS service to support other providers:

1. **AWS SNS**
2. **MessageBird**
3. **Vonage (formerly Nexmo)**
4. **Plivo**

To add a new provider, modify `utils/sms_service.py` and add the new provider logic.

## Production Checklist

- [ ] Set up Twilio account
- [ ] Configure environment variables
- [ ] Test SMS delivery
- [ ] Set up monitoring/logging
- [ ] Implement rate limiting
- [ ] Add phone number validation
- [ ] Set up error handling
- [ ] Monitor costs
- [ ] Test with real phone numbers 