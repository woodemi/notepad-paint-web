import 'dart:ui';

import 'package:flutter/material.dart';

import 'models.dart';

class StylusPainterController {
  static Paint get defaultPaint => Paint()
    ..color = Colors.black
    ..strokeWidth = 5;

  final List<StylusStroke> strokes = List<StylusStroke>();

  int _strokePointerCount = 0;

  int get strokePointerCount => _strokePointerCount;

  Paint _paint = defaultPaint;

  Paint get paint => _paint;

  set paint(Paint paint) {
    assert(paint != null);
    _paint = paint;
  }

  StylusStroke _s;

  void append(StylusPointer pointer) {
    if (pointer.p == 0) {
      _s = null; // Ensure no stroke
      return;
    }

    if (_s == null) {
      _s = StylusStroke(paint); // Stroke begins with pointer down
      strokes.add(_s);
    }
    _s.pointers.add(pointer);
    _strokePointerCount++;
  }

  void clear() {
    strokes.clear();
    _strokePointerCount = 0;
  }
}