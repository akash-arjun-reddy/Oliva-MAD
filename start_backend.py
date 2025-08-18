#!/usr/bin/env python3
"""
Script to start the backend with required environment variables
This will set the minimum required variables to make your backend work
"""

import os
import subprocess
import sys

def set_environment_variables():
    """Set the required environment variables"""
    # Database configuration - using your original working credentials
    os.environ["DB_HOST"] = "localhost"
    os.environ["DB_PORT"] = "5432"
    os.environ["DB_USER"] = "mobileapp"  # Your original username
    os.environ["DB_PASSWORD"] = "123"    # Your original password
    os.environ["DB_NAME"] = "mad_database"
    os.environ["DATABASE_URL"] = "postgresql+psycopg2://mobileapp:123@localhost:5432/mad_database"
    
    # Zenoti database (using same as main for now)
    os.environ["ZENOTI_DATABASE_URL"] = "postgresql+psycopg2://mobileapp:123@localhost:5432/mad_database"
    
    # Application secrets
    os.environ["SECRET_KEY"] = "your-secret-key-here-change-this-in-production"
    os.environ["ALGORITHM"] = "HS256"
    os.environ["ACCESS_TOKEN_EXPIRE_MINUTES"] = "30"
    
    # Optional settings (can be empty)
    os.environ["AZURE_TENANT_ID"] = ""
    os.environ["AZURE_CLIENT_ID"] = ""
    os.environ["AZURE_CLIENT_SECRET"] = ""
    os.environ["AZURE_SCOPE"] = ""
    os.environ["AZURE_MAIL_USER"] = ""
    os.environ["GOOGLE_CLIENT_ID"] = ""
    os.environ["GOOGLE_CLIENT_SECRET"] = ""
    os.environ["ZENOTI_USERNAME"] = ""
    os.environ["ZENOTI_PASSWORD"] = ""
    os.environ["ZENOTI_ACCOUNT_NAME"] = ""
    os.environ["ZENOTI_APP_VERSION"] = ""
    os.environ["ZENOTI_METHOD_NAME"] = ""
    os.environ["ZENOTI_API_URL"] = ""
    os.environ["ZENOTI_API_KEY"] = ""
    os.environ["ZENOTI_BASE_URL"] = ""
    os.environ["MAX_DATE_RANGE_DAYS"] = "7"
    os.environ["DB_ECHO"] = "True"  # Set to True as it was in your working logs

def main():
    print("🔧 Setting up environment variables...")
    set_environment_variables()
    
    print("🚀 Starting backend server...")
    print("📍 Server will be accessible at: http://0.0.0.0:8000")
    print("🔧 Health check: http://YOUR_IP:8000/health")
    
    # Change to the backend directory
    backend_dir = "BackendMobileAPP/BackendMobileAPP"
    
    try:
        # Start the main backend
        subprocess.run([sys.executable, "main.py"], cwd=backend_dir, check=True)
    except subprocess.CalledProcessError as e:
        print(f"❌ Error starting backend: {e}")
        print("💡 If you have database issues, you can use the simplified version:")
        print("   python main_simple.py")
    except KeyboardInterrupt:
        print("\n🛑 Backend stopped by user")

if __name__ == "__main__":
    main() 