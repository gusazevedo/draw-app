import 'package:draw/stroke.dart';
import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

class StrokePainter extends CustomPainter {
  const StrokePainter({
    required this.color,
    required this.lines,
    required this.options,
    required this.isBlindMode,
  });

  final Color color;
  final List<Stroke> lines;
  final StrokeOptions options;
  final bool isBlindMode;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    for (final line in lines) {
      final outlinePoints = getStroke(line.points, options: options);

      if (outlinePoints.isEmpty) {
        continue;
      } else if (outlinePoints.length < 2) {
        canvas.drawCircle(
          outlinePoints.first,
          options.size / 2,
          paint,
        );
      } else {
        final path = Path();
        path.moveTo(outlinePoints.first.dx, outlinePoints.first.dy);
        for (int i = 0; i < outlinePoints.length - 1; ++i) {
          final p0 = outlinePoints[i];
          final p1 = outlinePoints[i + 1];
          path.quadraticBezierTo(
            p0.dx,
            p0.dy,
            (p0.dx + p1.dx) / 2,
            (p0.dy + p1.dy) / 2,
          );
        }

        canvas.drawPath(path, paint);
      }
    }
  }

  Path _getStrokePath(Stroke line) {
    final outlinePoints = getStroke(line.points, options: options);
    final path = Path();
    path.moveTo(outlinePoints.first.dx, outlinePoints.first.dy);
    for (int i = 0; i < outlinePoints.length - 1; ++i) {
      final p0 = outlinePoints[i];
      final p1 = outlinePoints[i + 1];
      path.quadraticBezierTo(
        p0.dx,
        p0.dy,
        (p0.dx + p1.dx) / 2,
        (p0.dy + p1.dy) / 2,
      );
    }
    return path;
  }

  @override
  bool? hitTest(Offset position) {
    if (!isBlindMode) return super.hitTest(position);
    final paths = lines.map((line) => _getStrokePath(line));
    return paths.any((path) => path.contains(position));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
