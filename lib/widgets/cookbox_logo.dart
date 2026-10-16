import 'package:flutter/material.dart';

class CookBoxLogo extends StatelessWidget {
  const CookBoxLogo({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 27.0 : 58.0;
    final wordmarkSize = compact ? 11.0 : 31.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: iconSize,
          height: iconSize,
          child: CustomPaint(painter: _CookBoxIconPainter()),
        ),
        SizedBox(width: compact ? 5 : 11),
        RichText(
          text: TextSpan(
            style: TextStyle(
              color: const Color(0xFF1D2B3F),
              fontSize: wordmarkSize,
              fontWeight: FontWeight.w800,
              letterSpacing: compact ? -0.35 : -0.8,
            ),
            children: const [
              TextSpan(text: 'Cook'),
              TextSpan(
                text: 'Box',
                style: TextStyle(color: Color(0xFFF05A28)),
              ),
            ],
          ),
        ),
        SizedBox(width: compact ? 7 : 12),
        Container(
          width: compact ? 6 : 10,
          height: compact ? 6 : 10,
          decoration: const BoxDecoration(
            color: Color(0xFF18C863),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}

class _CookBoxIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 58;
    final orange = Paint()..color = const Color(0xFFF05A28);
    final white = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.4 * scale
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    final green = Paint()..color = const Color(0xFF18C863);

    final roundedRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(16 * scale),
    );
    canvas.drawRRect(roundedRect, orange);

    final box = Path()
      ..moveTo(15 * scale, 22 * scale)
      ..lineTo(29 * scale, 31 * scale)
      ..lineTo(43 * scale, 22 * scale)
      ..moveTo(15 * scale, 22 * scale)
      ..lineTo(15 * scale, 39 * scale)
      ..lineTo(29 * scale, 48 * scale)
      ..lineTo(43 * scale, 39 * scale)
      ..lineTo(43 * scale, 22 * scale)
      ..moveTo(29 * scale, 31 * scale)
      ..lineTo(29 * scale, 48 * scale);
    canvas.drawPath(box, white);

    final leaf = Path()
      ..moveTo(38 * scale, 12 * scale)
      ..quadraticBezierTo(47 * scale, 8 * scale, 49 * scale, 11 * scale)
      ..quadraticBezierTo(47 * scale, 18 * scale, 39 * scale, 17 * scale)
      ..close();
    canvas.drawPath(leaf, green);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
