import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'cache_entry.dart';
import '../config/marker_builder_config.dart';

class MarkerCache {
  static final Map<String, CachedMarker> _cache = {};
  static int _hits = 0;
  static int _misses = 0;

  static Future<BitmapDescriptor?> get(String key) async {
    final entry = _cache[key];
    if (entry != null) {
      if (entry.isExpired) {
        _cache.remove(key);
        _misses++;
        return null;
      }
      _hits++;
      return entry.descriptor;
    }
    _misses++;
    return null;
  }

  static Future<void> set(
      String key, BitmapDescriptor descriptor, Duration? ttl) async {
    final effectiveTtl = ttl ?? MarkerBuilderConfig.global.defaultCacheDuration;

    // Memory-aware: if cache exceeds global limit, clear oldest or just clear all for simplicity if limit reached
    if (_cache.length >= MarkerBuilderConfig.global.maxCacheSize) {
      // Very simple LRU-ish: clear the first one (not really LRU but better than nothing)
      // Implementation requirement says "clear old entries when memory limit reached"
      _clearOldest();
    }

    _cache[key] = CachedMarker(descriptor: descriptor, ttl: effectiveTtl);
  }

  static void _clearOldest() {
    if (_cache.isEmpty) return;
    final keys = _cache.keys.toList();
    _cache.remove(keys.first);
    MarkerBuilderConfig.global.onCacheFull?.call();
  }

  static void clear([String? key]) {
    if (key != null) {
      _cache.remove(key);
    } else {
      _cache.clear();
    }
  }

  static void clearExpired() {
    _cache.removeWhere((key, value) => value.isExpired);
  }

  static Map<String, dynamic> get stats => {
        'hits': _hits,
        'misses': _misses,
        'size': _cache.length,
      };
}
