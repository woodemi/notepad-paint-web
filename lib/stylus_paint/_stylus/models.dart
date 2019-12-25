import 'dart:ui';

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