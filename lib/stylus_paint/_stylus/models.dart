import 'dart:ui';

import 'package:flutter/material.dart';

class StylusPointer {
  int x;
  int y;
  int t;
  int p;

  StylusPointer.fromMap(map)
      :
        this.x = map['x'],
        this.y = map['y'],
        this.t = map['t'],
        this.p = map['p'];

  Offset get offset => Offset(x.toDouble(), y.toDouble());
}

class StylusStroke {
  final List<StylusPointer> pointers = List<StylusPointer>();

  final Paint paint;

  StylusStroke(Paint paint)
      : paint = Paint()
          ..color = paint.color
          ..strokeWidth = paint.strokeWidth;
}