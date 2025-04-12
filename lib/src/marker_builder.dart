import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// A utility class to create custom map markers using Flutter widgets.
class CustomMapMarkerBuilder {
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
        child: Center(child: markerWidget),
      ),
    );

    final overlayState = Overlay.of(context);
    overlayState.insert(overlay);

    await Future.delayed(const Duration(milliseconds: 100));

    RenderRepaintBoundary boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    overlay.remove();

    return BitmapDescriptor.bytes(pngBytes);
  }
}