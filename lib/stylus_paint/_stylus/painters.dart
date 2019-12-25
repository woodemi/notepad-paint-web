import 'package:flutter/cupertino.dart';

import 'models.dart';

class DotStrokePainter extends CustomPainter {
  final List<StylusPointer> _pointers;

  final double scaleRatio;

  final Paint stylusPaint;

  DotStrokePainter(
    this._pointers,
    this.scaleRatio, {
    this.stylusPaint
  });

  @override
  void paint(Canvas canvas, Size size) {
    for(final p in _pointers) {
      if (p.p > 0)
        canvas.drawCircle(p.offset * scaleRatio, 5, stylusPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class LineStrokePainter extends CustomPainter {
  final List<StylusPointer> _pointers;

  final double scaleRatio;

  final Paint stylusPaint;

  LineStrokePainter(
    this._pointers,
    this.scaleRatio, {
    this.stylusPaint
  });

  @override
  void paint(Canvas canvas, Size size) {
    StylusPointer last;
    for(final p in _pointers) {
      final pre = last?.p ?? 0;
      if (pre > 0 && p.p > 0) {
        canvas.drawLine(last.offset * scaleRatio, p.offset * scaleRatio, stylusPaint);
      }
      last = p;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}