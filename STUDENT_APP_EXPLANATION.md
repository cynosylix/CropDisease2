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
- **Admin:** Create an admin in your Firebase project (see **ADMIN_SETUP.md**), then log in with that email/password → Admin Dashboard (users, their history).
