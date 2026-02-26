# Image-based model (HSV + TFLite)

The script **image-based.py** does leaf detection (HSV green mask) and classifies the crop with **leaf_disease_model.tflite**.

## How to get results in the app (quick steps)

1. **Add the model file** in this folder: `assets/model/leaf_disease_model.tflite` (same folder as `image-based.py`).
2. **Install Python deps** (from project root):  
   `pip install -r ml_server/requirements.txt`
3. **Start the server** (from project root):  
   `python -m uvicorn ml_server.server_image_based:app --host 127.0.0.1 --port 8000`  
   For Android emulator use the same; for a physical device use `--host 0.0.0.0` and point the app to your PC’s IP.
4. **Run the Flutter app** and pick a leaf image → you should see label and confidence.

## Use from the Flutter app (uploaded image → this model)

1. **Put the TFLite model** in this folder:
   - `assets/model/leaf_disease_model.tflite`

2. **Automated (desktop – no need to run the script yourself)**  
   - Install once: `pip install fastapi uvicorn python-multipart opencv-python tensorflow`  
   - Set the project root so the app can start the server when needed:
     - **Windows (PowerShell):** `$env:CROP_DISEASE_PROJECT = "C:\Users\YourName\StudioProjects\cropdisease"`
     - **Windows (CMD):** `set CROP_DISEASE_PROJECT=C:\Users\YourName\StudioProjects\cropdisease`
     - **Mac/Linux:** `export CROP_DISEASE_PROJECT=/path/to/cropdisease`
   - Run the Flutter app on **desktop** (e.g. `flutter run -d windows`). When the user uploads an image and taps Analyze, if no on-device model is used, the app will **start the Python server automatically** (if it’s not already running), then send the image to it and show the result. You do **not** need to run the script or server manually.

3. **Manual server (if you prefer)**  
   From project root:
   ```bash
   uvicorn ml_server.server_image_based:app --host 0.0.0.0 --port 8000
   ```
   Then use the app so it uses the server (e.g. no on-device model). On Android emulator the app uses `10.0.2.2:8000`; on desktop it can use `127.0.0.1:8000` if you set the env var above.

## Run the script by hand

- **With an image path (JSON output, no GUI):**
  ```bash
  python assets/model/image-based.py /path/to/photo.jpg
  ```
  Prints one line: `{"label": "Potato___Early_blight", "confidence": 0.95}`

- **Original mode (fixed path + OpenCV windows):**  
  Run with no arguments; it uses the path in `IMAGE_PATH` inside the script and shows the result in OpenCV windows.
