import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'controller.dart';

class CircleIndicatePainter extends CustomPainter {
  static const Color defaultColor = Colors.black;

  static const double defaultRadius = 5;

  final StylusPainterController controller;

  final double scaleRatio;

  CircleIndicatePainter(this.controller, this.scaleRatio);

  final Paint _paint = Paint()
    ..color = defaultColor;

  Color get color => _paint.color;

  set color(Color color) {
    assert(color != null);
    _paint.color = color;
  }

  double _paintRadius = defaultRadius;

  double get paintRadius => _paintRadius;

  set paintRadius(double paintRadius) {
    assert(paintRadius != null);
    _paintRadius = paintRadius;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (controller.pointers.length > 0) {
      var pointer = controller.pointers.last;
      canvas.drawCircle(pointer.offset * scaleRatio, _paintRadius ?? defaultRadius, _paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}