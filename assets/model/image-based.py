"""
Leaf disease prediction: HSV leaf detection + TFLite classification.
- Run with no args: uses IMAGE_PATH below and shows OpenCV windows (original behavior).
- Run with image path: python image-based.py /path/to/image.jpg
  Prints one JSON line: {"label": "Potato___Early_blight", "confidence": 0.95}
  No leaf: {"label": "No leaf detected", "confidence": 0.0}
"""
import json
import os
import sys

import cv2
import numpy as np
import tensorflow as tf

# =====================
# CONFIG
# =====================
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH = os.path.join(SCRIPT_DIR, "leaf_disease_model.tflite")
IMAGE_PATH = "E:\\Projects\\Ai&Ml\\Project_plant\\prediction\\keybrd.webp"
IMG_SIZE = 224

# CLI mode: first arg = image path (no GUI, output JSON only)
CLI_MODE = len(sys.argv) >= 2
INPUT_IMAGE_PATH = sys.argv[1] if CLI_MODE else IMAGE_PATH

# =====================
# CLASS NAMES
# =====================
class_names = [
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
    "Tomato___Late_blight"
]


def run_prediction(image_path: str):
    """Load image, detect leaf (HSV), run TFLite. Returns (label, confidence) or (label, confidence, annotated_image)."""
    if not os.path.isfile(MODEL_PATH):
        return ("Model not found", 0.0, None) if not CLI_MODE else ("Model not found", 0.0)
    interpreter = tf.lite.Interpreter(model_path=MODEL_PATH)
    interpreter.allocate_tensors()
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()

    image = cv2.imread(image_path)
    if image is None:
        return ("Image not found", 0.0, None) if not CLI_MODE else ("Image not found", 0.0)

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
            if not CLI_MODE:
                cv2.rectangle(image, (x, y), (x + w, y + h), (0, 255, 0), 2)
            leaf_only = cv2.bitwise_and(image, image, mask=mask)
            leaf_crop = leaf_only[y:y + h, x:x + w]
            leaf_resized = cv2.resize(leaf_crop, (IMG_SIZE, IMG_SIZE))
            leaf_resized = cv2.cvtColor(leaf_resized, cv2.COLOR_BGR2RGB)
            leaf_resized = leaf_resized.astype(np.float32) / 255.0
            leaf_resized = np.expand_dims(leaf_resized, axis=0)

            interpreter.set_tensor(input_details[0]["index"], leaf_resized)
            interpreter.invoke()
            output = interpreter.get_tensor(output_details[0]["index"])
            confidence = float(np.max(output))
            class_index = int(np.argmax(output))
            predicted_class = class_names[class_index]

            if not CLI_MODE:
                label = f"{predicted_class} ({confidence*100:.1f}%)"
                cv2.putText(image, label, (x, y - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 255, 0), 2)
                print("\n🌿 Leaf Detected & Classified")
                print("---------------------------------")
                print(f"Predicted Class : {predicted_class}")
                print(f"Confidence      : {confidence * 100:.2f}%")
                return predicted_class, confidence, image
            return predicted_class, confidence

    return ("No leaf detected", 0.0, image) if not CLI_MODE else ("No leaf detected", 0.0)


def main():
    if CLI_MODE:
        label, confidence = run_prediction(INPUT_IMAGE_PATH)
        out = {"label": label, "confidence": confidence}
        print(json.dumps(out))
        return

    # Original behavior: fixed IMAGE_PATH, show windows
    result = run_prediction(IMAGE_PATH)
    if len(result) == 3:
        label, confidence, image = result
    else:
        label, confidence = result
        image = cv2.imread(IMAGE_PATH)
    if image is None:
        image = cv2.imread(IMAGE_PATH)
    if label == "No leaf detected":
        print("⚠️ No leaf detected!")
    if image is not None:
        cv2.imshow("Final Output", image)
        hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
        mask = cv2.inRange(hsv, np.array([35, 40, 40]), np.array([85, 255, 255]))
        cv2.imshow("Mask", mask)
        cv2.waitKey(0)
        cv2.destroyAllWindows()


if __name__ == "__main__":
    main()
