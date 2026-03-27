import 'package:flutter/material.dart';

import '../../services/map_service.dart';
import '../../widgets/maps/map_view_widget.dart';

/// Full-screen Google Map display with safe controller lifecycle.
///
/// This screen owns a [MapService] instance, passes its [onMapCreated]
/// callback to the child [MapViewWidget], and disposes the controller
/// when the screen is removed from the tree.
///
/// Future additions (markers, search, location tracking) should extend
/// this screen or compose it with additional overlay widgets.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  /// Owns the GoogleMapController lifecycle for this screen.
  final MapService _mapService = MapService();

  /// Tracks whether the map's native view has finished initialising.
  bool _mapReady = false;

  // ── Lifecycle ────────────────────────────────────────────────────────

  @override
  void dispose() {
    _mapService.dispose();
    super.dispose();
  }

  // ── Callbacks ────────────────────────────────────────────────────────

  void _onMapCreated(controller) {
    _mapService.onMapCreated(controller);
    if (mounted) {
      setState(() => _mapReady = true);
    }
  }

  // ── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Show the map widget.  A loading indicator overlays until the native
    // map fires onMapCreated — this prevents a jarring blank rectangle.
    return Stack(
      children: [
        MapViewWidget(
          onMapCreated: _onMapCreated,
        ),
        if (!_mapReady)
          const Center(
            child: CircularProgressIndicator.adaptive(),
          ),
      ],
    );
  }
}
