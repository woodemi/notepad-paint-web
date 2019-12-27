import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:notepad_core/notepad_core.dart';

import 'stylus_paint/stylus_paint.dart';

class NotepadDetailPage extends StatefulWidget {
  final scanResult;

  final stylusPaintController = StylusPainterController();

  NotepadDetailPage(this.scanResult);

  @override
  State<StatefulWidget> createState() => _NotepadDetailPageState();
}

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

_toast(String msg) => _scaffoldKey.currentState
    .showSnackBar(SnackBar(content: Text(msg), duration: Duration(seconds: 2)));

class _NotepadDetailPageState extends State<NotepadDetailPage> implements NotepadClientCallback {
  @override
  void initState() {
    super.initState();
    notepadConnector.connectionChangeHandler = _handleConnectionChange;
    notepadConnector.connect(widget.scanResult);
  }

  @override
  void dispose() {
    super.dispose();
    notepadConnector.disconnect();
    notepadConnector.connectionChangeHandler = null;
  }

  NotepadClient _notepadClient;

  void _handleConnectionChange(NotepadClient client, NotepadConnectionState state) {
    print('_handleConnectionChange $client $state');
    if (state == NotepadConnectionState.connected) {
      client.setMode(NotepadMode.Sync).then((onValue) {
        _notepadClient = client;
        _notepadClient.callback = this;
      });
    } else {
      _notepadClient?.callback = null;
      _notepadClient = null;
    }
  }

  @override
  void handlePointer(List<NotePenPointer> list) {
    syncPointerStreamController.addStream(Stream.fromIterable(list));
  }

  @override
  void handleEvent(NotepadEvent notepadEvent) {
    print('handleEvent $notepadEvent');
    _toast(notepadEvent.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('NotepadDetailPage'),
        actions: <Widget>[
          FlatButton(
            child: Icon(Icons.exposure_plus_1),
            onPressed: () {
              widget.stylusPaintController.paint.strokeWidth++;
            },
          ),
          FlatButton(
            child: Icon(Icons.format_color_text),
            onPressed: () {
              widget.stylusPaintController.paint.color = Colors.red;
            },
          ),
          FlatButton(
            child: Icon(Icons.clear),
            onPressed: () {
              widget.stylusPaintController.paint = StylusPainterController.defaultPaint;
            },
          )
        ],
      ),
      body: Center(
        child: PaintArea.of(
          controller: widget.stylusPaintController,
          srcSize: Size(14800, 21000),
          dstSize: window.physicalSize,
          backgroundColor: Color(0xFFFEFEFE),
        ),
      ),
    );
  }
}

class PaintArea extends StatefulWidget {
  final StylusPainterController controller;

  final double scaleRatio;

  final Size paintSize;

  final Color backgroundColor;

  PaintArea({
    this.controller,
    this.scaleRatio,
    this.paintSize,
    this.backgroundColor,
  })
      : assert(scaleRatio != null),
        assert(paintSize != null);

  factory PaintArea.of({
    StylusPainterController controller,
    Size srcSize,
    Size dstSize,
    Color backgroundColor,
  }) {
    final paintScale = min(dstSize.width / srcSize.width, dstSize.height / srcSize.height);
    final scaleRatio = paintScale / window.devicePixelRatio;
    final paintSize = srcSize * scaleRatio;
    return PaintArea(
      controller: controller,
      scaleRatio: scaleRatio,
      paintSize: paintSize,
      backgroundColor: backgroundColor,
    );
  }

  @override
  State<StatefulWidget> createState() => _PaintAreaState();
}

final syncPointerStreamController = StreamController<NotePenPointer>();

class _PaintAreaState extends State<PaintArea> {
  StreamSubscription<StylusPointer> _streamSubscription;

  @override
  void initState() {
    super.initState();
    final stylusPointerStream = syncPointerStreamController.stream.map((p) => StylusPointer.fromMap(p.toMap()));
    _streamSubscription = stylusPointerStream.listen((onData) {
      setState(() => widget.controller.append(onData));
    });
  }

  @override
  void dispose() {
    super.dispose();
    _streamSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor,
      constraints: BoxConstraints.loose(widget.paintSize),
      child: Stack(
        children: <Widget>[
          CustomPaint(
            size: widget.paintSize,
            painter: PathStrokePainter(
              widget.controller,
              widget.scaleRatio,
            ),
          ),
          CustomPaint(
            size: widget.paintSize,
            painter: CircleIndicatePainter(
              widget.controller,
              widget.scaleRatio,
            ),
          )
        ],
      ),
    );
  }
}