import 'dart:ui';

import 'package:draw/screens/blind_view.dart';
import 'package:draw/config/stroke.dart';
import 'package:draw/config/stroke_options.dart';
import 'package:draw/widgets/stroke_painter.dart';
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

  void navigatOnPress() {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => BlindView(lines: lines.value)));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Área de desenho',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        backgroundColor: const Color(0xff8257E5),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.cleaning_services_outlined,
              color: Colors.white,
              size: 30,
            ),
            tooltip: 'Limpar desenho',
          ),
          IconButton(
            onPressed: navigatOnPress,
            icon: const Icon(
              Icons.switch_access_shortcut_add_rounded,
              color: Colors.white,
              size: 30,
            ),
            tooltip: 'Submeter desenho',
          ),
        ],
      ),
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
        ],
      ),
    );
  }
}
