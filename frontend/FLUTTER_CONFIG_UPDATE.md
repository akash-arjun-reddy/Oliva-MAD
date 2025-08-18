# 📱 Flutter App Configuration Update

After deploying your backend to Fly.io, you need to update your Flutter app to use the new API endpoints.

## 🔧 Step 1: Update API Base URL

### Find your API configuration file:
Look for files like:
- `lib/config/env.dart`
- `lib/data/network/api_client.dart`
- `lib/services/api_service.dart`

### Update the base URL:
```dart
// Change from localhost to your Fly.io app URL
const String baseUrl = 'https://oliva-clinic-backend.fly.dev';
```

## 🔧 Step 2: Update API Routes (if needed)

If you have hardcoded localhost URLs, update them:

```dart
// Before
const String apiUrl = 'http://localhost:8000';

// After
const String apiUrl = 'https://oliva-clinic-backend.fly.dev';
```

## 🔧 Step 3: Test API Connection

Add a test function to verify the connection:

```dart
Future<bool> testApiConnection() async {
  try {
    final response = await http.get(
      Uri.parse('https://oliva-clinic-backend.fly.dev/health'),
    );
    return response.statusCode == 200;
  } catch (e) {
    print('API connection failed: $e');
    return false;
  }
}
```

## 🔧 Step 4: Update CORS Settings (if needed)

If you encounter CORS issues, the backend is already configured to allow all origins. If you want to restrict it:

1. Update the backend CORS configuration in `main.py`:
```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://your-flutter-app.com"],  # Replace with your domain
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

2. Redeploy the backend:
```bash
flyctl deploy
```

## 🔧 Step 5: Environment-Specific Configuration

Create environment-specific configurations:

```dart
// lib/config/env.dart
class Environment {
  static const String devBaseUrl = 'http://localhost:8000';
  static const String prodBaseUrl = 'https://oliva-clinic-backend.fly.dev';
  
  static String get baseUrl {
    // Use build configuration or environment variable
    const bool isProduction = bool.fromEnvironment('dart.vm.product');
    return isProduction ? prodBaseUrl : devBaseUrl;
  }
}
```

## 🔧 Step 6: Test Your App

1. **Test API endpoints:**
   - Health check: `https://oliva-clinic-backend.fly.dev/health`
   - API docs: `https://oliva-clinic-backend.fly.dev/docs`

2. **Test from Flutter app:**
   - Run your Flutter app
   - Try logging in/registering
   - Test all API calls

## 🆘 Troubleshooting

### Common Issues:

1. **Connection Timeout**
   - Check if the backend is running: `flyctl status`
   - Verify the URL is correct
   - Check network connectivity

2. **CORS Errors**
   - The backend allows all origins by default
   - If issues persist, check browser console for specific errors

3. **Authentication Issues**
   - Verify SECRET_KEY is set in Fly.io secrets
   - Check JWT token generation/validation

### Debug Commands:
```bash
# Check backend logs
flyctl logs

# Check backend status
flyctl status

# Restart backend if needed
flyctl restart
```

## ✅ Success Checklist

- [ ] API base URL updated
- [ ] All API calls working
- [ ] Authentication working
- [ ] No CORS errors
- [ ] App functions normally
- [ ] Database operations working

## 🎉 You're Ready!

Your Flutter app is now connected to your deployed backend on Fly.io with PostgreSQL on Neon.tech! 