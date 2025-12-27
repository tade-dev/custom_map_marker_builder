## [1.0.0] - 2025-12-22
### Added
- **Intelligent Caching System**: `MarkerCache` with TTL, memory-aware cleanup, and performance statistics.
- **Batch Generation**: `fromWidgetBatch` and `fromWidgetMap` and parallel processing for creating multiple markers efficiently.
- **SVG Support**: Native SVG rendering using `flutter_svg`.
- **Network & Asset Helpers**: Simplified methods for loading images from network and assets.
- **Animation Support**: `AnimatedMarkerBuilder` for creating animated markers from widgets.
- **Clustering**: `MarkerClusterBuilder` for creating high-performance cluster icons.
- **Error Handling**: Comprehensive exception system with timeouts and fallback mechanisms.
- **Quality Presets**: `MarkerQuality` enum for easy resolution control.
- **Platform Optimizations**: Automated adjustments for Web and Native platforms.

### Improved
- Robust off-screen rendering with better frame synchronization.
- Thread-safe overlay management for parallel batch processing.
- Comprehensive documentation and expanded example app.

## [0.0.4] - 2025-05-21
### Fixed
- Eliminated initial marker flicker by replacing `Future.delayed` with `addPostFrameCallback`, ensuring accurate rendering timing without layout artifacts.

### Improved
- More stable off-screen widget rendering for marker generation.
- Cleaner internal marker capture logic to avoid frame timing issues on app startup.

### Thanks
- Special thanks to @TyBarthel for reporting the flicker issue and suggesting the fix.

## [0.0.3+1] - 2025-04-15
### Fixed
- Resolved issue where custom markers appeared visually detached from map coordinates by correctly setting the `anchor` to `Offset(0.5, 1.0)`.
- Improved marker alignment for better tap interaction and UI consistency.

### Updated
- Recommended widget sizing to prevent overflow and ensure proper placement on the map.
- General code cleanup and documentation enhancements for better developer experience.

## [0.0.3] - 2025-04-15
### Fixed
- Resolved issue where custom markers appeared visually detached from map coordinates by correctly setting the `anchor` to `Offset(0.5, 1.0)`.
- Improved marker alignment for better tap interaction and UI consistency.

### Updated
- Recommended widget sizing to prevent overflow and ensure proper placement on the map.
- General code cleanup and documentation enhancements for better developer experience.

## [0.0.2] - 2025-04-12
### Added
- Initial release of `custom_marker_builder`.
- Supports generating Google Maps markers from Flutter widgets using `RepaintBoundary`.
- Simple API to convert widgets into `BitmapDescriptor` for use with `google_maps_flutter`.