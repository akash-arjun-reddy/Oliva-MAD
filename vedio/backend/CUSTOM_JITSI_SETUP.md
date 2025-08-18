# 🔧 Custom Jitsi Meet Server Setup

## 🎯 **If You Have Your Own Jitsi Meet Server**

### **Step 1: Configure Your Custom Server**

Create a `.env` file in the backend directory:

```bash
# Your Custom Jitsi Meet Server
CUSTOM_JITSI_SERVER=https://your-jitsi-server.com
CUSTOM_JITSI_EMAIL=your-email@yourdomain.com
CUSTOM_JITSI_PASSWORD=your-jitsi-password

# Email Settings (for sending meeting links)
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
SENDER_EMAIL=your-email@gmail.com
SENDER_PASSWORD=your-app-password

# App Settings
DEBUG=false
HOST=127.0.0.1
PORT=8002
```

### **Step 2: Update Jitsi Meet Service**

If you need to use your custom Jitsi Meet server instead of the public one, update the settings:

```bash
# Use your custom server
JITSI_BASE_URL=https://your-jitsi-server.com
JITSI_CONFIG_PARAMS=config.prejoinPageEnabled=false&config.disableDeepLinking=true
```

### **Step 3: Test Your Setup**

1. **Start the backend:**
```bash
cd backend
python main.py
```

2. **Test with your custom server:**
```bash
curl -X POST "http://localhost:8002/api/v1/generate-link" \
  -H "Content-Type: application/json" \
  -d '{
    "customer_name": "John Doe",
    "doctor_name": "Dr. Sarah Smith",
    "slot_time": "2024:01:15"
  }'
```

## 🔍 **What You Need to Provide:**

### **For Jitsi Meet Server:**
- **Server URL**: Your Jitsi Meet server address
- **Email**: The email you registered with Jitsi Meet
- **Password**: Your Jitsi Meet account password

### **For Email Functionality:**
- **SMTP Server**: Your email provider's SMTP server
- **Email**: Your email address
- **Password**: Your email password or app password

## 🚀 **Integration Options:**

### **Option 1: Use Public Jitsi Meet (Current)**
```bash
# Uses https://meet.jit.si (no credentials needed)
JITSI_BASE_URL=https://meet.jit.si
```

### **Option 2: Use Your Custom Server**
```bash
# Uses your registered Jitsi Meet server
JITSI_BASE_URL=https://your-jitsi-server.com
CUSTOM_JITSI_EMAIL=your-email@yourdomain.com
CUSTOM_JITSI_PASSWORD=your-password
```

### **Option 3: Hybrid Approach**
- Use public Jitsi Meet for video calls
- Use your email for sending meeting links
- Best of both worlds

## 📧 **Email Integration with Your Jitsi Server:**

If your Jitsi Meet server has email integration:

1. **Configure SMTP in your Jitsi server**
2. **Set up email templates**
3. **Use our app to generate links**
4. **Let Jitsi handle email sending**

## 🔧 **Advanced Configuration:**

### **Custom Jitsi Meet API Integration:**

If your Jitsi server has API endpoints, you can integrate them:

```python
# In meeting_service.py
async def create_meeting_with_custom_server(self, request):
    # Use your custom Jitsi server API
    # Send meeting creation request to your server
    # Handle authentication with your credentials
    pass
```

### **Email Templates:**

Customize email content for your organization:

```python
# In email_service.py
def create_custom_email_body(self, meeting_data):
    return f"""
    Dear {meeting_data.customer_name},
    
    Your meeting with {meeting_data.doctor_name} has been scheduled.
    
    Meeting Details:
    - Date: {meeting_data.slot_time}
    - Link: {meeting_data.meeting_link}
    
    Best regards,
    Your Organization Name
    """
```

## 🧪 **Testing Your Setup:**

1. **Test Jitsi Server Connection:**
```bash
curl https://your-jitsi-server.com
```

2. **Test Email Sending:**
```bash
curl -X POST "http://localhost:8002/api/v1/send-email" \
  -H "Content-Type: application/json" \
  -d '{
    "customer_name": "Test User",
    "doctor_name": "Test Doctor",
    "slot_time": "2024:01:15",
    "customer_email": "test@example.com",
    "doctor_email": "doctor@example.com"
  }'
```

## 🔍 **Troubleshooting:**

### **Common Issues:**

1. **"Cannot connect to Jitsi server"**
   - Check your server URL
   - Verify server is running
   - Check firewall settings

2. **"Authentication failed"**
   - Verify your Jitsi credentials
   - Check email/password format

3. **"Email not sending"**
   - Check SMTP settings
   - Verify email credentials
   - Test with different email provider

### **Need Help?**

If you need help integrating your specific Jitsi Meet server, please provide:
- Your Jitsi server URL
- Your registration email
- Any API documentation you have
- Email configuration details 