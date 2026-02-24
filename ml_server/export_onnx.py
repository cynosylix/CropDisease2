"""
Export best.pt (Ultralytics YOLO) to ONNX for on-device inference in Flutter.
Run once from project root: python ml_server/export_onnx.py
  (or from ml_server: python export_onnx.py)

Creates:
  - assets/model/best.onnx   (model for Flutter flutter_onnxruntime)
  - assets/data/class_names.json   (id -> label map)

No server needed after this; the app can run inference locally using these assets.
"""
import json
import os
import sys
from pathlib import Path

# Project root (parent of ml_server)
SCRIPT_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = SCRIPT_DIR.parent
os.chdir(PROJECT_ROOT)

MODEL_PT = PROJECT_ROOT / "assets" / "model" / "best.pt"
OUT_ONNX = PROJECT_ROOT / "assets" / "model" / "best.onnx"
OUT_NAMES = PROJECT_ROOT / "assets" / "data" / "class_names.json"


def main():
    if not MODEL_PT.exists():
        print(f"Error: Model not found at {MODEL_PT}")
        sys.exit(1)

    try:
        from ultralytics import YOLO
    except ImportError:
        print("Error: Install ultralytics first: pip install ultralytics")
        sys.exit(1)

    print(f"Loading {MODEL_PT} ...")
    model = YOLO(str(MODEL_PT))

    # Get class names (works for both classification and detection)
    names = getattr(model, "names", None) or {}
    if isinstance(names, dict):
        # Ensure keys are int and values are str; sort by id for consistent index
        names = {int(k): str(v) for k, v in names.items()}
    else:
        names = {i: str(v) for i, v in enumerate(names)} if names else {}

    OUT_NAMES.parent.mkdir(parents=True, exist_ok=True)
    with open(OUT_NAMES, "w", encoding="utf-8") as f:
        json.dump(names, f, indent=2, ensure_ascii=False)
    print(f"Saved class names ({len(names)} classes) -> {OUT_NAMES}")

    # Export to ONNX. Use imgsz=224 for classification; 640 is default for detection.
    # If your model is classification, 224 is typical; for detection leave default.
    task = getattr(model.model, "names", None)
    imgsz = 224  # safe default for classification; for detection use 640
    if hasattr(model, "task") and model.task == "detect":
        imgsz = 640
    print(f"Exporting to ONNX (imgsz={imgsz}) ...")
    # Export writes best.onnx next to best.pt (same directory)
    exported = model.export(format="onnx", imgsz=imgsz, simplify=True, opset=12)
    onnx_path = Path(exported) if isinstance(exported, str) else OUT_ONNX
    if not onnx_path.is_absolute():
        onnx_path = (PROJECT_ROOT / onnx_path).resolve()
    if onnx_path.exists():
        print(f"Done. ONNX: {onnx_path}")
        print(f"Class names: {OUT_NAMES}")
    else:
        print("Warning: ONNX file not found at expected path; check export output.")
    return 0


if __name__ == "__main__":
    sys.exit(main() or 0)
