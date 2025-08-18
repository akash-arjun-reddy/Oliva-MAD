# Quick SMS Setup Guide

## Problem
Currently, OTPs are only printed to the console and not sent to your phone.

## Solution Options

### Option 1: Twilio (Recommended - International)
1. Sign up at [Twilio.com](https://www.twilio.com/)
2. Get your Account SID and Auth Token
3. Get a Twilio phone number
4. Set environment variables:

```bash
# In your backend directory, create a .env file:
TWILIO_ACCOUNT_SID=your_account_sid_here
TWILIO_AUTH_TOKEN=your_auth_token_here
TWILIO_FROM_NUMBER=+1234567890
SMS_PROVIDER=twilio
```

### Option 2: MSG91 (For India)
1. Sign up at [MSG91.com](https://msg91.com/)
2. Get your API key
3. Set environment variables:

```bash
FREE_SMS_API_KEY=your_msg91_api_key_here
FREE_SMS_SENDER_ID=your_sender_id
```

### Option 3: TextLocal (For India)
1. Sign up at [TextLocal.in](https://www.textlocal.in/)
2. Get your API key
3. Set environment variables:

```bash
FREE_SMS_API_KEY=your_textlocal_api_key_here
FREE_SMS_SENDER_ID=your_sender_id
```

## Quick Test

After setting up any of the above options:

1. Start your backend server
2. Run the SMS test:
   ```bash
   python test_sms.py
   ```
3. Check if SMS is sent to your phone

## For Immediate Testing

If you want to test right now without setting up SMS:

1. The OTP will be printed in your backend console
2. Use that OTP in your app
3. Later, configure one of the SMS services above

## Environment Variables Reference

```bash
# SMS Provider
SMS_PROVIDER=development  # or twilio

# Twilio (International)
TWILIO_ACCOUNT_SID=your_sid
TWILIO_AUTH_TOKEN=your_token
TWILIO_FROM_NUMBER=+1234567890

# Free SMS Service (India)
FREE_SMS_API_KEY=your_api_key
FREE_SMS_SENDER_ID=your_sender_id

# OTP Configuration
OTP_LENGTH=6
OTP_EXPIRY_MINUTES=10
```

## Testing Steps

1. **Set up SMS credentials** (choose one option above)
2. **Start backend server**
3. **Login with your phone number** in the app
4. **Check your phone** for OTP
5. **Enter OTP** in the app
6. **Test video call OTP** by clicking "Join Video"

## Troubleshooting

### "No SMS received"
- Check if credentials are set correctly
- Verify phone number format (+1234567890)
- Check backend console for errors

### "Invalid credentials"
- Double-check your API keys
- Ensure environment variables are set
- Restart backend server after setting variables

### "Phone number format error"
- Use international format: +1234567890
- Remove spaces and special characters
- For India: +91XXXXXXXXXX
- For US: +1XXXXXXXXXX 