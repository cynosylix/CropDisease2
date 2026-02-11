# PowerShell script to auto-update labels.txt based on model class count
# Run this after the app shows the model's class count in terminal

Write-Host "========================================"
Write-Host "Auto-Update labels.txt Script"
Write-Host "========================================"
Write-Host ""
Write-Host "This script will help you update labels.txt"
Write-Host "First, run the app and check terminal for:"
Write-Host "  'Number of output classes: ???'"
Write-Host ""
$numClasses = Read-Host "Enter the number of classes your model has"

if ([int]$numClasses -le 0) {
    Write-Host "Invalid number. Exiting."
    exit
}

Write-Host ""
Write-Host "Generating labels.txt with $numClasses labels..."

# Common plant disease labels
$commonLabels = @(
    "Healthy",
    "Leaf Blight",
    "Powdery Mildew",
    "Rust",
    "Leaf Spot",
    "Bacterial Spot",
    "Early Blight",
    "Late Blight",
    "Leaf Mold",
    "Septoria Leaf Spot",
    "Spider Mites",
    "Target Spot",
    "Yellow Leaf Curl Virus",
    "Mosaic Virus",
    "Apple Scab",
    "Black Rot",
    "Cedar Apple Rust",
    "Cercospora Leaf Spot",
    "Common Rust",
    "Northern Leaf Blight",
    "Esca",
    "Haunglongbing",
    "Leaf Scorch"
)

$labels = @()
for ($i = 0; $i -lt [int]$numClasses; $i++) {
    if ($i -lt $commonLabels.Length) {
        $labels += $commonLabels[$i]
    } else {
        $labels += "Class_$i"
    }
}

$content = $labels -join "`n"
$filePath = "assets\labels\labels.txt"

try {
    Set-Content -Path $filePath -Value $content -Encoding UTF8
    Write-Host ""
    Write-Host "✅ Successfully updated $filePath"
    Write-Host "   Added $numClasses labels"
    Write-Host ""
    Write-Host "⚠️  NOTE: Some labels may be placeholders (Class_X)"
    Write-Host "⚠️  You should replace them with actual disease names"
    Write-Host "⚠️  Get real labels from your model's training dataset"
    Write-Host "⚠️  Labels must be in the SAME ORDER as model training"
    Write-Host ""
    Write-Host "Current labels:"
    $labels | ForEach-Object { Write-Host "  - $_" }
} catch {
    Write-Host ""
    Write-Host "❌ Error updating file: $_"
    Write-Host ""
    Write-Host "Manual update:"
    Write-Host "1. Open: assets\labels\labels.txt"
    Write-Host "2. Replace with:"
    Write-Host $content
}
