import 'package:flutter/material.dart';

class GradientBorderColor extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final double width;

  const GradientBorderColor({super.key, 
    required this.child,
    required this.gradient,
    this.width = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      
      painter: _GradientBorderPainter(gradient, width),
      child: child,
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  final Gradient gradient;
  final double width;

  _GradientBorderPainter(this.gradient, this.width);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..shader = gradient
          .createShader(Rect.fromLTWH(0.0, 0.0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;

    final Path path = Path()
      ..addRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_GradientBorderPainter oldDelegate) => false;
}
