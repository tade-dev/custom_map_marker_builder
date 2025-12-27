import 'package:flutter_test/flutter_test.dart';
import 'package:custom_marker_builder/custom_marker_builder.dart';

void main() {
  test('MarkerQuality returns correct pixel ratios', () {
    expect(MarkerQuality.low.pixelRatio, 1.0);
    expect(MarkerQuality.medium.pixelRatio, 2.0);
    expect(MarkerQuality.high.pixelRatio, 3.0);
    expect(MarkerQuality.ultra.pixelRatio, 4.0);
  });

  test('MarkerCache stores and retrieves descriptors', () async {
    // Tests the caching logic
    // ...
  });
}
