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

2. **Python server** (`ml_server/server_image_based.py`)  
   - Runs on your PC (e.g. `http://0.0.0.0:8000`).  
   - Loads **one TFLite model** from `assets/model/leaf_disease_model.tflite` at startup.  
   - Registers **mDNS** so the app can discover it (`_cropdisease._tcp.local`).  
   - When the app sends an image: resizes/normalizes it, runs **inference**, returns the **class index** and **confidence**.  
   - No ML runs on the phone; all inference is on the server.

3. **Model and labels**  
   - **Model:** `assets/model/leaf_disease_model.tflite` (e.g. 13 classes: healthy, blight, rust, spot, rot, etc.).  
   - **Class names** and **disease info** (symptoms, treatment, prevention) are in the app (`disease_info.dart`), so the app can show tips even when the server only returns a class index.

4. **Admin**  
   - Admin logs in with a fixed email/password → **Admin Dashboard** to see users and their analysis history (from Firebase).

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
