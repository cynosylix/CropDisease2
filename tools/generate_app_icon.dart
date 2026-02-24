// Generates app_icon.png (eco/leaf icon matching About screen Icons.eco_rounded).
// Run from project root: dart run tools/generate_app_icon.dart

import 'dart:io';

import 'package:image/image.dart' as img;

void main() {
  const int size = 1024;
  const int center = size ~/ 2;

  // Forest green from app theme (About screen primary)
  const int r = 0x2E, g = 0x7D, b = 0x32;
  final green = img.ColorRgba8(r, g, b, 255);

  final image = img.Image(width: size, height: size);

  // Fill transparent
  img.fill(image, color: img.ColorRgba8(0, 0, 0, 0));

  // Leaf shape: two overlapping circles (like Material eco_rounded leaf)
  const int leafRadius = 380;
  const int offset = 120;
  img.fillCircle(image, x: center - offset, y: center, radius: leafRadius, color: green, antialias: true);
  img.fillCircle(image, x: center + offset, y: center, radius: leafRadius, color: green, antialias: true);

  // Stem / center overlap
  img.fillCircle(image, x: center, y: center + 80, radius: 200, color: green, antialias: true);

  final dir = Directory('assets/icons');
  if (!dir.existsSync()) dir.createSync(recursive: true);

  final file = File('assets/icons/app_icon.png');
  file.writeAsBytesSync(img.encodePng(image));
  // ignore: avoid_print
  print('Generated ${file.path}');
}
