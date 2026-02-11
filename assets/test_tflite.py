"""
Test TensorFlow Lite Model
Verify that TFLite model works correctly
"""
import os
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'  # 0=all, 1=no INFO, 2=no WARNING, 3=no ERROR
import tensorflow as tf
import numpy as np
from tensorflow.keras.preprocessing.image import load_img, img_to_array
import json
import sys

# Configuration
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)
MODEL_NAME = 'plant_disease_mobilenet.tflite'
IMAGE_SIZE = 224


def _choose_image_file():
    """Open a file dialog for the user to pick an image. Returns path or None."""
    try:
        import tkinter as tk
        from tkinter import filedialog
        root = tk.Tk()
        root.withdraw()
        root.attributes('-topmost', True)
        root.lift()
        root.after(100, lambda: root.focus_force())
        path = filedialog.askopenfilename(
            title="Select an image (TFLite test)",
            filetypes=[
                ("Image files", "*.jpg *.jpeg *.png *.bmp"),
                ("JPEG", "*.jpg *.jpeg"),
                ("PNG", "*.png"),
                ("All files", "*.*"),
            ],
        )
        try:
            root.destroy()
        except Exception:
            pass
        return path if path else None
    except Exception:
        return None


def _find_model():
    """Resolve model path: same dir as script, assets/model/, or project root."""
    candidates = [
        os.path.join(SCRIPT_DIR, MODEL_NAME),
        os.path.join(SCRIPT_DIR, 'model', MODEL_NAME),
        os.path.join(PROJECT_ROOT, 'assets', 'model', MODEL_NAME),
        os.path.join(PROJECT_ROOT, MODEL_NAME),
        MODEL_NAME,
    ]
    for path in candidates:
        if os.path.exists(path):
            return path
    return None


def load_tflite_model(model_path):
    """Load TFLite model"""
    resolved = model_path or _find_model()
    if not resolved or not os.path.exists(resolved):
        print(f"Error: TFLite model '{MODEL_NAME}' not found!")
        print("Searched:", SCRIPT_DIR, os.path.join(SCRIPT_DIR, 'model'), PROJECT_ROOT)
        print("Available .tflite files:")
        for d in [SCRIPT_DIR, os.path.join(SCRIPT_DIR, 'model'), PROJECT_ROOT]:
            if os.path.isdir(d):
                for file in os.listdir(d):
                    if file.endswith('.tflite'):
                        print(f"  - {os.path.join(d, file)}")
        sys.exit(1)
    model_path = resolved
    
    print(f"Loading TFLite model: {model_path}")
    interpreter = tf.lite.Interpreter(model_path=model_path)
    interpreter.allocate_tensors()
    print("Model loaded successfully!")
    
    # Get input and output details
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    
    print(f"\nInput details:")
    print(f"  Shape: {input_details[0]['shape']}")
    print(f"  Type: {input_details[0]['dtype']}")
    print(f"Output details:")
    print(f"  Shape: {output_details[0]['shape']}")
    print(f"  Type: {output_details[0]['dtype']}")
    
    return interpreter, input_details, output_details

def preprocess_image(img_path):
    """Preprocess image for TFLite model"""
    if not os.path.exists(img_path):
        raise FileNotFoundError(f"Image file not found: {img_path}")
    
    # Load and resize image
    img = load_img(img_path, target_size=(IMAGE_SIZE, IMAGE_SIZE))
    
    # Convert to array and normalize
    x = img_to_array(img) / 255.0
    
    # Add batch dimension
    x = np.expand_dims(x, axis=0).astype(np.float32)
    
    return x

def predict_tflite(interpreter, input_details, output_details, img_path, class_names):
    """Make prediction using TFLite model"""
    print(f"\nProcessing image: {img_path}")
    
    # Preprocess image
    x = preprocess_image(img_path)
    
    # Set input tensor
    interpreter.set_tensor(input_details[0]['index'], x)
    
    # Run inference
    interpreter.invoke()
    
    # Get output
    output_data = interpreter.get_tensor(output_details[0]['index'])
    predictions = output_data[0]
    
    # Get top prediction
    idx = int(np.argmax(predictions))
    conf = float(np.max(predictions))
    predicted_class = class_names[idx]
    
    # Get top 3 predictions
    top_3_indices = np.argsort(predictions)[-3:][::-1]
    top_3 = []
    for i in top_3_indices:
        top_3.append({
            'class': class_names[i],
            'confidence': float(predictions[i]),
            'index': int(i)
        })
    
    return {
        'predicted_class': predicted_class,
        'confidence': conf,
        'class_index': idx,
        'top_3': top_3
    }

def compare_with_keras():
    """Compare TFLite predictions with original Keras model"""
    print("\n" + "="*60)
    print("COMPARING TFLITE vs KERAS MODEL")
    print("="*60)
    
    keras_model_path = 'plant_disease_mobilenet_best.h5'
    if not os.path.exists(keras_model_path):
        return  # Optional: no .h5 Keras model to compare with
    
    # Load Keras model
    keras_model = tf.keras.models.load_model(keras_model_path)
    
    # Load TFLite model
    interpreter, input_details, output_details = load_tflite_model(_find_model())
    
    # Load class names
    with open('class_names.json', 'r') as f:
        class_names = json.load(f)
    
    # Find a test image
    test_image = None
    dataset_dir = "dataset"
    if os.path.exists(dataset_dir):
        for root, dirs, files in os.walk(dataset_dir):
            for file in files:
                if file.lower().endswith(('.jpg', '.jpeg', '.png')):
                    test_image = os.path.join(root, file)
                    break
            if test_image:
                break
    
    if not test_image:
        print("No test image found")
        return
    
    print(f"\nTest image: {test_image}")
    
    # Keras prediction
    x = preprocess_image(test_image)
    keras_pred = keras_model.predict(x, verbose=0)[0]
    keras_idx = np.argmax(keras_pred)
    keras_conf = keras_pred[keras_idx]
    
    # TFLite prediction
    interpreter.set_tensor(input_details[0]['index'], x)
    interpreter.invoke()
    tflite_pred = interpreter.get_tensor(output_details[0]['index'])[0]
    tflite_idx = np.argmax(tflite_pred)
    tflite_conf = tflite_pred[tflite_idx]
    
    print(f"\nKeras Model:")
    print(f"  Prediction: {class_names[keras_idx]}")
    print(f"  Confidence: {keras_conf*100:.2f}%")
    
    print(f"\nTFLite Model:")
    print(f"  Prediction: {class_names[tflite_idx]}")
    print(f"  Confidence: {tflite_conf*100:.2f}%")
    
    # Compare
    if keras_idx == tflite_idx:
        print("\n✓ Predictions match!")
    else:
        print("\n⚠ Predictions differ!")
    
    diff = np.abs(keras_pred - tflite_pred).max()
    print(f"Max prediction difference: {diff:.6f}")
    
    if diff < 0.01:
        print("✓ Predictions are very similar (good conversion!)")
    else:
        print("⚠ Significant difference detected")

def main():
    """Main function"""
    if len(sys.argv) > 1:
        model_path = sys.argv[1]
    else:
        model_path = _find_model()
        if not model_path:
            quantized = os.path.join(SCRIPT_DIR, 'model', 'plant_disease_mobilenet_quantized.tflite')
            if os.path.exists(quantized):
                model_path = quantized
                print("Using quantized model (smaller, faster)")
        if not model_path:
            model_path = None  # let load_tflite_model find it

    interpreter, input_details, output_details = load_tflite_model(model_path)

    # Load class names: class_names.json or assets/labels/labels.txt
    class_names = None
    for labels_path in [
        os.path.join(SCRIPT_DIR, 'class_names.json'),
        os.path.join(PROJECT_ROOT, 'assets', 'labels', 'labels.txt'),
        os.path.join(SCRIPT_DIR, 'labels', 'labels.txt'),
        'class_names.json',
        'assets/labels/labels.txt',
    ]:
        if os.path.exists(labels_path):
            with open(labels_path, 'r', encoding='utf-8') as f:
                if labels_path.endswith('.json'):
                    class_names = json.load(f)
                else:
                    class_names = [line.strip() for line in f if line.strip() and not line.startswith('#')]
            break
    if not class_names:
        print("Error: class_names.json or assets/labels/labels.txt not found!")
        sys.exit(1)
    
    # Get image path: from argv, or always ask user to choose/upload
    if len(sys.argv) > 2:
        image_path = sys.argv[2].strip()
    else:
        print("\n--- Select an image ---")
        print("Opening file dialog... (if nothing appears, check behind this window)")
        image_path = _choose_image_file()
        if not image_path:
            print("File dialog cancelled or unavailable. Type image path instead:")
            image_path = input("> ").strip().strip('"').strip("'")
        if not image_path:
            print("No image selected. Exiting.")
            sys.exit(1)
        print(f"Using image: {image_path}")
    if not os.path.exists(image_path):
        print(f"Error: File not found: {image_path}")
        sys.exit(1)
    
    # Make prediction
    try:
        result = predict_tflite(interpreter, input_details, output_details, image_path, class_names)
        
        # Display results
        print("\n" + "="*60)
        print("TFLITE PREDICTION RESULTS")
        print("="*60)
        print(f"Image: {image_path}")
        print(f"\nPredicted Class: {result['predicted_class']}")
        print(f"Confidence: {result['confidence']*100:.2f}%")
        print(f"Class Index: {result['class_index']}")
        
        print("\nTop 3 Predictions:")
        print("-" * 60)
        for i, pred in enumerate(result['top_3'], 1):
            print(f"{i}. {pred['class']:50s} {pred['confidence']*100:6.2f}%")
        
        print("="*60)
        
        # Compare with Keras if available
        compare_with_keras()
        
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()




