# Admin setup (Firebase only)

There is **no built-in default admin**. The only way to get admin access is to have a user in Firebase with **`isAdmin: true`**.

## Create your one admin

### Option 1 – Run the script (recommended)

1. Get a **service account key** from Firebase Console: Project settings → Service accounts → **Generate new private key**. Save the JSON file.
2. Put it in the project as **`scripts/serviceAccountKey.json`** (this path is in `.gitignore`; do not commit it).
3. In a terminal:
   ```bash
   cd scripts
   npm install
   node create_admin.js --email admin@yourdomain.com --password YourPassword123
   ```
4. Log in to the app with that email and password. You will have admin access.

See **`scripts/README.md`** for more options (e.g. custom name, different key path).

### Option 2 – Create the user in Firebase Console

1. Open **Firebase Console** → your project → **Realtime Database** → **Data**.
2. Go to the **`users`** node.
3. Click **+** to add a child. Choose **Push** (or add under `users`).
4. Set these fields (use your own email and password):

   | Key        | Value (example)        |
   |-----------|-------------------------|
   | `name`    | `Admin`                 |
   | `email`   | `admin@yourdomain.com`  |
   | `password`| `YourSecurePassword123` |
   | `createdAt` | `2025-01-01T00:00:00.000Z` (any ISO date) |
   | **`isAdmin`** | **`true`**          |

5. Save. That user can now log in in the app with that email and password and will see **Settings → Admin** and can view all users and their analyses.

### Option 3 – Register in the app, then make admin in Firebase

1. In the app, tap **Register** and create an account (email + password + name).
2. In **Firebase Console** → **Realtime Database** → **`users`**, find the new user (by email).
3. Edit that user and add a field: **`isAdmin`** = **`true`**.
4. Log out in the app (if needed) and log in again with that account. You will have admin access.

---

Only users with **`isAdmin: true`** in Firebase see the Admin section in Settings. Everyone else is a normal user.
