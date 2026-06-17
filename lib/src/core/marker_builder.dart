import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../cache/marker_cache.dart';
import '../config/marker_builder_config.dart';
import '../config/quality.dart';
import '../exceptions/marker_exceptions.dart';

class CustomMapMarkerBuilder {
  static Future<BitmapDescriptor> fromWidget({
    required BuildContext context,
    required Widget marker,
    String? cacheKey,
    Duration? cacheDuration,
    bool useCache = true,
    ImageConfiguration? imageConfiguration,
    Size? targetSize,
    MarkerQuality? quality,
    double? customPixelRatio,
    Widget? fallbackMarker,
    BitmapDescriptor? fallbackDescriptor,
    void Function(Object error, StackTrace stack)? onError,
    Duration? renderTimeout,
  }) async {
    final effectiveConfig = MarkerBuilderConfig.global;
    final effectiveQuality = quality ?? effectiveConfig.defaultQuality;
    final effectivePixelRatio = customPixelRatio ?? effectiveQuality.pixelRatio;
    final effectiveTimeout = renderTimeout ?? effectiveConfig.renderTimeout;

    if (useCache && cacheKey != null) {
      final cached = await MarkerCache.get(cacheKey);
      if (cached != null) return cached;
    }

    if (!context.mounted) {
      throw RenderException('Context is no longer mounted');
    }

    try {
      final descriptor = await _renderWidget(
        context: context,
        marker: marker,
        targetSize: targetSize,
        pixelRatio: effectivePixelRatio,
        timeout: effectiveTimeout,
      );

      if (useCache && cacheKey != null) {
        await MarkerCache.set(cacheKey, descriptor,
            cacheDuration ?? effectiveConfig.defaultCacheDuration);
      }

      return descriptor;
    } catch (e, stack) {
      onError?.call(e, stack);

      if (fallbackMarker != null && context.mounted) {
        try {
          return await _renderWidget(
            context: context,
            marker: fallbackMarker,
            targetSize: targetSize,
            pixelRatio: effectivePixelRatio,
            timeout: effectiveTimeout,
          );
        } catch (_) {}
      }

      if (fallbackDescriptor != null) {
        return fallbackDescriptor;
      }

      if (e is MarkerBuilderException) rethrow;
      throw RenderException('Failed to render marker', e, stack);
    }
  }

  static Future<BitmapDescriptor> _renderWidget({
    required BuildContext context,
    required Widget marker,
    required double pixelRatio,
    required Duration timeout,
    Size? targetSize,
  }) async {
    final key = GlobalKey();

    Widget widgetToRender = marker;
    if (targetSize != null) {
      widgetToRender = SizedBox(
        width: targetSize.width,
        height: targetSize.height,
        child: marker,
      );
    }

    final markerWidget = RepaintBoundary(
      key: key,
      child: widgetToRender,
    );

    final overlay = OverlayEntry(
      builder: (context) => Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            Positioned(
              left: -2000,
              top: -2000,
              child: markerWidget,
            ),
          ],
        ),
      ),
    );

    final overlayState = Overlay.of(context, rootOverlay: true);
    overlayState.insert(overlay);

    try {
      final completer = Completer<void>();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!completer.isCompleted) completer.complete();
      });

      await completer.future.timeout(timeout, onTimeout: () {
        throw TimeoutException(
            'Rendering timed out after ${timeout.inSeconds}s');
      });

      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw RenderException('Could not find RenderRepaintBoundary');
      }

      if (boundary.debugNeedsLayout) {
        final c2 = Completer<void>();
        WidgetsBinding.instance.addPostFrameCallback((_) => c2.complete());
        await c2.future;
      }

      ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw RenderException('Failed to convert image to byte data');
      }

      Uint8List pngBytes = byteData.buffer.asUint8List();
      // ignore: deprecated_member_use
      return BitmapDescriptor.fromBytes(pngBytes);
    } finally {
      overlay.remove();
    }
  }

  static Future<BitmapDescriptor> fromNetworkImage({
    required BuildContext context,
    required String imageUrl,
    Size? size,
    Widget? loadingWidget,
    Widget? errorWidget,
    BoxFit fit = BoxFit.contain,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 10),
    String? cacheKey,
  }) async {
    return fromWidget(
      context: context,
      cacheKey: cacheKey ?? imageUrl,
      targetSize: size,
      renderTimeout: timeout,
      marker: Image.network(
        imageUrl,
        headers: headers,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return loadingWidget ??
              const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? const Icon(Icons.error);
        },
      ),
    );
  }

  static Future<BitmapDescriptor> fromAssetImage({
    required BuildContext context,
    required String assetPath,
    Size? size,
    BoxFit fit = BoxFit.contain,
    String? cacheKey,
  }) async {
    return fromWidget(
      context: context,
      cacheKey: cacheKey ?? assetPath,
      targetSize: size,
      marker: Image.asset(
        assetPath,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.error);
        },
      ),
    );
  }

  static Future<BitmapDescriptor> fromSvg({
    required BuildContext context,
    required String svgString,
    Size? size,
    Color? color,
    ColorFilter? colorFilter,
    BoxFit fit = BoxFit.contain,
    String? cacheKey,
  }) async {
    return fromWidget(
      context: context,
      cacheKey: cacheKey,
      targetSize: size,
      marker: SvgPicture.string(
        svgString,
        width: size?.width,
        height: size?.height,
        fit: fit,
        colorFilter: colorFilter ??
            (color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null),
      ),
    );
  }

  static Future<BitmapDescriptor> fromSvgAsset({
    required BuildContext context,
    required String assetPath,
    Size? size,
    Color? color,
    ColorFilter? colorFilter,
    BoxFit fit = BoxFit.contain,
    String? cacheKey,
  }) async {
    return fromWidget(
      context: context,
      cacheKey: cacheKey ?? assetPath,
      targetSize: size,
      marker: SvgPicture.asset(
        assetPath,
        width: size?.width,
        height: size?.height,
        fit: fit,
        colorFilter: colorFilter ??
            (color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null),
      ),
    );
  }
}
