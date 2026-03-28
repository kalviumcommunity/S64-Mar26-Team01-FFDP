import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Lightweight, immutable model representing a geographic location.
///
/// Decouples the rest of the app from the `geolocator` [Position] type, making
/// it easy to swap location providers or add serialization later.
class AppLocation {
  /// Latitude in degrees.
  final double latitude;

  /// Longitude in degrees.
  final double longitude;

  /// Accuracy of the reading in metres (if available).
  final double? accuracy;

  /// When this reading was taken.
  final DateTime timestamp;

  const AppLocation({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    required this.timestamp,
  });

  // ── Factories ───────────────────────────────────────────────────────

  /// Creates an [AppLocation] from a geolocator [Position].
  factory AppLocation.fromPosition(Position position) {
    return AppLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      timestamp: position.timestamp,
    );
  }

  /// Creates an [AppLocation] from raw coordinates (timestamp defaults to now).
  factory AppLocation.fromLatLng(double lat, double lng) {
    return AppLocation(
      latitude: lat,
      longitude: lng,
      timestamp: DateTime.now(),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────

  /// Converts this location to a Google Maps [LatLng] for use with the SDK.
  LatLng toLatLng() => LatLng(latitude, longitude);

  @override
  String toString() =>
      'AppLocation(lat: $latitude, lng: $longitude, acc: $accuracy)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppLocation &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}
