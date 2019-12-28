import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'models.dart';

abstract class IndicatePainter extends CustomPainter {
  final List<StylusPointer> pointers;

  final double scaleRatio;

  IndicatePainter(this.pointers, this.scaleRatio);

  bool trackEnabled = false;

  static const int defaultTrackPointerCount = 10;

  int trackPointerCount = defaultTrackPointerCount;

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    var length = pointers.length;
    var count = trackEnabled ? trackPointerCount : 1;
    if (length < count) return;

    var sublist = pointers.sublist(length - count);
    paintPointers(canvas, size, sublist);
  }

  void paintPointers(ui.Canvas canvas, ui.Size size, List<StylusPointer> pointers);

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class CircleIndicatePainter extends IndicatePainter {
  CircleIndicatePainter(List<StylusPointer> pointers, double scaleRatio)
      : super(pointers, scaleRatio);

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

  ImageIndicatePainter(List<StylusPointer> pointers, double scaleRatio, this.image)
    : super(pointers, scaleRatio) {
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