# Custom Map Marker Builder

A Flutter package for creating dynamic custom map markers using standard Flutter widgets. Convert any widget into a Google Maps marker with pixel-perfect rendering.

## Features

- Create custom markers from any Flutter widget (text, images, icons)
- Widget-based marker design for complete customization
- High-quality rendering using `RepaintBoundary`
- Seamless integration with `google_maps_flutter`

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  custom_marker_builder: 1.0.0
```

## Usage

### 1. Import the package

```dart
import 'package:custom_marker_builder/custom_marker_builder.dart';
```

### 2. Create a widget for your marker

```dart
class CustomMarkerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black26)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_gas_station, color: Colors.green, size: 30),
          SizedBox(width: 4),
          Text("₦640", style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
```

### 3. Convert the widget to a marker icon

```dart
final markerKey = GlobalKey();

// Capture the widget
RepaintBoundary(
  key: markerKey,
  child: CustomMarkerWidget(),
);

// Convert to BitmapDescriptor
final markerIcon = await CustomMarkerBuilder.fromWidget(markerKey);

// Create marker
final marker = Marker(
  markerId: MarkerId('myMarker'),
  position: LatLng(6.5244, 3.3792),
  icon: markerIcon,
);
```

### 4. Add to Google Maps

```dart
GoogleMap(
  initialCameraPosition: CameraPosition(
    target: LatLng(6.5244, 3.3792),
    zoom: 12,
  ),
  markers: {marker},
)
```

## Example

Check the `/example` folder for a complete implementation.

## License

MIT
