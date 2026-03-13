# Flutter Project Structure Overview

## Introduction

Understanding the Flutter project structure is fundamental to developing scalable, maintainable, and well-organized mobile applications. When you create a Flutter project using `flutter create project_name`, Flutter automatically generates a folder hierarchy that follows best practices for cross-platform development.

This document explores the purpose and role of each folder and file in a Flutter project, helping you understand how Flutter manages code, assets, and platform-specific configurations for both Android and iOS.

---

## Project Structure Hierarchy

```
S64-Mar26-Team01-FFDP/
│
├── lib/                          # 🎯 Core application code
│   ├── main.dart                 # App entry point
│   ├── concept_demo.dart         # Demo/test file
│   ├── firebase_options.dart     # Firebase configuration
│   │
│   ├── screens/                  # UI Screens
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── signup_screen.dart
│   │   └── home/
│   │       └── dashboard_screen.dart
│   │
│   ├── services/                 # Business logic & API calls
│   │   ├── auth_service.dart
│   │   ├── firestore_service.dart
│   │   └── storage_service.dart
│   │
│   ├── models/                   # Data models & entities
│   │   ├── user_model.dart
│   │   └── booking_model.dart
│   │
│   └── widgets/                  # Reusable UI components
│       ├── custom_text_field.dart
│       └── primary_button.dart
│
├── android/                      # 🔷 Android build configuration
│   ├── app/
│   │   ├── build.gradle          # Android build settings
│   │   └── src/                  # Android source code
│   └── gradle.properties         # Gradle configuration
│
├── ios/                          # 🍎 iOS build configuration
│   ├── Runner/
│   │   ├── Info.plist            # iOS app metadata
│   │   └── Assets.xcassets/      # iOS assets
│   └── Podfile                   # iOS dependencies
│
├── assets/                       # 📁 Static files (images, fonts, etc.)
│   ├── images/
│   ├── fonts/
│   └── json/
│
├── test/                         # 🧪 Automated tests
│   └── widget_test.dart          # Widget & integration tests
│
├── docs/                         # 📚 Project documentation
│   ├── setup_guide.md
│   ├── concept1/
│   ├── concept3/
│   └── PROJECT_STRUCTURE.md      # This file
│
├── build/                        # Auto-generated build artifacts
│   ├── android/
│   └── ios/
│
├── .dart_tool/                   # Dart tooling cache
├── .idea/                        # IDE configuration
├── pubspec.yaml                  # 📦 Dependency & asset configuration
├── pubspec.lock                  # Locked dependency versions
├── README.md                     # Project documentation
├── .gitignore                    # Git ignore patterns
└── .env (optional)               # Environment variables
```

---

## Detailed Folder & File Explanations

### 1. **lib/** — Core Application Code
**Purpose:** Contains all Dart code for your Flutter application.

| File/Folder | Purpose |
|---|---|
| `main.dart` | Entry point of the app. Contains `main()` function and `MyApp` widget. Initializes Firebase and sets up navigation. |
| `screens/` | Contains all screen/page widgets. Organized by feature (auth/, home/). |
| `services/` | Business logic layer. Handles API calls, database operations, and external service integrations. |
| `models/` | Data models and entity classes. Defines data structures for Firebase documents. |
| `widgets/` | Reusable UI components (buttons, text fields, cards, etc.). Promotes code reuse across screens. |
| `utils/` | Utility functions, constants, and helper methods. |
| `theme/` | Theme configuration, color palettes, and text styles. |

**Best Practice:**
- Keep `lib/` organized by feature or by layer (screens, services, models)
- Avoid putting all code in `main.dart` — use separate files and folders
- Reusable components should go in `widgets/`

---

### 2. **android/** — Android Build Configuration
**Purpose:** Contains all Android-specific configuration files for building APK/AAB for Android devices.

| File/Folder | Purpose |
|---|---|
| `android/app/build.gradle` | Defines app name, version, min/target SDK, and Android-specific dependencies |
| `android/app/src/main/AndroidManifest.xml` | Declares app permissions, activities, and app metadata |
| `android/app/src/main/res/` | Contains Android resources (drawable, layout, values) |
| `android/gradle.properties` | Gradle build properties and configurations |
| `android/settings.gradle` | Gradle settings for multi-module builds |

**Key Points:**
- Do NOT edit build.gradle manually unless necessary — use `pubspec.yaml` for dependencies
- Permissions must be declared in `AndroidManifest.xml`
- Android-specific code goes in Kotlin or Java under `src/`

---

### 3. **ios/** — iOS Build Configuration
**Purpose:** Contains all iOS-specific configuration files for building IPA for iPhone/iPad.

| File/Folder | Purpose |
|---|---|
| `ios/Runner/Info.plist` | iOS app metadata (permissions, display name, supported orientations) |
| `ios/Runner/Assets.xcassets/` | iOS assets (icons, images, launch screen) |
| `ios/Podfile` | iOS dependency manager (CocoaPods) — similar to `pubspec.yaml` |
| `ios/Runner.xcworkspace/` | Xcode workspace for building iOS apps |

**Key Points:**
- Info.plist must declare permissions and capabilities
- Use Xcode to modify iOS-specific settings visually
- iOS native code goes in Swift or Objective-C under `Runner/`

---

### 4. **assets/** — Static Resources
**Purpose:** Stores images, fonts, JSON files, and other static resources.

**Structure:**
```
assets/
├── images/
│   ├── logo.png
│   ├── background.jpg
│   └── icons/
├── fonts/
│   └── Roboto-Regular.ttf
└── json/
    └── config.json
```

**Usage in Code:**
```dart
// Reference in pubspec.yaml first:
flutter:
  assets:
    - assets/images/
    - assets/fonts/

// Then use in code:
Image.asset('assets/images/logo.png')
```

---

### 5. **test/** — Automated Tests
**Purpose:** Contains unit, widget, and integration tests.

| File Type | Purpose |
|---|---|
| `widget_test.dart` | Tests UI widgets (button clicks, rendering, etc.) |
| `unit_test.dart` | Tests business logic (services, models, functions) |
| `integration_test.dart` | Tests entire user flows end-to-end |

**Running Tests:**
```bash
flutter test                    # Run all tests
flutter test test/widget_test.dart  # Run specific test
flutter test --coverage         # Generate coverage report
```

---

### 6. **pubspec.yaml** — Dependency & Configuration Manager
**Purpose:** Central configuration file for the Flutter project. Similar to `package.json` in Node.js.

**Key Sections:**

```yaml
name: your_app
description: Your app description
version: 1.0.0+1

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
  cloud_firestore: ^5.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/fonts/
  fonts:
    - family: Roboto
      fonts:
        - asset: assets/fonts/Roboto-Regular.ttf
```

**Never modify:**
- `pubspec.lock` — auto-generated, commit to version control
- Manually edit `pubspec.yaml` for dependencies, then run `flutter pub get`

---

### 7. **build/** — Auto-Generated Build Artifacts
**Purpose:** Contains compiled app builds (APK, AAB, IPA).

- **Do NOT commit to Git** — add to `.gitignore`
- **Do NOT modify manually** — Flutter regenerates on build
- Remove with `flutter clean` if needed

---

### 8. **Supporting Files**

| File | Purpose |
|---|---|
| `.gitignore` | Lists files/folders Git should ignore (build/, .env, etc.) |
| `README.md` | Project documentation, setup instructions, usage guide |
| `.dart_tool/` | Dart analyzer cache — ignore in Git |
| `.idea/` | IDE configuration (Android Studio/IntelliJ) — ignore in Git |
| `.env` (optional) | Environment variables (API keys, secrets) — ignore in Git |

---

## Project Structure Best Practices

### ✅ Do's:
- **Organize by Feature:** Group related screens, services, and models together
  ```
  screens/
  ├── auth/
  │   ├── login_screen.dart
  │   └── signup_screen.dart
  └── home/
      └── dashboard_screen.dart
  ```

- **Separate Concerns:**
  - `screens/` → UI only
  - `services/` → Business logic
  - `models/` → Data structures
  - `widgets/` → Reusable components

- **Keep main.dart Minimal:** Use it only for initialization and routing

- **Document Public APIs:** Add comments to services and models

### ❌ Don'ts:
- Put all code in `main.dart`
- Mix business logic with UI code
- Create deeply nested folder structures (max 3-4 levels)
- Commit `build/`, `.dart_tool/`, or `.idea/` folders
- Store secrets in code — use `.env` file

---

## How This Structure Supports Scalability & Teamwork

### 📈 Scalability
1. **Easy Navigation:** Clear folder structure helps developers find code quickly
2. **Code Reuse:** Organized widgets and services prevent duplication
3. **Testing:** Separated business logic (services) makes unit testing easier
4. **Performance:** Modular structure allows lazy loading and optimization

### 👥 Team Collaboration
1. **Parallel Development:** Multiple team members can work on different features without conflicts
2. **Code Review:** Clear structure makes reviews faster and easier
3. **Onboarding:** New developers understand the project faster with organized code
4. **Consistency:** Shared structure guidelines reduce merge conflicts
5. **Responsibility:** Each folder has a clear owner/team

### 🔄 CI/CD Integration
- Tests in `test/` are automatically run by CI/CD pipelines
- Build scripts know where to find Android (`android/`) and iOS (`ios/`) configs
- Assets are properly declared in `pubspec.yaml`

---

## Folder Structure for Different App Types

### Social Media App
```
lib/
├── screens/
│   ├── auth/
│   ├── feed/
│   ├── profile/
│   └── messages/
├── services/
│   ├── auth_service.dart
│   ├── feed_service.dart
│   └── messaging_service.dart
└── models/
    ├── user_model.dart
    ├── post_model.dart
    └── message_model.dart
```

### E-Commerce App
```
lib/
├── screens/
│   ├── products/
│   ├── cart/
│   ├── checkout/
│   └── orders/
├── services/
│   ├── product_service.dart
│   ├── cart_service.dart
│   └── payment_service.dart
└── models/
    ├── product_model.dart
    ├── cart_model.dart
    └── order_model.dart
```

---

## Summary Checklist

- ✅ `lib/` is organized with `screens/`, `services/`, `models/`, `widgets/`
- ✅ `android/` and `ios/` folders contain platform-specific config
- ✅ `pubspec.yaml` manages all dependencies and assets
- ✅ `test/` contains automated tests
- ✅ `.gitignore` excludes build and cache files
- ✅ `docs/` contains project documentation
- ✅ README.md has setup and usage instructions
- ✅ Code is organized by feature or layer for easy navigation
- ✅ Reusable components are in `widgets/`
- ✅ Business logic is separated in `services/`

---

## Resources
- [Flutter Project Structure Guide](https://flutter.dev/docs/development/best-practices/project-structure)
- [Managing Assets in Flutter](https://flutter.dev/docs/development/ui/assets-and-images)
- [Understanding pubspec.yaml](https://dart.dev/tools/pub/pubspec)
- [Flutter Testing Guide](https://flutter.dev/docs/testing/overview)
- [Best Practices for Flutter Folder Organization](https://flutter.dev/docs/development/best-practices)

---

**Last Updated:** March 13, 2024
**Author:** Team01 - S64 Sprint 2
**Status:** ✅ Complete
