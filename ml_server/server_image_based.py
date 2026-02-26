"""
Prediction server: in-process inference (model loaded once at startup).
Same API: POST /predict -> {label, confidence}, GET /health.
Advertises via mDNS (_cropdisease._tcp.local) so the app can auto-discover the server IP.

Run from project root either way:
  pip install -r ml_server/requirements.txt
  python ml_server/server_image_based.py
  # or: python -m uvicorn ml_server.server_image_based:app --host 0.0.0.0 --port 8000
"""
import socket
import sys
from contextlib import asynccontextmanager
from pathlib import Path

# Allow "ml_server" to be imported when run as: python ml_server/server_image_based.py
_PROJECT_ROOT = Path(__file__).resolve().parent.parent
if str(_PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(_PROJECT_ROOT))

from fastapi import File, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

try:
    from fastapi import FastAPI
except ImportError:
    raise ImportError("Install: pip install fastapi uvicorn python-multipart")

PROJECT_ROOT = Path(__file__).resolve().parent.parent
PORT = 8000

_zeroconf = None


def _get_local_ip():
    """Primary LAN IP so the app can reach this server."""
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
    """Register this server as _cropdisease._tcp.local for app auto-discovery."""
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


def _is_image(content_type, filename):
    if content_type and content_type.startswith("image/"):
        return True
    if filename:
        ext = (filename or "").lower().split(".")[-1]
        if ext in ("jpg", "jpeg", "png", "gif", "webp", "bmp"):
            return True
    return False


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Load model once at startup; register mDNS for app auto-discovery."""
    try:
        from ml_server.inference_image_based import _load_model
        _load_model()
        print("Model loaded. Predictions will be fast.")
    except Exception as e:
        print(f"Warning: Model not loaded at startup: {e}. First request may be slow.")
    _register_mdns()
    yield
    _unregister_mdns()


app = FastAPI(title="Crop disease inference (image-based)", lifespan=lifespan)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
async def health():
    return {"status": "ok", "model": "image-based (in-process)"}


@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    """Run in-process inference. Returns {label, confidence}."""
    if not _is_image(file.content_type, file.filename):
        raise HTTPException(status_code=400, detail="Upload an image file (jpg, png, etc.)")
    contents = await file.read()
    if not contents:
        raise HTTPException(status_code=400, detail="Empty file")

    try:
        from ml_server.inference_image_based import predict_from_bytes
        label, confidence = predict_from_bytes(contents)
    except FileNotFoundError as e:
        raise HTTPException(
            status_code=500,
            detail=f"Model file missing. Add leaf_disease_model.tflite to assets/model/. {e}",
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    return {"label": label, "confidence": confidence}


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=PORT)
