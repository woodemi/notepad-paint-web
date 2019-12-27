import 'dart:ui' as ui;

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

class ImageIndicatePainter extends CustomPainter {
  static const Color defaultColor = Colors.black;

  final StylusPainterController controller;

  final double scaleRatio;

  final ui.Image image;

  ImageIndicatePainter(this.controller, this.scaleRatio, this.image) {
    translate = defaultTranslate;
  }

  final Paint _paint = Paint()..color = Colors.green;

  bool trackEnabled = false;

  static const int defaultTrackPointerCount = 10;

  int _trackPointerCount = defaultTrackPointerCount;

  int get trackPointerCount => _trackPointerCount;

  set trackPointerCount(int trackPointerCount) {
    assert(trackPointerCount != null);
    _trackPointerCount = trackPointerCount;
  }

  Offset get defaultTranslate => Offset(image.width / 2, -image.height / 2);

  Offset _translate;

  Offset get translate => _translate;

  set translate(Offset translate) {
    assert(translate != null);
    _translate = translate;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var length = controller.pointers.length;
    var count = trackEnabled ? trackPointerCount : 1;
    if (length < count) return;

    canvas.save();
    canvas.translate(translate.dx, translate.dy);

    var pointers = controller.pointers.sublist(length - count);
    for (final p in pointers) {
      var src = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
      var dst = Rect.fromCenter(
          center: p.offset * scaleRatio,
          width: image.width.toDouble(),
          height: image.height.toDouble(),
      );
      canvas.drawImageRect(image, src, dst, _paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}