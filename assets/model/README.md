# Model (best.pt + main.py)

- **best.pt** – YOLO leaf disease model (Ultralytics). 17 classes: Apple, Corn, Potato, Tomato, Grape leaf diseases.
- **main.py** – CLI script for local inference.

## CLI usage

```bash
# From project root
python assets/model/main.py [image_path]

# With image
python assets/model/main.py path/to/leaf.jpg

# No args: uses sample.jpg in this folder (create one for testing)
```

## Server

The Flutter app uses `ml_server/server.py`, which loads this same `best.pt` model and exposes HTTP endpoints for the app. Run `python ml_server/server.py` from project root.
