import 'package:flutter/foundation.dart';
import 'quality.dart';

class MarkerBuilderConfig {
  final MarkerQuality defaultQuality;
  final Duration defaultCacheDuration;
  final Duration renderTimeout;
  final bool enableCaching;
  final bool enableBatchOptimization;
  final int maxCacheSize;
  final VoidCallback? onCacheFull;

  const MarkerBuilderConfig({
    this.defaultQuality = MarkerQuality.high,
    this.defaultCacheDuration = const Duration(hours: 1),
    this.renderTimeout = const Duration(seconds: 5),
    this.enableCaching = true,
    this.enableBatchOptimization = true,
    this.maxCacheSize = 100,
    this.onCacheFull,
  });

  static MarkerBuilderConfig? _global;

  static void setGlobal(MarkerBuilderConfig config) {
    _global = config;
  }

  static MarkerBuilderConfig get global =>
      _global ?? const MarkerBuilderConfig();
}
