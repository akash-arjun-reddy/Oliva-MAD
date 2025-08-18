# Clinic Feature Structure

This feature follows a scalable, uniform architecture for maintainability and team collaboration.

## Folder Structure

```
clinic/
├── presentation/
│   ├── pages/        # Page widgets (screens/routes)
│   └── widgets/      # Reusable UI components for this feature
├── bloc/             # State management logic (Bloc/Cubit)
├── services/         # Business logic, API calls, integration
├── data/             # Models, repositories, datasources
```

## Folder Purpose

- **presentation/pages/**: Contains all screen widgets for the clinic feature. Each file here represents a full page or route.
- **presentation/widgets/**: Contains reusable UI components used only within the clinic feature (e.g., cards, banners).
- **bloc/**: Contains Bloc or Cubit files for state management (if used).
- **services/**: Contains business logic, API calls, and integration code specific to the clinic feature.
- **data/**: Contains models, repositories, and datasources for the clinic feature.

## Best Practices
- Keep page files focused on UI and navigation.
- Extract reusable UI into `widgets/`.
- Move business logic and API calls to `services/`.
- Place models and repositories in `data/`.
- Use `bloc/` for state management logic if needed.
- Only create folders when needed—remove empty folders if not used.

## Example Usage
- If you add a new screen, place it in `presentation/pages/`.
- If you create a new card or button used in multiple places, put it in `presentation/widgets/`.
- If you add a new API call, put the logic in `services/`.
- If you define a new data model, put it in `data/`.

---

**This structure ensures your feature is modular, maintainable, and ready for team scaling!** 