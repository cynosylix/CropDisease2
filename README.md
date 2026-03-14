# Crop Disease Detector

Flutter app for leaf disease detection using YOLO (best.pt model) via ML server.

## Quick Start

1. **Firebase** – Replace `android/app/google-services.json` with your Firebase project config. See [FIREBASE_SWITCH_ACCOUNT.md](FIREBASE_SWITCH_ACCOUNT.md).
2. **Admin** – Create admin user: `cd scripts && node create_admin.js --email admin@example.com --password YourPassword123`
3. **ML Server** – Put `best.pt` in `assets/model/`, then run `python ml_server/server.py` (or use `start_ml_server.bat`).
4. **App** – `flutter pub get && flutter run`

## Docs

| Doc | Description |
|-----|-------------|
| [FIREBASE_SWITCH_ACCOUNT.md](FIREBASE_SWITCH_ACCOUNT.md) | Switch to your Firebase project |
| [ml_server/README.md](ml_server/README.md) | ML server setup (best.pt, ONNX export) |
| [STUDENT_APP_EXPLANATION.md](STUDENT_APP_EXPLANATION.md) | How the app works |
| [FIREBASE_REALTIME_DB_RULES.md](FIREBASE_REALTIME_DB_RULES.md) | Database rules |
| [FIREBASE_STORAGE_SETUP.md](FIREBASE_STORAGE_SETUP.md) | Image storage (optional) |

## Model

The app uses **best.pt** (Ultralytics YOLO) from `assets/model/`. The ML server loads it at startup. See `ml_server/README.md` for server and ONNX options.
