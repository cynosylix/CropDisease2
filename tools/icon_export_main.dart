// Renders the EXACT same logo as the About page (Icons.eco_rounded) to PNG for launcher and splash.
// Run from project root: flutter run -t tools/icon_export_main.dart -d windows
// (Use -d windows, -d linux, or -d macos; the app will capture and exit.)

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() {
  runApp(const _IconExportApp());
}

class _IconExportApp extends StatefulWidget {
  const _IconExportApp();

  @override
  State<_IconExportApp> createState() => _IconExportAppState();
}

class _IconExportAppState extends State<_IconExportApp> {
  final GlobalKey _repaintKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _captureAndSave());
  }

  Future<void> _captureAndSave() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;
    final image = await boundary.toImage(pixelRatio: 2.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;
    final pngBytes = byteData.buffer.asUint8List();

    // Project root: assume we're run from project root
    final projectRoot = Directory.current.path;
    final assetsIcons = Directory('$projectRoot/assets/icons');
    if (!assetsIcons.existsSync()) assetsIcons.createSync(recursive: true);

    final appIconFile = File('$projectRoot/assets/icons/app_icon.png');
    await appIconFile.writeAsBytes(pngBytes);
    // ignore: avoid_print
    print('Saved exact eco_rounded logo -> ${appIconFile.path}');

    // Android splash (same image)
    final androidSplashDir = Directory('$projectRoot/android/app/src/main/res/drawable-nodpi');
    if (!androidSplashDir.existsSync()) androidSplashDir.createSync(recursive: true);
    final splashFile = File('${androidSplashDir.path}/splash_logo.png');
    await splashFile.writeAsBytes(pngBytes);
    // ignore: avoid_print
    print('Saved Android splash -> ${splashFile.path}');

    // iOS splash (same image; 1x, 2x, 3x)
    final iosDir = Directory('$projectRoot/ios/Runner/Assets.xcassets/LaunchImage.imageset');
    if (!iosDir.existsSync()) iosDir.createSync(recursive: true);
    await File('${iosDir.path}/LaunchImage.png').writeAsBytes(pngBytes);
    await File('${iosDir.path}/LaunchImage@2x.png').writeAsBytes(pngBytes);
    await File('${iosDir.path}/LaunchImage@3x.png').writeAsBytes(pngBytes);
    await File('${iosDir.path}/Contents.json').writeAsString('''
{
  "images" : [
    { "idiom" : "universal", "filename" : "LaunchImage.png", "scale" : "1x" },
    { "idiom" : "universal", "filename" : "LaunchImage@2x.png", "scale" : "2x" },
    { "idiom" : "universal", "filename" : "LaunchImage@3x.png", "scale" : "3x" }
  ],
  "info" : { "author" : "xcode", "version" : 1 }
}
''');
    // ignore: avoid_print
    print('Saved iOS splash -> ${iosDir.path}');
    // ignore: avoid_print
    print('Next: dart run flutter_launcher_icons');
    exit(0);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFF2E7D32),
        body: RepaintBoundary(
          key: _repaintKey,
          child: Center(
            child: SizedBox(
              width: 512,
              height: 512,
              child: Container(
                color: const Color(0xFF2E7D32),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.eco_rounded,
                  size: 400,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
