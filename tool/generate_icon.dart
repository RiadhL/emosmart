import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final size = 1024;
  final image = img.Image(width: size, height: size);

  // Fill with purple background
  img.fill(image, color: img.ColorRgb8(91, 79, 207));

  // Draw rounded corners by making corners transparent (white = launcher will crop)
  final radius = 220;
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      bool inCorner = false;
      if (x < radius && y < radius) {
        inCorner = (x - radius) * (x - radius) + (y - radius) * (y - radius) > radius * radius;
      } else if (x > size - radius && y < radius) {
        inCorner = (x - (size - radius)) * (x - (size - radius)) + (y - radius) * (y - radius) > radius * radius;
      } else if (x < radius && y > size - radius) {
        inCorner = (x - radius) * (x - radius) + (y - (size - radius)) * (y - (size - radius)) > radius * radius;
      } else if (x > size - radius && y > size - radius) {
        inCorner = (x - (size - radius)) * (x - (size - radius)) + (y - (size - radius)) * (y - (size - radius)) > radius * radius;
      }
      if (inCorner) {
        image.setPixel(x, y, img.ColorRgb8(255, 255, 255));
      }
    }
  }

  final white = img.ColorRgb8(255, 255, 255);
  final letterHeight = 320;
  final barHeight    = 55;

  // ── Letter E ───────────────────────────────────────────────────────────────
  final eX  = 260;
  final eY  = (size - letterHeight) ~/ 2;
  final eW  = 120;

  // vertical bar
  img.fillRect(image, x1: eX, y1: eY, x2: eX + 55, y2: eY + letterHeight, color: white);
  // top bar
  img.fillRect(image, x1: eX, y1: eY, x2: eX + eW, y2: eY + barHeight, color: white);
  // middle bar (slightly shorter)
  img.fillRect(image,
      x1: eX,
      y1: eY + letterHeight ~/ 2 - barHeight ~/ 2,
      x2: eX + eW - 20,
      y2: eY + letterHeight ~/ 2 + barHeight ~/ 2,
      color: white);
  // bottom bar
  img.fillRect(image,
      x1: eX, y1: eY + letterHeight - barHeight, x2: eX + eW, y2: eY + letterHeight, color: white);

  // ── Letter S ───────────────────────────────────────────────────────────────
  final sX = 530;
  final sY = (size - letterHeight) ~/ 2;
  final sW = 130;
  final sB = 55; // bar thickness

  // top bar
  img.fillRect(image, x1: sX, y1: sY, x2: sX + sW, y2: sY + sB, color: white);
  // upper-left vertical
  img.fillRect(image, x1: sX, y1: sY, x2: sX + sB, y2: sY + letterHeight ~/ 2, color: white);
  // middle bar
  img.fillRect(image,
      x1: sX,
      y1: sY + letterHeight ~/ 2 - sB ~/ 2,
      x2: sX + sW,
      y2: sY + letterHeight ~/ 2 + sB ~/ 2,
      color: white);
  // lower-right vertical
  img.fillRect(image,
      x1: sX + sW - sB, y1: sY + letterHeight ~/ 2, x2: sX + sW, y2: sY + letterHeight, color: white);
  // bottom bar
  img.fillRect(image,
      x1: sX, y1: sY + letterHeight - sB, x2: sX + sW, y2: sY + letterHeight, color: white);

  Directory('assets/icon').createSync(recursive: true);
  File('assets/icon/app_icon.png').writeAsBytesSync(img.encodePng(image));
  print('Icon generated at assets/icon/app_icon.png');
}
