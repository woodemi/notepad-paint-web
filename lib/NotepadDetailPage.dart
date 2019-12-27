import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

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
          dstSize: ui.window.physicalSize,
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
    final scaleRatio = paintScale / ui.window.devicePixelRatio;
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

  ui.Image _indicator;

  @override
  void initState() {
    super.initState();
    widget.controller.paint.strokeWidth = 0.5;
    loadAssetImage(AssetImage('images/indicator_pen.png')).then((onValue) {
      setState(() => _indicator = onValue);
    });
    final stylusPointerStream = syncPointerStreamController.stream.map((p) => StylusPointer.fromMap(p.toMap()));
    _streamSubscription = stylusPointerStream.timeout(Duration(milliseconds: 100)).listen((onData) {
      setState(() {
        if (!indicatorVisible) indicatorVisible = true;
        widget.controller.append(onData);
      });
    }, onError: (error) {
      if (error is TimeoutException) {
        if (indicatorVisible) setState(() => indicatorVisible = false);
      }
    });
  }

  bool indicatorVisible = false;

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
            painter: LineStrokePainter(
              widget.controller,
              widget.scaleRatio,
            ),
          ),
          if (indicatorVisible)
            _buildIndicator(),
          if (!indicatorVisible)
            AnimatedOpacity(
              opacity: 0.0,
              duration: Duration(milliseconds: 200),
              child: _buildIndicator(),
            ),
        ],
      ),
    );
  }

  Stack _buildIndicator() {
    return Stack(
      children: <Widget>[
        CustomPaint(
          size: widget.paintSize,
          painter: CircleIndicatePainter(
            widget.controller,
            widget.scaleRatio,
          )..uiPaint.style = PaintingStyle.stroke,
        ),
        if (_indicator != null)
          CustomPaint(
            size: widget.paintSize,
            painter: ImageIndicatePainter(
              widget.controller,
              widget.scaleRatio,
              _indicator,
            ),
          ),
      ],
    );
  }
}

Future<ui.Image> loadAssetImage<T>(ImageProvider<T> imageProvider) async {
  var stream = imageProvider.resolve(ImageConfiguration.empty);
  var completer = Completer<ui.Image>();
  var listener = ImageStreamListener((frame, sync) => completer.complete(frame.image));
  stream.addListener(listener);
  var image = await completer.future;
  stream.removeListener(listener);
  return image;
}