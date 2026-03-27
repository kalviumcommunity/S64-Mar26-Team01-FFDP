import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../models/location_model.dart';

/// Result of a permission request, providing both the raw permission value
/// and a human-readable status for UI consumption.
enum LocationPermissionStatus {
  /// Permission granted — location can be accessed.
  granted,

  /// User denied the permission request (can ask again).
  denied,

  /// User permanently denied — must open app settings manually.
  permanentlyDenied,

  /// The device's location service (GPS) is turned off.
  serviceDisabled,
}

/// Pure-service class for location access.
///
/// Responsibilities:
///  • Check / request location permissions
///  • Fetch current device position (one-shot)
///  • Provide a position stream for real-time tracking
///  • Return typed [AppLocation] or `null` — never throws to callers
///
/// This class contains **no UI logic** and is safe to use from any layer.
class LocationService {
  // ── Permission Handling ────────────────────────────────────────────

  /// Returns `true` if the device's location service (GPS/network) is on.
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      debugPrint('📍 LocationService: isLocationServiceEnabled error: $e');
      return false;
    }
  }

  /// Checks the current permission status without triggering a system dialog.
  Future<LocationPermissionStatus> checkPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationPermissionStatus.serviceDisabled;
      }

      final permission = await Geolocator.checkPermission();
      return _mapPermission(permission);
    } catch (e) {
      debugPrint('📍 LocationService: checkPermission error: $e');
      return LocationPermissionStatus.denied;
    }
  }

  /// Requests location permission from the user.
  ///
  /// Returns the resulting [LocationPermissionStatus].
  /// If the permission was already permanently denied, this returns
  /// [LocationPermissionStatus.permanentlyDenied] immediately — it does
  /// **not** trigger an infinite request loop.
  Future<LocationPermissionStatus> requestPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('📍 LocationService: location services are off');
        return LocationPermissionStatus.serviceDisabled;
      }

      // Check current state first to avoid re-requesting after permanent denial.
      final current = await Geolocator.checkPermission();
      if (current == LocationPermission.deniedForever) {
        debugPrint('📍 LocationService: permanently denied — skipping request');
        return LocationPermissionStatus.permanentlyDenied;
      }

      // Only request if not already granted.
      if (current == LocationPermission.always ||
          current == LocationPermission.whileInUse) {
        return LocationPermissionStatus.granted;
      }

      final requested = await Geolocator.requestPermission();
      final status = _mapPermission(requested);
      debugPrint('📍 LocationService: permission result → $status');
      return status;
    } catch (e) {
      debugPrint('📍 LocationService: requestPermission error: $e');
      return LocationPermissionStatus.denied;
    }
  }

  /// Opens the device's app-settings page so the user can manually grant
  /// location permission after a permanent denial.
  Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (e) {
      debugPrint('📍 LocationService: openAppSettings error: $e');
      return false;
    }
  }

  /// Opens the device's location-settings page so the user can enable GPS.
  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (e) {
      debugPrint('📍 LocationService: openLocationSettings error: $e');
      return false;
    }
  }

  // ── Location Fetching ─────────────────────────────────────────────

  /// Fetches the current device position as an [AppLocation].
  ///
  /// Returns `null` if:
  ///  • permission is not granted
  ///  • location services are disabled
  ///  • the GPS read fails for any reason
  ///
  /// Uses [LocationAccuracy.high] by default. The [timeLimit] prevents
  /// indefinite blocking on slow GPS hardware.
  Future<AppLocation?> getCurrentLocation({
    Duration timeLimit = const Duration(seconds: 10),
  }) async {
    try {
      final status = await checkPermission();
      if (status != LocationPermissionStatus.granted) {
        debugPrint('📍 LocationService: cannot fetch — permission is $status');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: timeLimit,
      );

      final location = AppLocation.fromPosition(position);
      debugPrint('📍 LocationService: got position $location');
      return location;
    } on TimeoutException {
      debugPrint('📍 LocationService: getCurrentPosition timed out');
      return null;
    } catch (e) {
      debugPrint('📍 LocationService: getCurrentPosition error: $e');
      return null;
    }
  }

  // ── Streaming ─────────────────────────────────────────────────────

  /// Returns a stream of [AppLocation] updates for real-time tracking.
  ///
  /// The stream emits at the interval controlled by [distanceFilter] (metres).
  /// Callers are responsible for cancelling the subscription.
  ///
  /// Returns `null` if permission is not granted.
  Future<Stream<AppLocation>?> getPositionStream({
    int distanceFilter = 10,
  }) async {
    final status = await checkPermission();
    if (status != LocationPermissionStatus.granted) {
      debugPrint('📍 LocationService: stream unavailable — permission $status');
      return null;
    }

    final positionStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilter,
      ),
    );

    return positionStream.map(
      (position) => AppLocation.fromPosition(position),
    );
  }

  // ── Internal ──────────────────────────────────────────────────────

  /// Maps the geolocator [LocationPermission] enum to our app-level enum.
  LocationPermissionStatus _mapPermission(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return LocationPermissionStatus.granted;
      case LocationPermission.deniedForever:
        return LocationPermissionStatus.permanentlyDenied;
      case LocationPermission.denied:
      case LocationPermission.unableToDetermine:
        return LocationPermissionStatus.denied;
    }
  }
}
