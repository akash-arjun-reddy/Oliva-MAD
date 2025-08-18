# Flutter Project Architecture Guide

This project follows a scalable, modular, and uniform architecture for maintainability, team collaboration, and future growth.

---

## 📁 Folder Structure Overview

```
lib/
├── config/           # Global configuration (env, theme)
├── core/             # App-wide constants, utils, and reusable widgets
├── data/             # Global network logic (API client, routes)
├── features/
│   ├── authentication/
│   ├── clinic/
│   ├── dashboard/
│   ├── doctor/
│   ├── shop/
│   └── skin_issues/
│       ├── presentation/
│       │   ├── pages/      # Page widgets (screens/routes)
│       │   └── widgets/    # Reusable UI components for this feature
│       ├── bloc/           # State management logic (Bloc/Cubit)
│       ├── services/       # Business logic, API calls, integration
│       └── data/           # Models, repositories, datasources
├── presentation/      # Global app UI (entry, splash, routes)
└── services/          # Global services (API, Auth, Analytics)
```

---

## 📦 Folder Purpose

- **config/**: App-wide configuration (e.g., `env.dart`, `theme.dart`).
- **core/**: Global constants, utility functions, and reusable widgets used across features.
- **data/**: Global network logic (API client, routes, interceptors).
- **features/**: Each feature is self-contained and follows the same modular structure:
  - **presentation/pages/**: Page widgets (screens/routes) for the feature.
  - **presentation/widgets/**: Reusable UI components for the feature.
  - **bloc/**: State management logic (Bloc/Cubit) for the feature.
  - **services/**: Business logic, API calls, and integration for the feature.
  - **data/**: Models, repositories, and datasources for the feature.
- **presentation/**: Global app UI, entry point, splash screen, and route management.
- **services/**: Global services (API, Auth, Analytics, etc.).

---

## 🏗️ Best Practices

- **Keep pages focused on UI and navigation.**
- **Extract reusable UI into `widgets/`.**
- **Move business logic and API calls to `services/`.**
- **Place models and repositories in `data/`.**
- **Use `bloc/` for state management logic if needed.**
- **Only create folders when needed—remove empty folders if not used.**
- **Follow consistent naming:**
  - Pages: `*_page.dart`
  - Widgets: `*_widget.dart`
  - Blocs: `*_bloc.dart` or `*_cubit.dart`
  - Services: `*_service.dart`
  - Models: `*_model.dart`

---

## 🚀 Example Feature Structure

```
features/clinic/
├── presentation/
│   ├── pages/
│   │   └── booking_success_page.dart
│   └── widgets/
│       └── clinic_card_widget.dart
├── bloc/
│   └── clinic_bloc.dart
├── services/
│   └── clinic_api_service.dart
└── data/
    └── clinic_model.dart
```

---

## 📈 Why This Structure?
- **Scalable:** Easy to add new features or expand existing ones.
- **Maintainable:** Clear separation of concerns and responsibilities.
- **Team-friendly:** Multiple developers can work on different features without conflicts.
- **Testable:** Smaller, focused files and folders make testing easier.

---

**Stick to this structure for all features and your project will remain clean, modular, and ready for growth!**
