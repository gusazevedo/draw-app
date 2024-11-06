import 'package:perfect_freehand/perfect_freehand.dart';

StrokeOptions options = StrokeOptions(
  size: 15,
  thinning: 1,
  smoothing: 0.5,
  streamline: 0.5,
  start: StrokeEndOptions.start(
    taperEnabled: true,
    customTaper: 0.0,
    cap: true,
  ),
  end: StrokeEndOptions.end(
    taperEnabled: true,
    customTaper: 0.0,
    cap: true,
  ),
  simulatePressure: true,
  isComplete: false,
);
