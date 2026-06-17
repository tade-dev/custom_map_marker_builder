import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'marker_builder.dart';

class BatchMarkerBuilder {
  static Future<List<BitmapDescriptor>> fromWidgetBatch({
    required BuildContext context,
    required List<Widget> markers,
    List<String>? cacheKeys,
    ImageConfiguration? imageConfiguration,
    void Function(int completed, int total)? onProgress,
  }) async {
    final total = markers.length;
    var completed = 0;

    final futures = <Future<BitmapDescriptor?>>[];

    for (var i = 0; i < markers.length; i++) {
      final future = CustomMapMarkerBuilder.fromWidget(
        context: context,
        marker: markers[i],
        cacheKey:
            cacheKeys != null && cacheKeys.length > i ? cacheKeys[i] : null,
        imageConfiguration: imageConfiguration,
      ).then((value) {
        completed++;
        onProgress?.call(completed, total);
        return value as BitmapDescriptor?;
      }).catchError((_) {
        completed++;
        onProgress?.call(completed, total);
        return null;
      });
      futures.add(future);
    }

    final results = await Future.wait(futures);
    return results.whereType<BitmapDescriptor>().toList();
  }

  static Future<Map<String, BitmapDescriptor>> fromWidgetMap({
    required BuildContext context,
    required Map<String, Widget> markers,
    ImageConfiguration? imageConfiguration,
    void Function(int completed, int total)? onProgress,
  }) async {
    final keys = markers.keys.toList();
    final total = keys.length;
    var completed = 0;

    final results = <String, BitmapDescriptor>{};
    final futures = <Future<void>>[];

    for (final key in keys) {
      final futuresEntry = CustomMapMarkerBuilder.fromWidget(
        context: context,
        marker: markers[key]!,
        cacheKey: key,
        imageConfiguration: imageConfiguration,
      ).then((value) {
        results[key] = value;
        completed++;
        onProgress?.call(completed, total);
      }).catchError((_) {
        completed++;
        onProgress?.call(completed, total);
      });
      futures.add(futuresEntry);
    }

    await Future.wait(futures);
    return results;
  }
}
