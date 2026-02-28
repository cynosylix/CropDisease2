# Firebase Storage – enable image storage (optional)

For analysis **images** to be stored and shown in **History**, Firebase Storage must be enabled. **The app works without Storage**: analyses are still saved (label, confidence, date) in Realtime Database; only image thumbnails in History are missing.

## Requirements

- **Firebase Auth** is already integrated. On login/register, the app signs in with Firebase Auth so Storage requests have `request.auth`.
- Storage path: `users/{auth.uid}/analyses/`. Rules must use `request.auth.uid == userId`.

## Storage may require Blaze plan

Firebase may show: **"To use Storage, upgrade your project's pricing plan"**. Storage can require the **Blaze (pay-as-you-go)** plan depending on your project/region.

- **If you don’t upgrade:** Keep using the app as-is. History will list all analyses with label, confidence, and date; thumbnails will be empty.
- **If you upgrade to Blaze:** You can enable Storage and get image thumbnails in History (steps below). Blaze has a free tier; you only pay if you exceed it.

## 1. Enable Storage (only if your project has Blaze / Storage enabled)

1. Open [Firebase Console](https://console.firebase.google.com) and select **your project** (e.g. `cropleafdisease` from `google-services.json`).
2. Go to **Build** → **Storage**.
3. If you see "upgrade your project's pricing plan", you need to upgrade to **Blaze** in **Project settings** → **Usage and billing** (or skip Storage and use the app without image storage).
4. Click **Get started**, choose **Start in production mode** (we’ll set rules next) or **Start in test mode** for testing.
5. Pick a location and click **Done**. Your bucket will be e.g. `cropleafdisease.firebasestorage.app` (see `google-services.json`).

## 2. Set Security Rules

1. In **Storage** → **Rules**.
2. Use rules that allow **authenticated users** to read/write only their own folder (`userId` = `auth.uid`):

```text
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

3. Click **Publish**.

## 3. Enable Authentication (if needed)

Storage rules require `request.auth != null`. The app uses **Firebase Auth (Email/Password)**. In Firebase Console:

1. Go to **Build** → **Authentication**.
2. Click **Get started**.
3. Under **Sign-in method**, enable **Email/Password**.

The app signs in on login/register, so existing Realtime DB users will be migrated to Firebase Auth on their next login.

## 4. Test in the app

Run the app, log in, analyze a leaf image. You should see in the terminal:

- `[AnalysisRepository] Image uploaded: https://...`  
  and History should show the image thumbnail.

If you still see **Image upload failed** or **404**, check:

- Your project in Console matches `google-services.json` (e.g. `cropleafdisease`).
- Storage is **enabled** (Build → Storage shows a bucket).
- **Authentication** is enabled (Email/Password).
- **Rules** are published and allow `users/{userId}/analyses/` where `userId == auth.uid`.
