// flutter test test/generate_icon_test.dart
// Renders the EmoSmart app icon using dart:ui and saves to assets/icon/app_icon.png

import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generate app icon', () async {
    const size = 1024.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Purple rounded square background
    final bgPaint = Paint()..color = const Color(0xFF5B4FCF);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size, size),
        const Radius.circular(220),
      ),
      bgPaint,
    );

    // "ES" text — bold white, centered
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'ES',
        style: TextStyle(
          color: Colors.white,
          fontSize: 480,
          fontWeight: FontWeight.bold,
          letterSpacing: -20,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size - textPainter.width) / 2,
        (size - textPainter.height) / 2,
      ),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    final outFile = File('assets/icon/app_icon.png');
    outFile.createSync(recursive: true);
    outFile.writeAsBytesSync(bytes!.buffer.asUint8List());

    print('Icon saved: ${outFile.path} (${outFile.lengthSync()} bytes)');
  });
}
