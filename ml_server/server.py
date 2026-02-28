"""
Inference server for best.pt (Ultralytics YOLO).
Uses assets/model/best.pt and main.py logic.
Run: pip install -r ml_server/requirements.txt
     python ml_server/server.py
     # or: uvicorn server:app --host 0.0.0.0 --port 8000
Registers mDNS (_cropdisease._tcp.local) so the Flutter app can auto-discover.
"""
import os
import socket
from pathlib import Path
from typing import Optional

from contextlib import asynccontextmanager
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

PROJECT_ROOT = Path(__file__).resolve().parent.parent
MODEL_PATH = os.environ.get("MODEL_PATH", str(PROJECT_ROOT / "assets" / "model" / "best.pt"))
PORT = 8000

_model = None
_zeroconf = None


def _get_local_ip():
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.settimeout(0)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except Exception:
        return "127.0.0.1"


def _register_mdns():
    global _zeroconf
    try:
        from zeroconf import ServiceInfo, Zeroconf
        ip = _get_local_ip()
        info = ServiceInfo(
            "_cropdisease._tcp.local.",
            "Crop Disease Server._cropdisease._tcp.local.",
            addresses=[socket.inet_aton(ip)],
            port=PORT,
            server=f"{socket.gethostname().split('.')[0]}.local.",
        )
        _zeroconf = Zeroconf()
        _zeroconf.register_service(info)
        print(f"mDNS: app can auto-find server at http://{ip}:{PORT}")
    except Exception as e:
        print(f"mDNS registration skipped: {e}")


def _unregister_mdns():
    global _zeroconf
    if _zeroconf:
        try:
            _zeroconf.unregister_all_services()
            _zeroconf.close()
        except Exception:
            pass
        _zeroconf = None


def get_model():
    global _model
    if _model is None:
        try:
            from ultralytics import YOLO
            if not os.path.isfile(MODEL_PATH):
                raise FileNotFoundError(f"Model not found: {MODEL_PATH}")
            _model = YOLO(MODEL_PATH)
        except Exception as e:
            raise RuntimeError(f"Failed to load model from {MODEL_PATH}: {e}") from e
    return _model


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Preload model and register mDNS so the app can auto-discover."""
    global _model
    try:
        get_model()
        print(f"[server] Model loaded: {MODEL_PATH}")
    except Exception as e:
        print(f"[server] Model preload failed (will load on first request): {e}")
    _register_mdns()
    yield
    _unregister_mdns()
    _model = None


app = FastAPI(title="Crop disease inference (best.pt)", lifespan=lifespan)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


def _is_image_file(content_type: Optional[str], filename: Optional[str]) -> bool:
    if content_type and content_type.startswith("image/"):
        return True
    if filename:
        ext = (filename or "").lower().split(".")[-1]
        if ext in ("jpg", "jpeg", "png", "gif", "webp", "bmp"):
            return True
    return False


@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    """Run inference on uploaded image. Returns label and confidence from the model."""
    if not _is_image_file(file.content_type, file.filename):
        raise HTTPException(status_code=400, detail="Upload an image file (jpg, png, etc.)")
    contents = await file.read()
    if not contents:
        raise HTTPException(status_code=400, detail="Empty file")
    model = get_model()
    # Write to temp file for YOLO (accepts path or numpy)
    import tempfile
    suffix = Path(file.filename or "img").suffix or ".jpg"
    with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
        tmp.write(contents)
        tmp_path = tmp.name
    try:
        results = model(tmp_path)
    finally:
        try:
            os.unlink(tmp_path)
        except OSError:
            pass
    if not results:
        raise HTTPException(status_code=500, detail="No prediction result")
    result = results[0]
    # Classification: probs + names
    if hasattr(result, "probs") and result.probs is not None:
        probs = result.probs.data
        if hasattr(probs, "cpu"):
            probs = probs.cpu().numpy()
        top1_idx = int(probs.argmax())
        confidence = float(probs.flat[top1_idx])
        names = result.names or {}
        label = names.get(top1_idx, str(top1_idx))
        return {"label": label, "confidence": confidence}
    # Detection: take top box by confidence (or "No leaf detected" if none)
    if hasattr(result, "boxes") and result.boxes is not None:
        if len(result.boxes) == 0:
            return {"label": "No leaf detected", "confidence": 0.0}
        boxes = result.boxes
        confs = boxes.conf
        if hasattr(confs, "cpu"):
            confs = confs.cpu().numpy()
        cls_ids = boxes.cls
        if hasattr(cls_ids, "cpu"):
            cls_ids = cls_ids.cpu().numpy()
        idx = int(confs.argmax())
        confidence = float(confs.flat[idx])
        class_id = int(cls_ids.flat[idx])
        names = result.names or {}
        label = names.get(class_id, str(class_id))
        return {"label": label, "confidence": confidence}
    raise HTTPException(status_code=500, detail="Model returned no class (unknown task type)")


@app.get("/health")
async def health():
    return {"status": "ok", "model": MODEL_PATH}


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=PORT)
