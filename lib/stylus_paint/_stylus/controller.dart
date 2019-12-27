import 'dart:ui';

import 'package:flutter/material.dart';

import 'models.dart';

class StylusPainterController {
  static Paint get defaultPaint => Paint()
    ..color = Colors.black
    ..strokeWidth = 5;

  /// All pointers
  final List<StylusPointer> pointers = List<StylusPointer>();

  /// Pointers whose pressure > 0
  final List<StylusStroke> strokes = List<StylusStroke>();

  Paint _paint = defaultPaint;

  Paint get paint => _paint;

  set paint(Paint paint) {
    assert(paint != null);
    _paint = paint;
  }

  StylusStroke _s;

  void append(StylusPointer pointer) {
    pointers.add(pointer);

    if (pointer.p == 0) {
      _s = null; // Ensure no stroke
      return;
    }

    if (_s == null) {
      _s = StylusStroke(paint); // Stroke begins with pointer down
      strokes.add(_s);
    }
    _s.pointers.add(pointer);
  }
}