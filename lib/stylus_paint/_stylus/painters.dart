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
        canvas.drawCircle(Offset(p.x * scaleRatio, p.y * scaleRatio), 5, stylusPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}