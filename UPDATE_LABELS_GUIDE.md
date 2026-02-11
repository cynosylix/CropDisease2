# How to Update labels.txt

## Step 1: Find Out How Many Classes Your Model Has

When you run the app, check the terminal for:
```
Number of output classes: ???
```
or
```
Model outputs: ??? classes
```

**Note that number!**

---

## Step 2: Get the Correct Labels

You need to find the labels your model was trained with. Check:

1. **Your model's training dataset folder**
   - Look at folder names or file names
   - Each folder/class = one label

2. **Training script/notebook**
   - Check the class names used during training
   - Look for label mapping or class list

3. **Model documentation**
   - If you downloaded the model, check its documentation
   - Look for a README or label file

4. **Dataset source**
   - If using PlantVillage: 38 classes
   - If using custom dataset: check your data folder

---

## Step 3: Update labels.txt

1. **Open**: `assets/labels/labels.txt`
2. **Replace** all content with the correct labels
3. **Important**:
   - One label per line
   - Exact same order as model training
   - No empty lines
   - Exactly the number of classes your model has

---

## Common Datasets

### PlantVillage (38 classes):
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

### Custom 5-Class (if your model has 5):
```
Healthy
Leaf Blight
Powdery Mildew
Rust
Leaf Spot
```

---

## Step 4: Verify

1. Save the file
2. Restart the app
3. Check terminal - should show "✅ Label count MATCHES"
4. Test with images

---

**The key is: Labels must be in the EXACT ORDER your model was trained with!**
