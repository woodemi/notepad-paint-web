import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'controller.dart';
import 'models.dart';

abstract class IndicatePainter extends CustomPainter {
  final StylusPainterController controller;

  final double scaleRatio;

  IndicatePainter(this.controller, this.scaleRatio);

  bool trackEnabled = false;

  static const int defaultTrackPointerCount = 10;

  int trackPointerCount = defaultTrackPointerCount;

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    var length = controller.pointers.length;
    var count = trackEnabled ? trackPointerCount : 1;
    if (length < count) return;

    var pointers = controller.pointers.sublist(length - count);
    paintPointers(canvas, size, pointers);
  }

  void paintPointers(ui.Canvas canvas, ui.Size size, List<StylusPointer> pointers);

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class CircleIndicatePainter extends IndicatePainter {
  CircleIndicatePainter(StylusPainterController controller, double scaleRatio)
      : super(controller, scaleRatio);

  static const Color defaultColor = Colors.black;

  final Paint uiPaint = Paint()
    ..color = defaultColor;

  static const double defaultRadius = 5;

  double paintRadius = defaultRadius;

  @override
  void paintPointers(ui.Canvas canvas, ui.Size size, List<StylusPointer> pointers) {
    for (final p in pointers)
      canvas.drawCircle(p.offset * scaleRatio, paintRadius ?? defaultRadius, uiPaint);
  }
}

class ImageIndicatePainter extends IndicatePainter {
  final ui.Image image;

  ImageIndicatePainter(StylusPainterController controller, double scaleRatio, this.image)
    : super(controller, scaleRatio) {
    translate = defaultTranslate;
  }

  final Paint uiPaint = Paint();

  Offset get defaultTranslate => Offset(image.width / 2, -image.height / 2);

  Offset translate;

  @override
  void paintPointers(ui.Canvas canvas, ui.Size size, List<StylusPointer> pointers) {
    canvas.save();
    canvas.translate(translate?.dx ?? 0, translate?.dy ?? 0);

    for (final p in pointers) {
      var src = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
      var dst = Rect.fromCenter(
        center: p.offset * scaleRatio,
        width: image.width.toDouble(),
        height: image.height.toDouble(),
      );
      canvas.drawImageRect(image, src, dst, uiPaint);
    }

    canvas.restore();
  }
}