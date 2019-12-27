import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'controller.dart';

class CircleIndicatePainter extends CustomPainter {
  static const Color defaultColor = Colors.black;

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

  static const double defaultRadius = 5;

  double _paintRadius = defaultRadius;

  double get paintRadius => _paintRadius;

  set paintRadius(double paintRadius) {
    assert(paintRadius != null);
    _paintRadius = paintRadius;
  }

  bool trackEnabled = false;

  static const int defaultTrackPointerCount = 10;

  int _trackPointerCount = defaultTrackPointerCount;

  int get trackPointerCount => _trackPointerCount;

  set trackPointerCount(int trackPointerCount) {
    assert(trackPointerCount != null);
    _trackPointerCount = trackPointerCount;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var length = controller.pointers.length;
    var count = trackEnabled ? trackPointerCount : 1;
    if (length >= count) {
      var pointers = controller.pointers.sublist(length - count);
      for (final p in pointers)
        canvas.drawCircle(p.offset * scaleRatio, _paintRadius, _paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}