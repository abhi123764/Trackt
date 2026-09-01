import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Trackt logo painter for the splash screen logo.
class TracktLogoPainter extends CustomPainter {
  const TracktLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 6);

    // Green growth arc
    final arcPaint = Paint()
      ..color = AppColors.accentGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.043
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: size.width * 0.34),
      0.35,
      2.5,
      false,
      arcPaint,
    );

    // Growth arrow
    final arrowPaint = Paint()
      ..color = AppColors.accentGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.036
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width * 0.28, size.height * 0.36)
      ..lineTo(size.width * 0.44, size.height * 0.50)
      ..lineTo(size.width * 0.56, size.height * 0.40)
      ..lineTo(size.width * 0.76, size.height * 0.20);

    canvas.drawPath(path, arrowPaint);

    final arrowHead = Path()
      ..moveTo(size.width * 0.62, size.height * 0.18)
      ..lineTo(size.width * 0.78, size.height * 0.18)
      ..lineTo(size.width * 0.78, size.height * 0.32);

    canvas.drawPath(arrowHead, arrowPaint);

    // Person
    final bodyPaint = Paint()..color = AppColors.textPrimary;

    canvas.drawCircle(Offset(center.dx, center.dy - 14), 9, bodyPaint);

    final torso = Path()
      ..moveTo(center.dx - 14, center.dy + 26)
      ..quadraticBezierTo(
        center.dx - 16,
        center.dy - 4,
        center.dx,
        center.dy - 2,
      )
      ..quadraticBezierTo(
        center.dx + 16,
        center.dy - 4,
        center.dx + 14,
        center.dy + 26,
      )
      ..close();

    canvas.drawPath(torso, bodyPaint);

    // Barbell
    final barPaint = Paint()
      ..color = AppColors.textPrimary
      ..strokeWidth = size.width * 0.029
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(center.dx - size.width * 0.21, center.dy - size.height * 0.043),
      Offset(center.dx + size.width * 0.21, center.dy - size.height * 0.043),
      barPaint,
    );

    for (final dx in [-0.21, 0.21]) {
      final weightPaint = Paint()
        ..color = AppColors.textPrimary
        ..strokeWidth = size.width * 0.043
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(center.dx + size.width * dx, center.dy - size.height * 0.114),
        Offset(center.dx + size.width * dx, center.dy + size.height * 0.029),
        weightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
