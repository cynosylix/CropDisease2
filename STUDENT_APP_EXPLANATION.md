# Crop Disease Detector

## What it does
- Take or pick a leaf photo → app sends it to a **Python server** → shows **disease name**, **confidence %**, and **tips** (symptoms, treatment, prevention).
- **History** tab shows past results. **Settings**: language, server URL, logout.

## Project overall working

1. **Flutter app (phone/emulator)**  
   - User logs in (or registers). Login state is stored (e.g. SharedPreferences).  
   - On the **Home** screen: user taps camera or gallery → picks a leaf image.  
   - App sends that image to the **analysis server** (HTTP POST).  
   - App gets back: **class label** (e.g. "Tomato Blight") and **confidence**.  
   - App shows the result and looks up **symptoms, treatment, prevention** from local data (`lib/core/data/disease_info.dart`).  
   - Result can be saved to **Firebase** (Realtime DB / Storage) for history.  
   - **History** tab loads past analyses from Firebase.  
   - **Settings**: user can set **Analysis server URL** or leave it blank so the app **auto-finds the server** on the same Wi‑Fi (mDNS).

2. **Python server** (`ml_server/server.py`)  
   - Runs on your PC (e.g. `http://0.0.0.0:8000`).  
   - Loads **best.pt** (YOLO) from `assets/model/` at startup.  
   - Registers **mDNS** so the app can discover it (`_cropdisease._tcp.local`).  
   - When the app sends an image: runs **YOLO inference**, returns the **label** and **confidence**.  
   - No ML runs on the phone; all inference is on the server.

3. **Model and labels**  
   - **Model:** `assets/model/best.pt` (YOLO, 17 classes: Apple, Corn, Potato, Tomato, Grape leaf diseases).  
   - **Class names** and **disease info** (symptoms, treatment, prevention) are in the app (`disease_info.dart`), so the app can show tips even when the server only returns a label.

4. **Admin**  
   - Admin logs in with a fixed email/password → **Admin Dashboard** to see users and their analysis history (from Firebase).

## How to run

**1. Start the server** (from project root):
```bash
pip install -r ml_server/requirements.txt
python ml_server/server.py
```
Put `best.pt` (YOLO model) in `assets/model/`. Keep the terminal open.

**2. Run the app:** `flutter run`

- **Emulator:** uses `http://10.0.2.2:8000` (host machine). Ensure the server is running.
- **Phone:** same Wi‑Fi as PC. App may auto-find the server (mDNS), or set **Settings** → **Analysis server URL** (e.g. `http://192.168.1.5:8000`).

### Backend URL not working?
1. Run the server first and keep the terminal open until you see `Uvicorn running on http://0.0.0.0:8000`.
2. Verify: open `http://127.0.0.1:8000/health` in a browser; it should return `{"status":"ok",...}`.
3. **Emulator:** no change needed; app uses `10.0.2.2:8000`.
4. **Phone:** get your PC’s IP (e.g. `ipconfig` → IPv4) and set **Settings** → **Analysis server URL** to `http://YOUR_PC_IP:8000` (no trailing slash).

## Login
- **Students:** Register or Login (email, password, name).
- **Admin:** Create an admin in your Firebase project (see FIREBASE_SWITCH_ACCOUNT.md), then log in with that email/password → Admin Dashboard (users, their history).

---

## Dart Files – Detailed Reference

### Entry point

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry point. Initializes Firebase, SharedPreferences, and AuthService. Shows loading until auth is checked, then routes to LoginScreen, HomeScreen, or AdminDashboardScreen. Handles locale (en, ml, hi, ta) and theme (light/dark). Admin users go to AdminDashboardScreen; regular users to HomeScreen. |

---

### Core

| File | Purpose |
|------|---------|
| `lib/core/data/disease_info.dart` | Disease info database. Holds `modelClassNames` (19 YOLO classes), `getInfo(label)` to return symptoms/treatment/prevention/severity, and `isHealthyLabel(label)` for UI coloring. Uses keyword matching (blight, spot, rust, rot, etc.) to map server labels to DiseaseInfo. |
| `lib/core/localization/app_localizations.dart` | In-app localization without ARB. Supports en, ml, hi, ta. Exposes getters (e.g. `appTitle`, `camera`, `analyzing`, `login`) that return the string for the current locale. Fallback to English. |
| `lib/core/localization/app_localizations_delegate.dart` | Flutter LocalizationsDelegate for AppLocalizations. Loads the right locale and reports support for en/ml/hi/ta. |
| `lib/core/theme/app_theme.dart` | Light and dark Material 3 themes. Teal/green gradients, amber for alerts. Defines color schemes, typography, card/button styles, AppBar, etc. Uses system fonts (offline-safe). |
| `lib/core/widgets/app_launcher_logo.dart` | Splash/launcher logo widget. Gradient background, centered card with eco icon. Scalable; used in a 1024x1024 area. |

---

### Services

| File | Purpose |
|------|---------|
| `lib/services/auth_service.dart` | Auth via Firebase Realtime DB + Firebase Auth. Login/register against `users` node. Persists session (SharedPreferences). Admin flag from `isAdmin` in DB. Syncs to Firebase Auth for Storage rules. |
| `lib/services/ml_service.dart` | Talks to Python server (best.pt YOLO). Uses base URL (emulator: 10.0.2.2:8000; device: Settings URL or mDNS discovery). Sends image to `/predict`, returns [label, confidence, isUncertain]. Can auto-start server on desktop if CROP_DISEASE_PROJECT is set. |
| `lib/services/analysis_repository.dart` | Saves and loads analyses in Firebase. Stores label, confidence, timestamp in Realtime DB at `users/{userKey}/analyses/`. Optionally uploads image to Storage; always stores base64 thumbnail in DB so History works without Storage. |
| `lib/services/model_matcher.dart` | Diagnostic helper for TFLite/legacy setup. Checks input shape, type, label count vs model. Used for debugging; main app uses YOLO server, not TFLite. |

---

### Auth screens

| File | Purpose |
|------|---------|
| `lib/features/auth/presentation/screens/login_screen.dart` | Login UI (email, password). Calls AuthService.login(), shows errors. Navigates to RegisterScreen. Language selector. On success calls onLoginSuccess. |
| `lib/features/auth/presentation/screens/register_screen.dart` | Registration (name, email, password, confirm). Validation. Calls AuthService.register(). Links to LoginScreen. Shows localized errors (e.g. email exists, password too short). |

---

### Disease detection screens

| File | Purpose |
|------|---------|
| `lib/features/disease_detection/presentation/screens/home_screen.dart` | Main screen: Analyze + History tabs. Camera/gallery image picker → MlService.detect() → shows label, confidence, DiseaseInfo (symptoms, treatment, prevention). Saves to AnalysisRepository. Handles “No leaf detected” and “Not a crop leaf”. |
| `lib/features/disease_detection/presentation/screens/settings_screen.dart` | Settings: Language (en/ml/hi/ta), Analysis server URL (SharedPreferences `analysis_server_url`), About, Logout. Shows username. Admin link to AdminDashboardScreen. |
| `lib/features/disease_detection/presentation/screens/about_screen.dart` | About page. App description, localized via AppLocalizations. |

---

### Admin screens

| File | Purpose |
|------|---------|
| `lib/features/admin/presentation/screens/admin_dashboard_screen.dart` | Admin home. Lists users from AnalysisRepository. Tap user → AdminUserDetailScreen. Has “Analyze” (opens HomeScreen) and Logout. |
| `lib/features/admin/presentation/screens/admin_user_detail_screen.dart` | One user’s analyses: thumbnails, labels, confidence, dates. Uses AnalysisRepository.getAnalysesForUser(). |
