// ignore_for_file: avoid_print
import 'dart:io';
import 'package:image/image.dart' as img;
void main() {
  final i = img.decodeImage(File('assets/icons/icon.png').readAsBytesSync());
  print(i == null ? 'decode failed' : '${i.width}x${i.height}');
}
