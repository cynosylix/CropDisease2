# Firebase Storage – enable image storage (optional)

For analysis **images** to be stored and shown in **History**, Firebase Storage must be enabled. **The app works without Storage**: analyses are still saved (label, confidence, date) in Realtime Database; only image thumbnails in History are missing.

## Storage may require Blaze plan

Firebase may show: **"To use Storage, upgrade your project's pricing plan"**. Storage can require the **Blaze (pay-as-you-go)** plan depending on your project/region.

- **If you don’t upgrade:** Keep using the app as-is. History will list all analyses with label, confidence, and date; thumbnails will be empty.
- **If you upgrade to Blaze:** You can enable Storage and get image thumbnails in History (steps below). Blaze has a free tier; you only pay if you exceed it.

## 1. Enable Storage (only if your project has Blaze / Storage enabled)

1. Open [Firebase Console](https://console.firebase.google.com) and select project **cropdiseasedetector-86405**.
2. Go to **Build** → **Storage**.
3. If you see "upgrade your project's pricing plan", you need to upgrade to **Blaze** in **Project settings** → **Usage and billing** (or skip Storage and use the app without image storage).
4. Click **Get started**, choose **Start in production mode** (we’ll set rules next) or **Start in test mode** for testing.
5. Pick a location and click **Done**. Your bucket will be `cropdiseasedetector-86405.firebasestorage.app` (already in `google-services.json`).

## 2. Set Security Rules

1. In **Storage** → **Rules**.
2. Use rules that allow **authenticated users** to read/write only their own folder:

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

## 3. Test in the app

Run the app, log in, analyze a leaf image. You should see in the terminal:

- `[AnalysisRepository] Image uploaded: https://...`  
  and History should show the image thumbnail.

If you still see **Image upload failed** or **404**, check:

- The project in Console is **cropdiseasedetector-86405**.
- Storage is **enabled** (Build → Storage shows a bucket).
- **Rules** are published and allow `users/{userId}/analyses/` for the signed-in user.
