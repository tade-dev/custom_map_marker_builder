import 'package:google_maps_flutter/google_maps_flutter.dart';

class CachedMarker {
  final BitmapDescriptor descriptor;
  final DateTime expiry;
  final DateTime createdAt;

  CachedMarker({
    required this.descriptor,
    required Duration ttl,
  })  : createdAt = DateTime.now(),
        expiry = DateTime.now().add(ttl);

  bool get isExpired => DateTime.now().isAfter(expiry);
}
