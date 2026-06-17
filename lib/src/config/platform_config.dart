import 'package:flutter/foundation.dart';

class PlatformConfig {
  static bool? _useWebOptimization;
  static bool? _useNativeRendering;
  static int? _maxCacheSize;

  static bool get useWebOptimization => _useWebOptimization ?? kIsWeb;
  static bool get useNativeRendering => _useNativeRendering ?? !kIsWeb;
  static int get maxCacheSize => _maxCacheSize ?? (kIsWeb ? 50 : 200);

  static void configure({
    bool? webOptimization,
    bool? nativeRendering,
    int? maxCache,
  }) {
    _useWebOptimization = webOptimization;
    _useNativeRendering = nativeRendering;
    _maxCacheSize = maxCache;
  }
}
