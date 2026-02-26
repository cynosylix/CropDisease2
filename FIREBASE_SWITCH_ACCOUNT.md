# Switch Firebase Account

Your app currently uses a Firebase project you don’t have access to. To use **your own Firebase account**, do the following and then we can plug the files into the project.

---

## What the app uses

- **Android package name:** `com.example.cropdiseasedetector`
- **Firebase Realtime Database** (login, analysis history)
- **Firebase Storage** (if you upload/store images)
- **Firebase Auth** (email/password login) – enabled via the same project

---

## What you need to do (in your new Firebase account)

### 1. Create a new Firebase project (or use an existing one)

- Go to [Firebase Console](https://console.firebase.google.com/)
- Sign in with the Google account you want to use
- Create a new project (or pick one you already have)

### 2. Add an Android app to that project

- In the project, click **“Add app”** → **Android**
- **Android package name:** use exactly  
  `com.example.cropdiseasedetector`  
  (so the app keeps working without code changes)
- Register the app (you can skip “Download google-services.json” for now if you prefer to add it later)

### 3. Enable Firebase services

- **Authentication** → Sign-in method → enable **Email/Password**
- **Realtime Database** → Create database (choose a region, start in test mode if needed; we can lock rules later)
- **Storage** → Get started (use default rules for now if you want)

### 4. Download the config file

- In Firebase Console: **Project settings** (gear) → under “Your apps” select the Android app
- **Download `google-services.json`**

---

## What to send / add to the project

- **File:** `google-services.json` (the one you downloaded from your new project)

Place it in the project at:

- **Path:** `android/app/google-services.json`  
  (overwrite the existing file)

That’s the only file the app needs to switch to your Firebase account. There are no Firebase project IDs or URLs hardcoded in the Dart code; everything is read from this file.

---

## Optional: iOS

If you build for iOS later, in the same Firebase project add an **iOS app** with your iOS bundle ID, download **`GoogleService-Info.plist`**, and put it in `ios/Runner/`. We can add that when you’re ready.

---

## Summary

| What you need to provide | Where it goes |
|--------------------------|----------------|
| `google-services.json` from your new Firebase project (Android app with package `com.example.cropdiseasedetector`) | `android/app/google-services.json` |

After you have the file, you can either:

- Replace `android/app/google-services.json` yourself and run the app, or  
- Tell me when the file is in place (or paste its **project_id** and **package_name** if you prefer not to share the full file), and I can confirm the setup or adjust anything else (e.g. Realtime Database / Storage rules).
