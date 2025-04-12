import 'package:custom_marker_builder/custom_marker_builder.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final LatLng _location = const LatLng(6.5244, 3.3792);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MapSample(location: _location),
    );
  }
}

class MapSample extends StatefulWidget {
  final LatLng location;
  const MapSample({required this.location});

  @override
  State<MapSample> createState() => _MapSampleState();
}

class _MapSampleState extends State<MapSample> {
  late GoogleMapController controller;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMarker());
  }

  Future<void> _loadMarker() async {
    /// Creates a marker from a widget.
    final bitmap = await CustomMapMarkerBuilder.fromWidget(
      context: context,
      marker: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black26)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.home, color: Colors.blue),
            Text("₦550", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );

    final marker = Marker(
      markerId: const MarkerId("dynamic_marker"),
      position: widget.location,
      icon: bitmap,
    );

    setState(() => _markers.add(marker));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: widget.location,
          zoom: 15,
        ),
        markers: _markers,
        onMapCreated: (con) => con = controller,
      ),
    );
  }
}
