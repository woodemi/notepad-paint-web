import 'package:flutter/cupertino.dart';

import 'controller.dart';
import 'models.dart';

class DotStrokePainter extends CustomPainter {
  final StylusPaintController controller;

  final double scaleRatio;

  DotStrokePainter(this.controller, this.scaleRatio);

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in controller.strokes) {
      for (final p in stroke.pointers)
        if (p.p > 0)
          canvas.drawCircle(p.offset * scaleRatio, stroke.paint.strokeWidth / 2, stroke.paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class LineStrokePainter extends CustomPainter {
  final StylusPaintController controller;

  final double scaleRatio;

  LineStrokePainter(this.controller, this.scaleRatio);

  @override
  void paint(Canvas canvas, Size size) {
    for(final stroke in controller.strokes) {
      StylusPointer last;
      for (final p in stroke.pointers) {
        final pre = last?.p ?? 0;
        if (pre > 0 && p.p > 0) {
          canvas.drawLine(last.offset * scaleRatio, p.offset * scaleRatio, stroke.paint);
        }
        last = p;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}