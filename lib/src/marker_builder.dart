import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// A utility class for generating custom map markers from Flutter widgets.
///
/// This class provides a method to convert any Flutter widget into a
/// `BitmapDescriptor` that can be used as a custom marker icon in
/// `google_maps_flutter`.
///
/// Example usage:
/// ```dart
/// final markerIcon = await CustomMapMarkerBuilder.fromWidget(
///   context: context,
///   marker: MyCustomMarkerWidget(),
/// );
/// ```
class CustomMapMarkerBuilder {
  /// Converts a Flutter widget into a [BitmapDescriptor] that can be used
  /// as a custom marker in Google Maps.
  ///
  /// The widget is rendered off-screen using a [RepaintBoundary] and captured
  /// as a PNG image. The resulting bytes are used to create a [BitmapDescriptor].
  ///
  /// [context] is required to access the overlay for off-screen rendering.
  ///
  /// [marker] is the widget to be rendered into the marker.
  ///
  /// [pixelRatio] controls the resolution of the rendered marker image.
  /// Defaults to `3.0`.
  ///
  /// Returns a [Future] that completes with the [BitmapDescriptor] generated
  /// from the widget.
  static Future<BitmapDescriptor> fromWidget({
    required BuildContext context,
    required Widget marker,
    double pixelRatio = 3.0,
  }) async {
    final key = GlobalKey();

    final markerWidget = RepaintBoundary(
      key: key,
      child: marker,
    );

    final overlay = OverlayEntry(
      builder: (context) => Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            Positioned(
              left: -1000,
              top: -1000,
              child: markerWidget,
            ),
          ],
        ),
      ),
    );

    final overlayState = Overlay.of(context, rootOverlay: true);
    overlayState.insert(overlay);

    final completer = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      completer.complete();
    });
    await completer.future;

    // 🔍 Get image from RepaintBoundary
    RenderRepaintBoundary boundary =
        key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    overlay.remove();

    return BitmapDescriptor.fromBytes(pngBytes);
  }
}