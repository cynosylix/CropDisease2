# Create admin user (one-time)

This script adds an admin user to your Firebase Realtime Database so that user can open **Settings → Admin** in the app.

## 1. Get a service account key

1. Open [Firebase Console](https://console.firebase.google.com/) → your project.
2. Click the gear icon → **Project settings**.
3. Go to **Service accounts**.
4. Click **Generate new private key** → save the JSON file.
5. Move the file into this folder and rename it to **`serviceAccountKey.json`**  
   (or put it somewhere else and pass `--key path/to/file.json`).

**Important:** Do not commit `serviceAccountKey.json` to git. Add it to `.gitignore`.

## 2. Install and run

In a terminal, from the **`scripts`** folder:

```bash
cd scripts
npm install
node create_admin.js --email admin@yourdomain.com --password YourSecurePassword123
```

Use your own email and password (min 6 characters). The app stores the password in the database; this user will log in with the same email and password in the app.

Optional:

- `--name "Admin"` – display name (default: `Admin`).
- `--key path/to/serviceAccountKey.json` – path to the key file.
- `--database-url https://YOUR_PROJECT-default-rtdb.firebaseio.com` – if your Realtime Database URL is different.

## 3. Log in to the app

Open the app, go to **Login**, and sign in with the email and password you used above. You will see **Settings → Admin** and can view all users and their analyses.

---

If the user already exists (same email), the script only sets **`isAdmin: true`** on that user instead of creating a new one.
