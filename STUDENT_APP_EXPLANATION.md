# Crop Disease Detector

## What it does
- Take or pick a leaf photo → app sends it to a **Python server** → shows **disease name**, **confidence %**, and **tips** (symptoms, treatment, prevention).
- **History** tab shows past results. **Settings**: language, server URL, logout.

## How to run

**1. Start the server** (from project root):
```bash
pip install -r ml_server/requirements.txt
python ml_server/server_image_based.py
```
Put `leaf_disease_model.tflite` in `assets/model/`. Keep the terminal open.

**2. Run the app:** `flutter run`

- **Emulator:** uses default server URL.
- **Phone:** same Wi‑Fi as PC. App can auto-find the server, or set **Settings** → **Analysis server URL** (e.g. `http://192.168.1.5:8000`).

## Login
- **Students:** Register or Login (email, password, name).
- **Admin:** Login with `admin@cropdisease.com` / `Admin123` → Admin Dashboard (users, their history).

## Logo (launcher & splash)
- Run `dart run tools/generate_app_icon.dart` then `dart run flutter_launcher_icons`. Uninstall and reinstall the app so the launcher icon updates.
