# Quick Fix: Update labels.txt

## 🎯 What You Need to Do

Your model expects a certain number of classes, but `labels.txt` only has 5 labels.

---

## Step 1: Find Model Class Count

**Run the app and check terminal for:**
```
Number of output classes: ???
```
or
```
Model outputs: ??? classes
```

**Write down that number!**

---

## Step 2: Get Your Model's Labels

You need to find what labels your model was trained with. Check:

### Option A: Training Dataset
- Open your training dataset folder
- Each folder name = one label
- List them in the same order as folders

### Option B: Training Script
- Open your training notebook/script
- Find the class names list
- Copy them in the same order

### Option C: Model Source
- If you downloaded the model, check its documentation
- Look for a README or label file
- Check the source website

### Option D: Common Datasets

**If using PlantVillage dataset (38 classes):**
See `PLANTVILLAGE_LABELS.txt` example below

**If using custom 5-class dataset:**
Your current labels might be correct, just verify the order

---

## Step 3: Update labels.txt

1. **Open**: `assets/labels/labels.txt`
2. **Delete all content**
3. **Paste your labels** (one per line)
4. **Save**
5. **Restart app**

---

## Example: PlantVillage (38 classes)

If your model has 38 classes and uses PlantVillage dataset, your `labels.txt` should be:

```
Apple___Apple_scab
Apple___Black_rot
Apple___Cedar_apple_rust
Apple___Healthy
Blueberry___Healthy
Cherry___Powdery_mildew
Cherry___Healthy
Corn___Cercospora_leaf_spot
Corn___Common_rust
Corn___Northern_Leaf_Blight
Corn___Healthy
Grape___Black_rot
Grape___Esca
Grape___Leaf_blight
Grape___Healthy
Orange___Haunglongbing
Peach___Bacterial_spot
Peach___Healthy
Pepper_bell___Bacterial_spot
Pepper_bell___Healthy
Potato___Early_blight
Potato___Late_blight
Potato___Healthy
Raspberry___Healthy
Soybean___Healthy
Squash___Powdery_mildew
Strawberry___Leaf_scorch
Strawberry___Healthy
Tomato___Bacterial_spot
Tomato___Early_blight
Tomato___Late_blight
Tomato___Leaf_Mold
Tomato___Septoria_leaf_spot
Tomato___Spider_mites
Tomato___Target_Spot
Tomato___Yellow_Leaf_Curl_Virus
Tomato___Mosaic_virus
Tomato___Healthy
```

---

## ⚠️ CRITICAL RULES

1. **Exact count**: Must have exactly the number of classes your model has
2. **Exact order**: Must be in the same order as model training
3. **One per line**: No empty lines, no comments
4. **No duplicates**: Each label must be unique

---

## ✅ After Updating

1. Save `labels.txt`
2. Restart the app
3. Check terminal - should show "✅ Label count MATCHES"
4. Test with images - should work correctly now!

---

**The app will show you the exact number of classes when it starts. Use that number to update labels.txt!**
