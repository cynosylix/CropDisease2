// App launcher & splash: FULL VERTICAL GRADIENT (top #1B5E20 -> bottom #2E7D32),
// centered card, eco leaf. Output: single flattened 1024x1024 PNG (no separate layers).
// Run from project root: dart run tools/generate_app_icon.dart
// Then: dart run flutter_launcher_icons
// ignore_for_file: avoid_print

import 'dart:io';

import 'package:image/image.dart' as img;

/// Builds the full 1024x1024 image with gradient flattened into pixels.
img.Image buildFullImage() {
  const int size = 1024;
  const int center = size ~/ 2;

  // 1. Full vertical gradient: TOP = #1B5E20, BOTTOM = #2E7D32 (flattened into pixels)
  final image = img.Image(width: size, height: size);
  for (int y = 0; y < size; y++) {
    final t = y / (size - 1); // 0 at top, 1 at bottom
    final r = (0x1B + (0x2E - 0x1B) * t).round().clamp(0, 255);
    final g = (0x5E + (0x7D - 0x5E) * t).round().clamp(0, 255);
    final b = (0x20 + (0x32 - 0x20) * t).round().clamp(0, 255);
    final color = img.ColorRgba8(r, g, b, 255);
    for (int x = 0; x < size; x++) {
      image.setPixel(x, y, color);
    }
  }

  // 2. Center card: 50% of canvas = 512, radius 25% of square = 128, color #DDE7DA
  const int cardSize = 512;
  const int cardRadius = 128;
  const int cardLeft = (size - cardSize) ~/ 2;   // 256
  const int cardTop = (size - cardSize) ~/ 2;     // 256
  final cardColor = img.ColorRgba8(0xDD, 0xE7, 0xDA, 255);
  final innerLeft = cardLeft + cardRadius;   // 384
  final innerTop = cardTop + cardRadius;     // 384
  final innerRight = cardLeft + cardSize - cardRadius;  // 640
  final innerBottom = cardTop + cardSize - cardRadius; // 640
  img.fillRect(image, x1: innerLeft, y1: cardTop, x2: innerRight, y2: cardTop + cardSize, color: cardColor);
  img.fillRect(image, x1: cardLeft, y1: innerTop, x2: cardLeft + cardSize, y2: innerBottom, color: cardColor);
  img.fillCircle(image, x: innerLeft, y: innerTop, radius: cardRadius, color: cardColor);
  img.fillCircle(image, x: innerRight, y: innerTop, radius: cardRadius, color: cardColor);
  img.fillCircle(image, x: innerLeft, y: innerBottom, radius: cardRadius, color: cardColor);
  img.fillCircle(image, x: innerRight, y: innerBottom, radius: cardRadius, color: cardColor);

  // 3. Eco leaf inside card: 50% of card = 256, color #2E7D32 (centered at 512,512)
  final leafColor = img.ColorRgba8(0x2E, 0x7D, 0x32, 255);
  const int leafCenterY = 512;
  const int leafRadius = 80;
  const int lobeOffset = 32;
  const int lobeY = leafCenterY - 60;
  img.fillCircle(image, x: center - lobeOffset, y: lobeY, radius: leafRadius, color: leafColor);
  img.fillCircle(image, x: center + lobeOffset, y: lobeY, radius: leafRadius, color: leafColor);
  const int stemWidth = 24;
  const int stemTop = 552;
  const int stemBottom = 632;
  img.fillRect(image, x1: center - stemWidth ~/ 2, y1: stemTop, x2: center + stemWidth ~/ 2, y2: stemBottom, color: leafColor);
  img.fillCircle(image, x: center, y: stemBottom, radius: stemWidth ~/ 2, color: leafColor);

  return image;
}

/// Re-opens the saved PNG and returns true if gradient is visible (top row != bottom row).
bool verifyGradientInFile(File pngFile) {
  final bytes = pngFile.readAsBytesSync();
  final decoded = img.decodeImage(bytes);
  if (decoded == null || decoded.width < 2 || decoded.height < 2) return false;
  final topPixel = decoded.getPixel(decoded.width ~/ 2, 0);
  final bottomPixel = decoded.getPixel(decoded.width ~/ 2, decoded.height - 1);
  final topR = topPixel.r.toInt(), topG = topPixel.g.toInt(), topB = topPixel.b.toInt();
  final botR = bottomPixel.r.toInt(), botG = bottomPixel.g.toInt(), botB = bottomPixel.b.toInt();
  final gradientVisible = (topR != botR) || (topG != botG) || (topB != botB);
  if (gradientVisible) {
    print('  Gradient in file: top #${topR.toRadixString(16).padLeft(2, '0')}${topG.toRadixString(16).padLeft(2, '0')}${topB.toRadixString(16).padLeft(2, '0')} -> bottom #${botR.toRadixString(16).padLeft(2, '0')}${botG.toRadixString(16).padLeft(2, '0')}${botB.toRadixString(16).padLeft(2, '0')}');
  } else {
    print('VERIFY FAIL: Gradient not visible in saved PNG (top $topR,$topG,$topB vs bottom $botR,$botG,$botB)');
  }
  return gradientVisible;
}

void main() {
  final dir = Directory('assets/icons');
  if (!dir.existsSync()) dir.createSync(recursive: true);
  final file = File('assets/icons/app_icon.png');

  img.Image image = buildFullImage();
  for (int attempt = 1; attempt <= 3; attempt++) {
    file.writeAsBytesSync(img.encodePng(image));
    if (verifyGradientInFile(file)) {
      print('Generated ${file.path} (gradient verified on attempt $attempt)');
      break;
    }
    print('Regenerating and overwriting (attempt ${attempt + 1})...');
    image = buildFullImage();
  }
  if (!verifyGradientInFile(file)) {
    print('WARNING: Gradient still not visible after 3 attempts. Check encoder.');
  }

  final androidSplashDir = Directory('android/app/src/main/res/drawable-nodpi');
  if (!androidSplashDir.existsSync()) androidSplashDir.createSync(recursive: true);
  final splashImage = buildFullImage();
  final splashFile = File('${androidSplashDir.path}/splash_logo.png');
  splashFile.writeAsBytesSync(img.encodePng(splashImage));
  if (verifyGradientInFile(splashFile)) {
    print('Generated Android splash: ${androidSplashDir.path}/splash_logo.png (gradient verified)');
  } else {
    print('Generated Android splash: ${androidSplashDir.path}/splash_logo.png (verify failed)');
  }

  final iosSplashDir = Directory('ios/Runner/Assets.xcassets/LaunchImage.imageset');
  if (!iosSplashDir.existsSync()) iosSplashDir.createSync(recursive: true);
  for (final entry in [(1, 168), (2, 336), (3, 504)]) {
    final w = entry.$2;
    final scaled = img.copyResize(image, width: w, height: w);
    final name = entry.$1 == 1 ? 'LaunchImage.png' : 'LaunchImage@${entry.$1}x.png';
    File('${iosSplashDir.path}/$name').writeAsBytesSync(img.encodePng(scaled));
  }
  File('${iosSplashDir.path}/Contents.json').writeAsStringSync('''
{
  "images" : [
    { "idiom" : "universal", "filename" : "LaunchImage.png", "scale" : "1x" },
    { "idiom" : "universal", "filename" : "LaunchImage@2x.png", "scale" : "2x" },
    { "idiom" : "universal", "filename" : "LaunchImage@3x.png", "scale" : "3x" }
  ],
  "info" : { "author" : "xcode", "version" : 1 }
}
''');
  print('Generated iOS splash: ${iosSplashDir.path}');
  print('Run: dart run flutter_launcher_icons');
}
