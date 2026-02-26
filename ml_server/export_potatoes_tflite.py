"""
Convert potatoes.h5 (Keras) to potatoes.tflite for use in Flutter.
Run from project root: python ml_server/export_potatoes_tflite.py

Requires: pip install tensorflow

Creates:
  - assets/model/potatoes.tflite   (Flutter loads this via tflite_flutter)
  - assets/data/potatoes_class_names.json  (if model has class names; else create from model output shape)
"""
import json
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = SCRIPT_DIR.parent
MODEL_H5 = PROJECT_ROOT / "assets" / "model" / "potatoes.h5"
OUT_TFLITE = PROJECT_ROOT / "assets" / "model" / "potatoes.tflite"
OUT_NAMES = PROJECT_ROOT / "assets" / "data" / "potatoes_class_names.json"


def main():
    if not MODEL_H5.exists():
        print(f"Error: Model not found at {MODEL_H5}")
        sys.exit(1)

    try:
        import tensorflow as tf
    except ImportError:
        print("Error: Install tensorflow: pip install tensorflow")
        sys.exit(1)

    print(f"Loading {MODEL_H5} ...")
    # compile=False avoids errors when the .h5 was saved with older Keras (e.g. reduction='auto')
    model = tf.keras.models.load_model(str(MODEL_H5), compile=False)

    # Infer input shape (e.g. (224, 224, 3) or (256, 256, 3))
    in_shape = model.input_shape
    if len(in_shape) == 4:
        # (batch, height, width, channels)
        h, w = int(in_shape[1]), int(in_shape[2])
    else:
        h, w = 224, 224
    print(f"Input shape: {model.input_shape} -> using size {h}x{w}")

    num_classes = int(model.output_shape[-1])
    print(f"Output classes: {num_classes}")

    # Convert to TFLite
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    tflite_model = converter.convert()

    OUT_TFLITE.parent.mkdir(parents=True, exist_ok=True)
    OUT_TFLITE.write_bytes(tflite_model)
    print(f"Saved {OUT_TFLITE}")

    # Class names: default potato leaf labels if 3 classes
    default_names = {
        "0": "Potato leaf",
        "1": "Potato leaf early blight",
        "2": "Potato leaf late blight",
    }
    names = {str(i): default_names.get(str(i), f"Class_{i}") for i in range(num_classes)}
    OUT_NAMES.parent.mkdir(parents=True, exist_ok=True)
    with open(OUT_NAMES, "w", encoding="utf-8") as f:
        json.dump(names, f, indent=2)
    print(f"Saved {OUT_NAMES}")

    print("Done.")
    print("Next: In pubspec.yaml under flutter.assets add:  - assets/model/potatoes.tflite")
    print("Then run: flutter pub get && flutter run")
    return 0


if __name__ == "__main__":
    sys.exit(main() or 0)
