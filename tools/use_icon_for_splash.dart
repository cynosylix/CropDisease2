// Copies assets/icons/icon.png to Android splash and iOS LaunchImage.imageset.
// Run from project root: dart run tools/use_icon_for_splash.dart
// ignore_for_file: avoid_print

import 'dart:io';

import 'package:image/image.dart' as img;

void main() {
  final iconFile = File('assets/icons/icon.png');
  if (!iconFile.existsSync()) {
    print('ERROR: assets/icons/icon.png not found');
    exit(1);
  }
  final image = img.decodeImage(iconFile.readAsBytesSync());
  if (image == null) {
    print('ERROR: Could not decode icon.png');
    exit(1);
  }

  // Android: copy full size to drawable-nodpi/splash_logo.png
  final androidDir = Directory('android/app/src/main/res/drawable-nodpi');
  if (!androidDir.existsSync()) androidDir.createSync(recursive: true);
  File('${androidDir.path}/splash_logo.png').writeAsBytesSync(img.encodePng(image));
  print('Updated Android splash: ${androidDir.path}/splash_logo.png');

  // iOS: resize to 1x, 2x, 3x and write to LaunchImage.imageset
  final iosDir = Directory('ios/Runner/Assets.xcassets/LaunchImage.imageset');
  if (!iosDir.existsSync()) iosDir.createSync(recursive: true);
  for (final entry in [(1, 168), (2, 336), (3, 504)]) {
    final w = entry.$2;
    final scaled = img.copyResize(image, width: w, height: w);
    final name = entry.$1 == 1 ? 'LaunchImage.png' : 'LaunchImage@${entry.$1}x.png';
    File('${iosDir.path}/$name').writeAsBytesSync(img.encodePng(scaled));
  }
  File('${iosDir.path}/Contents.json').writeAsStringSync('''
{
  "images" : [
    { "idiom" : "universal", "filename" : "LaunchImage.png", "scale" : "1x" },
    { "idiom" : "universal", "filename" : "LaunchImage@2x.png", "scale" : "2x" },
    { "idiom" : "universal", "filename" : "LaunchImage@3x.png", "scale" : "3x" }
  ],
  "info" : { "author" : "xcode", "version" : 1 }
}
''');
  print('Updated iOS splash: ${iosDir.path}');
}
