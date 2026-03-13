# NanheNest Development Environment Setup Guide

This guide provides step-by-step instructions for setting up the development environment for the **NanheNest** mobile application. NanheNest is a social community platform built using Flutter and Firebase.

Building and running the application requires the following core components:
- **Language**: Dart 3.x
- **Framework**: Flutter 3.x
- **IDE**: Android Studio / VS Code
- **Backend**: Firebase (Auth, Firestore, Storage, Functions)

---

## 📋 Prerequisites

Before starting, ensure your system meets the minimum requirements:
- **Operating System**: macOS (latest stable) or Windows 10/11.
- **Disk Space**: At least 10 GB of free space.
- **Hardware**: Minimum 8GB RAM (16GB recommended for running emulators smoothly).
- **Accounts**: A Google account for Firebase and Google Maps Platform access.

---

## 1. Flutter SDK Installation

### macOS Installation
1. Download the latest stable Flutter SDK from the [official Flutter website](https://docs.flutter.dev/get-started/install/macos).
2. Extract the zip file to a permanent location (e.g., `~/development`).
3. Add the `flutter` tool to your path:
   ```bash
   # Add to your .zshrc or .bash_profile
   export PATH="$PATH:[PATH_TO_FLUTTER_GIT_DIRECTORY]/flutter/bin"
   ```
4. Update your path for the current session: `source ~/.zshrc` (or `.bash_profile`).

### Windows Installation
1. Download the Flutter SDK from the [official Flutter website](https://docs.flutter.dev/get-started/install/windows).
2. Extract the zip file (e.g., to `C:\src\flutter`).
   > [!WARNING]
   > Do not install Flutter in a directory that contains spaces or requires elevated privileges (like `C:\Program Files\`).
3. Add `C:\src\flutter\bin` to the **Path** environment variable for your user account.
4. Open a new Command Prompt or PowerShell window to apply the changes.

### Verifying Installation
Run the following command to check if there are any missing dependencies:
```bash
flutter doctor
```
Follow the instructions in the output to resolve any issues (e.g., installing Xcode for iOS development or Android SDK for Android).

---

## 2. Android Studio Setup

Android Studio provides the necessary Android SDK and tools to build and run the app on Android.

1. **Install Android Studio**: Download and install from [developer.android.com/studio](https://developer.android.com/studio).
2. **Launch Setup Wizard**: Follow the "Android Studio Setup Wizard" to install the SDK, platform-tools, and build-tools.
3. **Install Plugins**:
   - Open Android Studio.
   - Go to **Settings** (Windows) or **Settings/Preferences** (macOS).
   - Select **Plugins**, search for **Flutter**, and click **Install**.
   - This will also prompt you to install the **Dart** plugin. Click **Yes**.
4. **Restart Android Studio** to activate the plugins.

---

## 3. Android Emulator Configuration

To test the application without a physical device, you need to set up an Android Virtual Device (AVD).

1. **Open Device Manager**: In Android Studio, click on **Tools > Device Manager**.
2. **Create Device**: Click **Create Device**.
3. **Select Hardware**: Choose a phone model (e.g., **Pixel 6** or **Pixel 7**).
4. **Select System Image**:
   - Choose a recommended version (e.g., **Android 11.0 (R)** or **Android 13.0 (Tiramisu)**).
   - Download the image if it’s not already present.
5. **Finalize Configuration**:
   - Give it a name (e.g., `NanheNest_Emulator`).
   - Under **Graphics**, select **Hardware - GLES 2.0** for better performance.
6. **Launch**: Click the **Play** button next to your new device in the Device Manager.

---

## 4. Running Flutter Apps on Emulator

Once the emulator is running, you can connect it to your development environment.

### Connection Verification
Check if the emulator is detected by Flutter:
```bash
flutter devices
```
You should see your emulator listed in the output.

### Running the App
1. Navigate to the project root:
   ```bash
   cd NanheNest
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```
   If you have multiple devices, use `flutter run -d [DEVICE_ID]`.

---

## 5. Environment Verification Checklist

Use this checklist to confirm your environment is ready:
- [ ] `flutter --version` returns **3.x**.
- [ ] `dart --version` returns **3.x**.
- [ ] `flutter doctor` shows no critical errors for Android development.
- [ ] Android Studio has **Flutter** and **Dart** plugins installed.
- [ ] An Android Emulator is created and launches successfully.
- [ ] `flutter devices` lists the running emulator.
- [ ] `flutter run` successfully builds and launches the app on the emulator.

---

## 6. CI Environment Configuration

For automated builds (e.g., via GitHub Actions), the CI environment must be configured as follows:

- **Runner**: Ubuntu or macOS.
- **Flutter Version**: Use `subosito/flutter-action@v2` with `channel: 'stable'` and specified version (3.x).
- **Android SDK**: Ensure `platforms;android-33` (or latest used) and `build-tools` are installed.
- **Java**: JDK 11 or 17 is required for modern Android builds.
- **Secrets**: Add Firebase configuration files (`google-services.json`, `GoogleService-Info.plist`) as base64-encoded secrets if needed during the build process.

---

> [!TIP]
> **Troubleshooting**: If you encounter issues with the Android SDK location, you can manually set it using:
> `flutter config --android-sdk [PATH_TO_SDK]`
