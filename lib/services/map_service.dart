import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../core/config/map_config.dart';

/// Service that owns the [GoogleMapController] lifecycle and marker state.
///
/// Uses a [Completer] to guarantee the controller is never accessed before
/// the native map is ready, preventing null-access crashes and race conditions.
///
/// Marker management uses stable [MarkerId]s to prevent duplication on rebuild.
///
/// Usage:
/// ```dart
/// final service = MapService();
/// // Pass service.onMapCreated as the GoogleMap callback.
/// await service.animateTo(LatLng(28.6139, 77.2090));
/// service.addMarker(Marker(markerId: MarkerId('event_1'), position: ...));
/// // When done:
/// service.dispose();
/// ```
class MapService {
  /// Completer that resolves once [onMapCreated] fires.
  final Completer<GoogleMapController> _controllerCompleter =
      Completer<GoogleMapController>();

  /// Whether [dispose] has already been called.
  bool _disposed = false;

  /// Whether the underlying controller is ready for use.
  bool get isReady => _controllerCompleter.isCompleted && !_disposed;

  // ── Marker State ──────────────────────────────────────────────────

  /// Internal marker set keyed by [MarkerId] — prevents duplicates.
  final Map<MarkerId, Marker> _markerMap = {};

  /// Stable marker ID for the user's own location pin.
  static const String _userLocationMarkerId = 'user_location';

  /// Returns the current set of markers for the [GoogleMap] widget.
  ///
  /// This getter creates a new [Set] each time, which is safe for the
  /// `GoogleMap.markers` parameter (it diffs internally by [MarkerId]).
  Set<Marker> get markers => _markerMap.values.toSet();

  // ── Lifecycle ────────────────────────────────────────────────────────

  /// Callback to pass to [GoogleMap.onMapCreated].
  ///
  /// Completes the internal [Completer] exactly once.
  void onMapCreated(GoogleMapController controller) {
    if (!_controllerCompleter.isCompleted) {
      _controllerCompleter.complete(controller);
      debugPrint('🗺️ MapService: controller ready');
    }
  }

  /// Releases the native map controller.
  ///
  /// Safe to call multiple times — subsequent calls are no-ops.
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;

    if (_controllerCompleter.isCompleted) {
      final controller = await _controllerCompleter.future;
      controller.dispose();
      debugPrint('🗺️ MapService: controller disposed');
    }
  }

  // ── Camera helpers ───────────────────────────────────────────────────

  /// Smoothly animates the camera to [target] at the given [zoom].
  ///
  /// Returns silently if the controller is not yet ready or already disposed.
  Future<void> animateTo(
    LatLng target, {
    double zoom = MapConfig.defaultZoom,
  }) async {
    if (!isReady) {
      debugPrint('🗺️ MapService: animateTo ignored — controller not ready');
      return;
    }

    final controller = await _controllerCompleter.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: zoom),
      ),
    );
  }

  /// Moves the camera instantly (no animation) to [target].
  Future<void> moveTo(
    LatLng target, {
    double zoom = MapConfig.defaultZoom,
  }) async {
    if (!isReady) return;

    final controller = await _controllerCompleter.future;
    await controller.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: zoom),
      ),
    );
  }

  /// Returns the current visible region as a [LatLngBounds], or `null`
  /// if the controller is not ready.
  Future<LatLngBounds?> getVisibleRegion() async {
    if (!isReady) return null;

    final controller = await _controllerCompleter.future;
    return controller.getVisibleRegion();
  }

  // ── Marker Management ────────────────────────────────────────────────

  /// Adds or replaces a marker.  If a marker with the same [MarkerId]
  /// already exists it is silently replaced — no duplicates are created.
  void addMarker(Marker marker) {
    _markerMap[marker.markerId] = marker;
  }

  /// Removes a single marker by its [MarkerId].
  void removeMarker(MarkerId markerId) {
    _markerMap.remove(markerId);
  }

  /// Removes all markers from the map.
  void clearMarkers() {
    _markerMap.clear();
  }

  /// Convenience method: adds / updates the user-location marker.
  ///
  /// Uses a stable ID ([_userLocationMarkerId]) so rebuilds never duplicate it.
  void updateUserLocationMarker(
    LatLng position, {
    String title = 'My Location',
    BitmapDescriptor icon = BitmapDescriptor.defaultMarker,
  }) {
    final markerId = MarkerId(_userLocationMarkerId);
    _markerMap[markerId] = Marker(
      markerId: markerId,
      position: position,
      infoWindow: InfoWindow(title: title),
      icon: icon,
      zIndex: 2, // Draw above other markers.
    );
  }
}
