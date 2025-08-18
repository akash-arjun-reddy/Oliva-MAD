# 🏥 Oliva Clinic Mobile App

A comprehensive mobile application for Oliva Clinic with Python FastAPI backend and Flutter frontend.

## 🚀 Quick Start

### Prerequisites
- Python 3.8+
- Flutter SDK
- GitHub CLI (recommended for team collaboration)

### Team Setup (2-5 people)

#### 1. Install GitHub CLI
**Windows:**
```bash
winget install GitHub.cli
```

**Mac:**
```bash
brew install gh
```

**Linux:**
```bash
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh
```

#### 2. Authenticate with GitHub
```bash
gh auth login
```
Follow the prompts to authenticate.

#### 3. Clone and Work
```bash
git clone https://github.com/akash-arjun-reddy/Oliva-MAD.git
cd Oliva-MAD
```

## 🏗️ Project Structure

```
MAD/
├── BackendMobileAPP/          # Python FastAPI Backend
│   ├── main.py               # FastAPI application
│   ├── controller/           # API controllers
│   ├── models/              # Database models
│   ├── service/             # Business logic
│   └── requirements.txt     # Python dependencies
├── frontend/                # Flutter Mobile App
│   ├── lib/                # Dart source code
│   ├── android/            # Android specific files
│   ├── ios/               # iOS specific files
│   └── pubspec.yaml       # Flutter dependencies
└── SETUP.md               # Complete setup guide
```

## 🔧 Development

### Backend Development
```bash
cd BackendMobileAPP
pip install -r requirements.txt
python main.py
```
Backend will be available at: http://localhost:8000

### Frontend Development
```bash
cd frontend
flutter pub get
flutter run
```

### Build APK
```bash
cd frontend
# Windows
build_apk.bat
# Mac/Linux
./build_apk.sh
```

## 📱 Features

- **Authentication**: User login/registration
- **Appointments**: Book and manage appointments
- **Services**: Browse clinic services
- **Dashboard**: User dashboard with calendar
- **Shop**: Product catalog and ordering
- **Skin Issues**: Skin concern assessment

## 🚀 Deployment

See `SETUP.md` for complete deployment instructions including:
- Automatic backend deployment to Render
- Automatic frontend deployment
- Automatic APK generation
- GitHub Actions CI/CD

## 👥 Team Collaboration

### Making Changes
1. Create a new branch: `git checkout -b feature/your-feature`
2. Make your changes
3. Commit: `git commit -m "Add your feature"`
4. Push: `git push origin feature/your-feature`
5. Create Pull Request on GitHub

### Code Review
- All changes go through Pull Requests
- Team members review and approve changes
- Merge to main branch after approval

## 📞 Support

For questions or issues:
- Check `SETUP.md` for detailed setup instructions
- Check `DEPLOYMENT.md` for deployment troubleshooting
- Create an issue on GitHub for bugs or feature requests

---

**Built with ❤️ for Oliva Clinic** 