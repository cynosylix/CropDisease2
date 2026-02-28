"""
Leaf disease prediction using YOLO (best.pt).
Run: python "main (1).py" [image_path]
  - With image path: predicts and prints result.
  - No args: uses sample image path below.
"""
import os
import sys

from ultralytics import YOLO

# Paths (best.pt in same folder as this script)
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH = os.path.join(SCRIPT_DIR, "best.pt")
DEFAULT_IMAGE = os.path.join(SCRIPT_DIR, "sample.jpg")

# Use first arg as image path, or default
IMAGE_PATH = sys.argv[1] if len(sys.argv) >= 2 else DEFAULT_IMAGE

# 1. Load YOLO model
model = YOLO(MODEL_PATH)

# 2. Run inference
results = model.predict(
    source=IMAGE_PATH,
    conf=0.25,
    save=True,
    line_width=2,
    show_labels=True,
    show_conf=True,
    show=False,
)

# 3. Process and print results
for result in results:
    if len(result.boxes) == 0:
        print(f"Image: {result.path} -> No disease detected (Background/Safe)")
    else:
        for box in result.boxes:
            class_id = int(box.cls[0])
            label = model.names[class_id]
            confidence = float(box.conf[0])
            print(f"Image: {result.path} -> Detected: {label} ({confidence:.2f})")

print("Check 'runs/detect/predict' for the output images!")
# Class names: Apple leaf, Apple rust leaf, Corn Gray leaf spot, Corn leaf blight, Corn rust leaf,
# Potato leaf early blight, Potato leaf late blight, Tomato Septoria leaf spot, Tomato leaf,
# Tomato leaf bacterial spot, Tomato leaf late blight, Tomato leaf mosaic virus, Tomato leaf yellow virus,
# Tomato mold leaf, Tomato two spotted spider mites leaf, grape leaf, grape leaf black rot
