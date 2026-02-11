# Firebase Realtime Database – users not showing

The app writes new users to **Realtime Database** under the path: **`/users/<pushId>`**

Each child has: `name`, `email`, `password`, `createdAt`.

## 1. Check the database

- In Firebase Console go to **Build → Realtime Database**.
- Confirm you are in project **cropdiseasedetector-86405** and database **https://cropdiseasedetector-86405-default-rtdb.firebaseio.com** (same as in `android/app/google-services.json`).
- Under the root you should see a **`users`** node. New app registrations create keys like **`-Mxxxx...`** or **`-Nxxxx...`** (push IDs). Keys like `0OPX3bs7w6c3fSK7SQpVCz9vMgk1` are from Firebase Auth / another system.

## 2. Allow writes to `users`

If new users from the app never appear, the write is likely blocked by **Realtime Database rules**.

In Firebase Console → **Realtime Database** → **Rules**, use one of the following.

**Option A – allow read/write to `users` (for development):**

```json
{
  "rules": {
    "users": {
      ".read": true,
      ".write": true
    }
  }
}
```

**Option B – keep rest of DB locked, only open `users`:**

```json
{
  "rules": {
    "users": {
      ".read": true,
      ".write": true
    },
    ".read": false,
    ".write": false
  }
}
```

**Important for login:** Add an **index on `email`** so the app can look up users by email. Without it, login will fail with "Invalid email or password".

```json
{
  "rules": {
    "users": {
      ".read": true,
      ".write": true,
      ".indexOn": ["email"]
    }
  }
}
```

Publish the rules, then try registering and logging in again.

## 3. Use app logs

When you register, check the **debug console** (e.g. `flutter run` or Android Studio):

- **`[AuthService] Realtime DB path: users`** – path we use.
- **`[AuthService] register() writing to Firebase path: /users/-Mxxxx...`** or **`_trySyncUserToFirebase() OK: user written to /users/-Mxxxx...`** – write succeeded.
- **`_trySyncUserToFirebase() FAILED: ...`** – write failed; the message (e.g. `permission_denied`) explains why.

After fixing rules, new users should appear under **Realtime Database → users** with push-style keys and fields `name`, `email`, `password`, `createdAt`.
