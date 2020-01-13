import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'models.dart';

class DotStrokePainter extends CustomPainter {
  final List<StylusStroke> strokes;

  final double scaleRatio;

  DotStrokePainter(this.strokes, this.scaleRatio);

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      for (final p in stroke.pointers)
        if (p.p > 0)
          canvas.drawCircle(p.offset * scaleRatio, stroke.paint.strokeWidth / 2, stroke.paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class LineStrokePainter extends CustomPainter {
  final List<StylusStroke> strokes;

  final double scaleRatio;

  final bool forceRepaint;

  LineStrokePainter(this.strokes, this.scaleRatio, this.forceRepaint);

  @override
  void paint(Canvas canvas, Size size) {
    for(final stroke in strokes) {
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
  bool shouldRepaint(LineStrokePainter oldDelegate) {
    var should = strokes.length != oldDelegate.strokes.length;
    return forceRepaint || should;
  }
}

const CUBIC_NUM = 4;

class PathStrokePainter extends CustomPainter {
  final List<StylusStroke> strokes;

  final double scaleRatio;

  final bool forceRepaint;

  PathStrokePainter(this.strokes, this.scaleRatio, this.forceRepaint);

  @override
  void paint(Canvas canvas, Size size) {
    for(final stroke in strokes) {
      final cubicQueue = ListQueue<StylusPointer>(CUBIC_NUM);
      for (final p in stroke.pointers) {
        cubicQueue.add(p);
        if (cubicQueue.length < CUBIC_NUM)
          continue;
        else if (cubicQueue.length > CUBIC_NUM)
          cubicQueue.removeFirst();

        var pre = cubicQueue.elementAt(0);
        var c1 = cubicQueue.elementAt(1);
        var c2 = cubicQueue.elementAt(2);
        var cur = cubicQueue.elementAt(3);

        var path = Path()
          ..moveTo(pre.x * scaleRatio, pre.y * scaleRatio)
          ..cubicTo(c1.x * scaleRatio, c1.y * scaleRatio, c2.x * scaleRatio, c2.y * scaleRatio, cur.x * scaleRatio, cur.y * scaleRatio);

        canvas.drawPath(path, stroke.paint);
      }
    }
  }

  @override
  bool shouldRepaint(PathStrokePainter oldDelegate) {
    var should = strokes.length != oldDelegate.strokes.length;
    return forceRepaint || should;
  }
}