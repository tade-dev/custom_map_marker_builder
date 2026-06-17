import 'package:custom_marker_builder/custom_marker_builder.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MapSample(location: LatLng(6.5244, 3.3792)),
    );
  }
}

class MapSample extends StatefulWidget {
  final LatLng location;
  const MapSample({super.key, required this.location});

  @override
  State<MapSample> createState() => _MapSampleState();
}

class _MapSampleState extends State<MapSample> {
  // ignore: unused_field
  late GoogleMapController controller;
  final Set<Marker> _markers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMarkers());
  }

  Future<void> _loadMarkers() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    _markers.clear();

    try {
      final double lat = widget.location.latitude;
      final double lng = widget.location.longitude;
      const double step = 0.002;

      // 1. Basic Widget Marker
      if (!mounted) return;
      final basicBitmap = await CustomMapMarkerBuilder.fromWidget(
        context: context,
        marker:
            _buildLabeledMarker("Basic Widget", Icons.location_on, Colors.blue),
        cacheKey: "basic_widget",
      );

      _markers.add(Marker(
        markerId: const MarkerId("basic"),
        position: LatLng(lat + step * 2, lng),
        icon: basicBitmap,
      ));

      // 2. Network Image Marker
      if (!mounted) return;
      final networkBitmap = await CustomMapMarkerBuilder.fromNetworkImage(
        context: context,
        imageUrl:
            "https://raw.githubusercontent.com/flutter/website/main/src/assets/images/docs/catalog-widget-placeholder.png",
        size: const Size(60, 60),
        cacheKey: "network_img",
      );

      _markers.add(Marker(
        markerId: const MarkerId("network"),
        position: LatLng(lat + step, lng),
        icon: networkBitmap,
        infoWindow: const InfoWindow(title: "Network Image"),
      ));

      // 3. SVG Marker
      const svgString = '''
<svg width="100" height="100" viewBox="0 0 100 100">
  <rect width="100" height="100" rx="20" fill="#FF5722" />
  <circle cx="50" cy="50" r="30" fill="white" />
  <text x="50" y="55" font-size="20" text-anchor="middle" fill="#FF5722" font-family="Arial">SVG</text>
</svg>
''';
      if (!mounted) return;
      final svgBitmap = await CustomMapMarkerBuilder.fromSvg(
        context: context,
        svgString: svgString,
        size: const Size(60, 60),
        cacheKey: "svg_marker",
      );

      _markers.add(Marker(
        markerId: const MarkerId("svg"),
        position: LatLng(lat, lng),
        icon: svgBitmap,
      ));

      // 4. Cluster Marker
      if (!mounted) return;
      final clusterBitmap = await CustomMapMarkerBuilder.fromWidget(
        context: context,
        marker: MarkerClusterBuilder.buildClusterMarker(
          count: 99,
          backgroundColor: Colors.green,
        ),
        cacheKey: "cluster_99",
      );

      _markers.add(Marker(
        markerId: const MarkerId("cluster"),
        position: LatLng(lat - step, lng),
        icon: clusterBitmap,
      ));

      // 5. Batch Markers (Spread horizontally)
      final batchWidgets = {
        "Star": _buildLabeledMarker("Batch 1", Icons.star, Colors.orange),
        "Heart": _buildLabeledMarker("Batch 2", Icons.favorite, Colors.red),
        "Bell":
            _buildLabeledMarker("Batch 3", Icons.notifications, Colors.purple),
      };

      if (!mounted) return;
      final batchBitmaps = await BatchMarkerBuilder.fromWidgetMap(
        context: context,
        markers: batchWidgets,
      );

      var i = 1;
      batchBitmaps.forEach((key, bitmap) {
        _markers.add(Marker(
          markerId: MarkerId("batch_$key"),
          position: LatLng(lat - step * 2, lng + (i - 2) * step),
          icon: bitmap,
        ));
        i++;
      });
    } catch (e) {
      debugPrint("Error loading markers: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildLabeledMarker(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 2),
        boxShadow: const [
          BoxShadow(blurRadius: 4, color: Colors.black26, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Marker Builder Showcase"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.location,
              zoom: 14.5,
            ),
            markers: _markers,
            onMapCreated: (con) => controller = con,
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text("Generating Showcase Markers..."),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loadMarkers,
        label: const Text("Refresh Demo"),
        icon: const Icon(Icons.refresh),
      ),
    );
  }
}
