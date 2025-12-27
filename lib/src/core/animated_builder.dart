import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'marker_builder.dart';

class AnimatedMarkerBuilder {
  static Stream<BitmapDescriptor> fromAnimatedWidget({
    required BuildContext context,
    required Widget Function(double animationValue) builder,
    required Duration duration,
    int frameRate = 30,
    bool loop = true,
    Curve curve = Curves.linear,
  }) async* {
    final frameCount = (duration.inMilliseconds / 1000 * frameRate).round();
    final frames = <BitmapDescriptor>[];

    for (var i = 0; i < frameCount; i++) {
      final t = i / (frameCount - 1);
      final value = curve.transform(t);
      if (!context.mounted) break;
      final descriptor = await CustomMapMarkerBuilder.fromWidget(
        context: context,
        marker: builder(value),
      );
      frames.add(descriptor);
      yield descriptor;
    }

    if (loop && context.mounted) {
      while (true) {
        for (final frame in frames) {
          if (!context.mounted) break;
          await Future.delayed(
              Duration(milliseconds: (1000 / frameRate).round()));
          yield frame;
        }
        if (!context.mounted) break;
      }
    }
  }

  static Future<List<BitmapDescriptor>> generateFrames({
    required BuildContext context,
    required Widget Function(int frame) builder,
    required int frameCount,
    Size? size,
  }) async {
    final frames = <BitmapDescriptor>[];
    for (var i = 0; i < frameCount; i++) {
      if (!context.mounted) break;
      final descriptor = await CustomMapMarkerBuilder.fromWidget(
        context: context,
        marker: builder(i),
        targetSize: size,
      );
      frames.add(descriptor);
    }
    return frames;
  }
}
