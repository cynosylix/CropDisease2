### Crop Disease Detector – Simple Explanation for Students

### 1. What the app does
- **Main idea**: This app is a **crop disease detector**.  
  It uses **AI and the phone’s camera** to check if a plant leaf is healthy or has a disease, and then shows **treatment and prevention tips**.

### 2. How the app starts
- **Startup steps**:
  - The app initializes **Firebase** (backend services).
  - It loads saved login data using **`shared_preferences`**.
  - If the user is **already logged in**, it opens the **Home screen**.
  - If not, it shows the **Login screen** where the user enters **email and password** or goes to the **Register screen** to create an account.
  - The login state is saved, so next time the user usually does **not need to log in again**.

### 3. Home screen – what the user can do
- **Main actions on Home screen**:
  - See a **welcome message** with the user’s name and the app title.
  - **Take a photo** of a crop leaf using the camera.
  - **Select an existing photo** of a leaf from the gallery.
  - After a photo is chosen, the app:
    - Sends the image to the **AI model**.
    - Shows the **predicted disease name** (for example “Leaf Blight” or “Healthy”).
    - Shows a **confidence percentage** (how sure the model is).
    - Displays the result in a **colored card** (greenish for healthy, warning colors for disease).

### 4. How the AI (ML model) works – simple view
- **Model and assets**:
  - The app uses a **TensorFlow Lite model** file: `plant_disease_mobilenet.tflite` in the `assets/model` folder.
  - It also uses a `labels.txt` file with the **names of each class** (diseases and “healthy”).
- **`MlService` responsibilities**:
  - Loads the **TFLite model** and **labels**.
  - Prepares the image:
    - Resizes the image to **224 × 224 pixels**.
    - Converts each pixel to a number between **0 and 1**.
    - Puts all numbers into the exact **tensor shape** the model expects.
  - Runs the **interpreter** (the TFLite engine) to get a list of **probabilities** (one for each disease).
  - Finds the **highest probability** (argmax).
  - Converts that index to a **label string** using `labels.txt`.
  - Returns to the UI: **[label, confidence, isUncertain]**.

### 5. Handling uncertainty and safety
- **Safety checks**:
  - If the model returns an internal label like `"Class_5"`, the UI **never shows this raw label**.
  - In this case, the label is replaced with **"Unknown"** before it is displayed.
- **Low confidence handling**:
  - If the **confidence is very low** (for example below 15%):
    - The app may show the result as **"Unknown"**.
    - It shows an **orange warning message** suggesting to **try a clearer image**.
  - For **medium confidence**:
    - The app still shows the predicted disease name.
    - It also displays a **warning text** saying the prediction may be **uncertain or inaccurate**.

### 6. Disease information shown to the user
- **`DiseaseInfo` helper**:
  - Maps general disease names (that contain words like **“blight”**, **“rust”**, **“spot”**, **“powdery mildew”**, or **“healthy”**) to:
    - **Symptoms** (what you see on the leaves),
    - **Treatment steps** (what a farmer should do),
    - **Prevention tips** (how to avoid the disease in future),
    - **Severity level** (None / Low / Medium / High).
- **Healthy case**:
  - Shows a **“Plant Status”** section with a positive description.
  - Shows **maintenance tips** to keep the plant healthy.
- **Diseased case**:
  - Shows three sections:
    - **Symptoms**,
    - **Treatment Steps** (numbered list),
    - **Prevention Tips** (numbered list).

### 7. Languages and user interface
- **Multiple languages**:
  - The app supports **English (`en`)**, **Malayalam (`ml`)**, **Hindi (`hi`)**, and **Tamil (`ta`)**.
  - Texts (titles, buttons, messages) come from `AppLocalizations`, so the app can switch between languages.
- **Settings and logout**:
  - In the **Settings screen**, the user can:
    - Change the **language**.
    - **Log out**, which returns them to the Login screen.
- **Design**:
  - Uses **Material 3** themes, **gradients**, and **cards**.
  - Aims to be **clean, modern, and easy to understand** for students and farmers.

---

You can read this file directly to students, or use it as the basis for slides or a short oral explanation of how the Crop Disease Detector app works.
