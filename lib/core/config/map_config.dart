import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Centralized configuration for Google Maps across the app.
///
/// All map-related defaults live here so they can be tuned in one place.
/// Future environment-specific overrides (dev / staging / prod) can extend
/// this class or read from a remote config source.
class MapConfig {
  MapConfig._();

  // ── Default Camera Position ──────────────────────────────────────────
  /// Default latitude (Mumbai, India — chosen as a sensible app-level default).
  static const double defaultLatitude = 19.0760;

  /// Default longitude.
  static const double defaultLongitude = 72.8777;

  /// Default zoom level (city-level view).
  static const double defaultZoom = 14.0;

  /// Pre-built [CameraPosition] combining the defaults above.
  static const CameraPosition defaultCameraPosition = CameraPosition(
    target: LatLng(defaultLatitude, defaultLongitude),
    zoom: defaultZoom,
  );

  // ── Map Type ─────────────────────────────────────────────────────────
  /// Default map rendering style.
  static const MapType defaultMapType = MapType.normal;

  // ── UI Settings ──────────────────────────────────────────────────────
  /// Whether to show the zoom +/- buttons on the map.
  static const bool zoomControlsEnabled = true;

  /// Whether the built-in compass icon is visible.
  static const bool compassEnabled = true;

  /// Whether the "my location" blue-dot button is visible.
  static const bool myLocationButtonEnabled = true;

  /// Whether the user's location blue dot is rendered.
  static const bool myLocationEnabled = true;

  /// Whether the default Google Maps toolbar appears on marker taps.
  static const bool mapToolbarEnabled = false;

  // ── Constraints ──────────────────────────────────────────────────────
  /// Minimum zoom the user can pinch out to.
  static const double minZoom = 4.0;

  /// Maximum zoom the user can pinch in to.
  static const double maxZoom = 20.0;

  /// Combined min/max as [MinMaxZoomPreference] for the widget.
  static const MinMaxZoomPreference zoomPreference =
      MinMaxZoomPreference(minZoom, maxZoom);

  // ── Location Defaults ─────────────────────────────────────────────
  /// Zoom level used when centring on the user's location.
  static const double userLocationZoom = 16.0;

  /// How long to wait for a GPS fix before giving up.
  static const Duration locationFetchTimeout = Duration(seconds: 10);
}
