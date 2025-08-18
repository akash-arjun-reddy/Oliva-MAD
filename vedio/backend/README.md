# Jitsi Meet Link Generator - Backend

A FastAPI backend with clean architecture for generating unique Jitsi Meet links.

## 🏗️ Architecture

```
backend/
├── app/
│   ├── config/
│   │   ├── __init__.py
│   │   └── settings.py          # Application settings and configuration
│   ├── controllers/
│   │   ├── __init__.py
│   │   └── meeting_controller.py # API endpoints and request handling
│   ├── dto/
│   │   ├── __init__.py
│   │   ├── meeting_dto.py       # Data Transfer Objects
│   │   └── mappers.py          # DTO to Domain model mappers
│   ├── database/
│   │   ├── __init__.py
│   │   └── connection.py        # Database connection (for future use)
│   ├── models/
│   │   ├── __init__.py
│   │   └── meeting.py          # Domain models and schemas
│   ├── repositories/
│   │   ├── __init__.py
│   │   └── meeting_repository.py # Data access layer
│   ├── services/
│   │   ├── __init__.py
│   │   ├── meeting_service.py  # Business logic for meetings
│   │   └── email_service.py    # Email functionality
│   ├── utils/
│   │   ├── __init__.py
│   │   └── validators.py       # Input validation utilities
│   └── __init__.py
├── main.py                     # Application entry point
├── requirements.txt            # Python dependencies
└── README.md                  # This file
```

## 🎯 Features

- **Clean Architecture**: Proper separation of concerns with DTOs, repositories, and services
- **Configuration Management**: Centralized settings with environment variables
- **Input Validation**: Comprehensive validation for all inputs with detailed error messages
- **Error Handling**: Proper error responses and logging with structured DTOs
- **Email Integration**: Optional SMTP email functionality
- **API Documentation**: Auto-generated with FastAPI and detailed examples
- **CORS Support**: Cross-origin resource sharing enabled
- **Dependency Injection**: Proper service and repository injection
- **Repository Pattern**: Abstract data access layer for future database integration

## 🚀 Setup

1. **Install dependencies:**
```bash
pip install -r requirements.txt
```

2. **Configure environment (optional):**
```bash
cp env_example.txt .env
# Edit .env with your email settings
```

3. **Run the server:**
```bash
python main.py
```

## 📋 API Endpoints

### Health Check
- **GET /** - Application health check

### Meeting Management
- **POST /api/v1/generate-link** - Generate Jitsi Meet link
- **POST /api/v1/send-email** - Generate link and send emails
- **GET /api/v1/meetings/{meeting_id}** - Get meeting by ID

## 🔧 Configuration

### Environment Variables
```bash
# App Settings
DEBUG=false
HOST=127.0.0.1
PORT=8002

# Email Settings (Optional)
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
SENDER_EMAIL=your-email@gmail.com
SENDER_PASSWORD=your-app-password

# Jitsi Meet Settings
JITSI_BASE_URL=https://meet.jit.si
JITSI_CONFIG_PARAMS=config.prejoinPageEnabled=false&config.disableDeepLinking=true
```

## 🏛️ Architecture Layers

### **Controllers** (`app/controllers/`)
- Handle HTTP requests and responses
- Input validation and error handling
- Route requests to appropriate services
- Dependency injection for services

### **DTOs** (`app/dto/`)
- Data Transfer Objects for API layer
- Input validation with detailed error messages
- Response schemas with examples
- Mappers for converting between DTOs and domain models

### **Services** (`app/services/`)
- Business logic implementation
- Meeting generation and management
- Email sending functionality
- Repository pattern integration

### **Repositories** (`app/repositories/`)
- Abstract data access layer
- In-memory implementation for development
- Future database integration ready
- CRUD operations for meetings

### **Models** (`app/models/`)
- Domain models and entities
- Pydantic schemas for internal use
- Type safety and validation

### **Utils** (`app/utils/`)
- Reusable utility functions
- Input validation helpers
- Common functionality

### **Config** (`app/config/`)
- Application settings management
- Environment variable handling
- Configuration validation

### **Database** (`app/database/`)
- Database connection management
- ORM setup (for future use)
- Migration handling

## 🔄 Request Flow

1. **Request** → Controller
2. **Controller** → Validates input using DTOs
3. **Controller** → Maps DTO to Domain model
4. **Controller** → Calls appropriate Service
5. **Service** → Uses Repository for data access
6. **Service** → Implements business logic
7. **Service** → Returns result to Controller
8. **Controller** → Maps Domain model to Response DTO
9. **Controller** → Returns HTTP response

## 📚 API Documentation

Visit `http://localhost:8002/docs` for interactive API documentation with:
- Detailed request/response schemas
- Example values for all fields
- Error response documentation
- Try-it-out functionality

## 🧪 Testing

```bash
# Run tests (when implemented)
pytest

# Run with coverage
pytest --cov=app
```

## 🔮 Future Enhancements

- **Database Integration**: PostgreSQL/MySQL with SQLAlchemy
- **Authentication**: JWT-based user management
- **Rate Limiting**: API usage limits with Redis
- **Logging**: Structured logging with correlation IDs
- **Monitoring**: Health checks, metrics, and alerting
- **Caching**: Redis integration for performance
- **Background Jobs**: Celery for async email processing
- **API Versioning**: Proper versioning strategy 