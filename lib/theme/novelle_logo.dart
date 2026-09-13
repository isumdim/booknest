import 'package:flutter/material.dart';
import 'app_colors.dart';

class NovelleLogo extends StatelessWidget {
  final double size;
  final Color strokeColor;

  const NovelleLogo({
    super.key,
    this.size = 56,
    this.strokeColor = AppColors.lightPurple,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _OpenBookPainter(color: strokeColor),
    );
  }
}

// A simple line-art open book mark, drawn with strokes (no fill),
// used as the Novelle brand icon throughout the app.
class _OpenBookPainter extends CustomPainter {
  final Color color;
  _OpenBookPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.045
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    final baseY = h * 0.72;

    // Open book base (shallow curve)
    final basePath = Path()
      ..moveTo(w * 0.12, baseY)
      ..quadraticBezierTo(w * 0.5, h * 0.82, w * 0.88, baseY);
    canvas.drawPath(basePath, paint);

    // Left and right cover edges
    canvas.drawLine(Offset(w * 0.12, baseY), Offset(w * 0.22, h * 0.55), paint);
    canvas.drawLine(Offset(w * 0.88, baseY), Offset(w * 0.8, h * 0.6), paint);

    // Fanning page strokes rising from the book's spine
    final origin = Offset(w * 0.5, baseY - 2);
    final pagePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.032
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 6; i++) {
      final spread = (i - 2.5) * (w * 0.11);
      final height = h * (0.45 + (i == 2 || i == 3 ? 0.08 : 0));
      final end = Offset(origin.dx + spread, origin.dy - height);
      final control = Offset(origin.dx + spread * 0.5, origin.dy - height * 0.9);
      final path = Path()
        ..moveTo(origin.dx, origin.dy)
        ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
      canvas.drawPath(path, pagePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _OpenBookPainter oldDelegate) => oldDelegate.color != color;
}