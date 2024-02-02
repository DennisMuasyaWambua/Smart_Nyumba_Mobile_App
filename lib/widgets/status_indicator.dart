import 'package:flutter/material.dart';

class StatusIndicator extends StatelessWidget {
  final Color color;

  const StatusIndicator({Key? key, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(8, 8),
      painter: _CirclePainter(color),
    );
  }
}

class _CirclePainter extends CustomPainter {
  final Color color;

  _CirclePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..isAntiAlias = true;

    const double radius = 5;
    final Offset center = Offset(size.width / 2, size.height / 2);

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
