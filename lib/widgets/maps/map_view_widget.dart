import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/config/map_config.dart';

/// A reusable, self-contained Google Map widget.
///
/// Accepts optional overrides for initial position, map type, markers, and
/// the onMapCreated callback.  Defaults come from [MapConfig].
///
/// Wrap this widget in a parent that provides bounded constraints (e.g.
/// [Expanded], [SizedBox], or [Scaffold.body]) to avoid layout issues.
class MapViewWidget extends StatelessWidget {
  /// Initial camera position; defaults to [MapConfig.defaultCameraPosition].
  final CameraPosition initialCameraPosition;

  /// Map rendering style; defaults to [MapConfig.defaultMapType].
  final MapType mapType;

  /// Called when the native map view is ready.
  final void Function(GoogleMapController)? onMapCreated;

  /// Markers to display on the map.  Empty by default.
  final Set<Marker> markers;

  /// Polylines to display on the map.  Empty by default.
  final Set<Polyline> polylines;

  /// Called when the user taps on the map.
  final void Function(LatLng)? onTap;

  /// Called when the camera starts or stops moving.
  final void Function()? onCameraMoveStarted;

  /// Called when the camera finishes an idle state.
  final void Function()? onCameraIdle;

  const MapViewWidget({
    super.key,
    this.initialCameraPosition = MapConfig.defaultCameraPosition,
    this.mapType = MapConfig.defaultMapType,
    this.onMapCreated,
    this.markers = const <Marker>{},
    this.polylines = const <Polyline>{},
    this.onTap,
    this.onCameraMoveStarted,
    this.onCameraIdle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: GoogleMap(
        initialCameraPosition: initialCameraPosition,
        mapType: mapType,
        onMapCreated: onMapCreated,

        // Markers & overlays
        markers: markers,
        polylines: polylines,

        // Interaction callbacks
        onTap: onTap,
        onCameraMoveStarted: onCameraMoveStarted,
        onCameraIdle: onCameraIdle,

        // UI controls (from MapConfig)
        zoomControlsEnabled: MapConfig.zoomControlsEnabled,
        compassEnabled: MapConfig.compassEnabled,
        myLocationButtonEnabled: MapConfig.myLocationButtonEnabled,
        myLocationEnabled: MapConfig.myLocationEnabled,
        mapToolbarEnabled: MapConfig.mapToolbarEnabled,
        minMaxZoomPreference: MapConfig.zoomPreference,
      ),
    );
  }
}
