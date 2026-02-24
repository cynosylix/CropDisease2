# best.pt inference server & on-device export

The app uses **only** the `best.pt` model. You can run **without starting any server** by exporting the model to ONNX once and bundling it in the app.

## Option A – On-device (no server)

1. **Export once** (from project root):
   ```bash
   pip install ultralytics
   python ml_server/export_onnx.py
   ```
   This creates `assets/model/best.onnx` and `assets/data/class_names.json`.

2. **Run the app** as usual. It will load the ONNX model from assets and run inference on the device. No server, no `uvicorn`, no manual steps.

If the ONNX assets are missing, the app falls back to the server (Option B).

---

## Option B – Server (current setup)

The app uses the `best.pt` model (in `../assets/model/best.pt`). Class names come from the model; the labels file is not used. The model is **loaded at server startup** so the first analysis request does not time out.

## Dependencies (server)

| What | Requirement |
|------|-------------|
| **Python** | 3.8 or higher |
| **Model file** | `../assets/model/best.pt` (Ultralytics YOLO .pt) |
| **Python packages** | See `requirements.txt`: `ultralytics`, `fastapi`, `uvicorn`, `python-multipart`. PyTorch is pulled in by `ultralytics`. |
| **Flutter app** | No TFLite. Uses `http` and `image_picker`; talks to this server only. |

Install once: `pip install -r requirements.txt`.

## Run the server (every time you open the project)

**Option 1 – From Cursor/VS Code**  
Press `Ctrl+Shift+P` → run **"Tasks: Run Task"** → choose **"Start ML Server"**. A terminal will open and start the server. Wait for `[server] Model loaded: ...`.

**Option 2 – Double‑click (Windows)**  
From the project root, double‑click **`start_ml_server.bat`**. A new window opens with the server; wait for `[server] Model loaded: ...`.

**Option 3 – From this folder (manual)**  
```bash
pip install -r requirements.txt
uvicorn server:app --host 0.0.0.0 --port 8000
```
Or double‑click **`ml_server/start_server.bat`**.

Wait until you see `[server] Model loaded: ...` before using the app.

Or set a custom model path:

```bash
set MODEL_PATH=C:\path\to\best.pt
uvicorn server:app --host 0.0.0.0 --port 8000
```

- **Android emulator**: app uses `http://10.0.2.2:8000` by default (host machine).
- **Real device**: ensure phone and PC are on the same network and change the base URL in `lib/services/ml_service.dart` to your PC’s IP (e.g. `http://192.168.1.100:8000`).
