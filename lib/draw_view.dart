import 'dart:ui';

import 'package:draw/blind_view.dart';
import 'package:draw/stroke.dart';
import 'package:draw/stroke_options.dart';
import 'package:draw/stroke_painter.dart';
import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

class DrawView extends StatefulWidget {
  const DrawView({super.key});

  @override
  State<DrawView> createState() => _DrawViewState();
}

class _DrawViewState extends State<DrawView> {
  final lines = ValueNotifier(<Stroke>[]);
  final line = ValueNotifier<Stroke?>(null);

  void clear() => setState(() {
        lines.value = [];
        line.value = null;
      });

  void onPointerDown(PointerDownEvent details) {
    final supportsPressure = details.kind == PointerDeviceKind.stylus;
    options = options.copyWith(simulatePressure: !supportsPressure);

    final localPosition = details.localPosition;
    final point = PointVector(
      localPosition.dx,
      localPosition.dy,
      supportsPressure ? details.pressure : null,
    );

    line.value = Stroke([point]);
  }

  void onPointerMove(PointerMoveEvent details) {
    final supportsPressure = details.pressureMin < 1;
    final localPosition = details.localPosition;
    final point = PointVector(
      localPosition.dx,
      localPosition.dy,
      supportsPressure ? details.pressure : null,
    );

    line.value = Stroke([...line.value!.points, point]);
  }

  void onPointerUp(PointerUpEvent details) {
    lines.value = [...lines.value, line.value!];
    line.value = null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Column(
        children: [
          Expanded(
              child: Listener(
            onPointerDown: onPointerDown,
            onPointerMove: onPointerMove,
            onPointerUp: onPointerUp,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ValueListenableBuilder(
                    valueListenable: lines,
                    builder: (context, lines, _) {
                      return CustomPaint(
                        painter: StrokePainter(
                          isBlindMode: false,
                          color: colorScheme.onSurface,
                          lines: lines,
                          options: options,
                        ),
                      );
                    },
                  ),
                ),
                Positioned.fill(
                  child: ValueListenableBuilder(
                    valueListenable: line,
                    builder: (context, line, _) {
                      return CustomPaint(
                        painter: StrokePainter(
                          isBlindMode: false,
                          color: colorScheme.onSurface,
                          lines: line == null ? [] : [line],
                          options: options,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          )),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => BlindView(lines: lines.value)));
            },
            child: const Text('Show'),
          )
        ],
      ),
    );
  }
}
