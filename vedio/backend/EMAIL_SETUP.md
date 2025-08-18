# 📧 Email Setup Guide for Jitsi Meet Link Generator

## 🎯 **Email Configuration Options**

### **Option 1: Gmail SMTP (Recommended)**

1. **Create App Password:**
   - Go to your Google Account settings
   - Enable 2-factor authentication
   - Generate an "App Password" for "Mail"
   - Use this password instead of your regular password

2. **Create .env file:**
```bash
# Copy env_example.txt to .env
cp env_example.txt .env
```

3. **Edit .env file:**
```bash
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
SENDER_EMAIL=your-email@gmail.com
SENDER_PASSWORD=your-16-digit-app-password
```

### **Option 2: Outlook/Hotmail SMTP**

```bash
SMTP_SERVER=smtp-mail.outlook.com
SMTP_PORT=587
SENDER_EMAIL=your-email@outlook.com
SENDER_PASSWORD=your-password
```

### **Option 3: Custom SMTP Server**

```bash
SMTP_SERVER=your-smtp-server.com
SMTP_PORT=587
SENDER_EMAIL=your-email@yourdomain.com
SENDER_PASSWORD=your-password
```

## 🔧 **Gmail App Password Setup (Step by Step)**

1. **Go to Google Account:**
   - Visit https://myaccount.google.com/
   - Sign in with your Gmail account

2. **Enable 2-Factor Authentication:**
   - Go to "Security" tab
   - Click "2-Step Verification"
   - Follow the setup process

3. **Generate App Password:**
   - Go to "Security" → "App passwords"
   - Select "Mail" and "Other (Custom name)"
   - Enter "Jitsi Meet Generator"
   - Click "Generate"
   - Copy the 16-digit password

4. **Use in .env file:**
```bash
SENDER_EMAIL=your-email@gmail.com
SENDER_PASSWORD=abcd efgh ijkl mnop  # Your 16-digit app password
```

## 🧪 **Test Email Functionality**

1. **Start the backend:**
```bash
cd backend
python main.py
```

2. **Test with API:**
```bash
curl -X POST "http://localhost:8002/api/v1/send-email" \
  -H "Content-Type: application/json" \
  -d '{
    "customer_name": "John Doe",
    "doctor_name": "Dr. Sarah Smith",
    "slot_time": "2024:01:15",
    "customer_email": "customer@example.com",
    "doctor_email": "doctor@example.com"
  }'
```

## 🔍 **Troubleshooting**

### **Common Issues:**

1. **"Authentication failed"**
   - Check your app password is correct
   - Ensure 2-factor authentication is enabled

2. **"Connection refused"**
   - Check SMTP server and port
   - Try different ports (587, 465, 25)

3. **"Invalid email format"**
   - Verify email addresses are valid
   - Check for typos in email addresses

### **Security Notes:**

- ✅ **Use App Passwords** - Don't use your main password
- ✅ **Keep .env secure** - Don't commit to version control
- ✅ **Test with your own email** - Verify setup works

## 🚀 **Alternative: No Email Setup**

If you don't want to set up email:

1. **Just use the link generation:**
   - Create meeting links
   - Copy and paste manually
   - Share via other methods (WhatsApp, SMS, etc.)

2. **The app works perfectly without email:**
   - All core functionality works
   - Email is optional feature
   - Links can be shared manually

## 📱 **Frontend Integration**

The Flutter app will automatically:
- ✅ Try to send emails if configured
- ✅ Show email status in the UI
- ✅ Gracefully handle email failures
- ✅ Still work if email is not set up 