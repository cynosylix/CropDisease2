"""
In-process inference: same logic as assets/model/image-based.py but model loaded once.
Use this from the FastAPI server to avoid loading TensorFlow + model on every request.
"""
from pathlib import Path
from typing import Tuple
import numpy as np

PROJECT_ROOT = Path(__file__).resolve().parent.parent
MODEL_PATH = PROJECT_ROOT / "assets" / "model" / "leaf_disease_model.tflite"
IMG_SIZE = 224

CLASS_NAMES = [
    "Apple___Black_rot",
    "Apple___healthy",
    "Corn_(maize)___Common_rust_",
    "Corn_(maize)___healthy",
    "Grape___Black_rot",
    "Grape___healthy",
    "Grape___Leaf_blight_(Isariopsis_Leaf_Spot)",
    "Potato___Early_blight",
    "Potato___healthy",
    "Potato___Late_blight",
    "Tomato___Early_blight",
    "Tomato___healthy",
    "Tomato___Late_blight",
]

_interpreter = None
_input_index = None
_output_index = None


def _load_model():
    """Load TFLite model once. Call at server startup."""
    global _interpreter, _input_index, _output_index
    if _interpreter is not None:
        return
    if not MODEL_PATH.is_file():
        raise FileNotFoundError(f"Model not found: {MODEL_PATH}")
    import tensorflow as tf  # noqa: E402
    _interpreter = tf.lite.Interpreter(model_path=str(MODEL_PATH))
    _interpreter.allocate_tensors()
    input_details = _interpreter.get_input_details()
    output_details = _interpreter.get_output_details()
    _input_index = input_details[0]["index"]
    _output_index = output_details[0]["index"]


def predict_from_bytes(image_bytes: bytes) -> Tuple[str, float]:
    """
    Run leaf detection (HSV) + TFLite classification on image bytes.
    Returns (label, confidence). Same output as image-based.py.
    """
    import cv2  # noqa: E402
    _load_model()
    nparr = np.frombuffer(image_bytes, np.uint8)
    image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    if image is None:
        return "Image not found", 0.0

    hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
    lower_green = np.array([35, 40, 40])
    upper_green = np.array([85, 255, 255])
    mask = cv2.inRange(hsv, lower_green, upper_green)
    kernel = np.ones((5, 5), np.uint8)
    mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, kernel)
    mask = cv2.morphologyEx(mask, cv2.MORPH_OPEN, kernel)
    contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    for cnt in contours:
        area = cv2.contourArea(cnt)
        if area > 1000:
            x, y, w, h = cv2.boundingRect(cnt)
            leaf_only = cv2.bitwise_and(image, image, mask=mask)
            leaf_crop = leaf_only[y : y + h, x : x + w]
            leaf_resized = cv2.resize(leaf_crop, (IMG_SIZE, IMG_SIZE))
            leaf_resized = cv2.cvtColor(leaf_resized, cv2.COLOR_BGR2RGB)
            leaf_resized = leaf_resized.astype(np.float32) / 255.0
            leaf_resized = np.expand_dims(leaf_resized, axis=0)

            _interpreter.set_tensor(_input_index, leaf_resized)
            _interpreter.invoke()
            output = _interpreter.get_tensor(_output_index)
            confidence = float(np.max(output))
            class_index = int(np.argmax(output))
            predicted_class = CLASS_NAMES[class_index]
            return predicted_class, confidence

    return "No leaf detected", 0.0
