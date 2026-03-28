import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/config/map_config.dart';
import '../../services/location_service.dart';
import '../../services/map_service.dart';
import '../../widgets/maps/map_view_widget.dart';

/// Full-screen Google Map display with location access, markers, and safe
/// controller lifecycle.
///
/// Flow:
///  1. `initState` — request location permission
///  2. Permission granted → fetch current position
///  3. Position obtained → add user marker, animate camera **once**
///  4. Permission denied / error → show the map at the default position with
///     a non-blocking info banner
///
/// All async work is fire-and-forget from `initState`; location logic is
/// **never** called inside [build]. The [_hasMovedToUser] flag prevents
/// repeated camera jumps on rebuilds.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  /// Owns the GoogleMapController lifecycle and marker state.
  final MapService _mapService = MapService();

  /// Handles permission and GPS reads — pure service, no UI.
  final LocationService _locationService = LocationService();

  /// Tracks whether the map's native view has finished initialising.
  bool _mapReady = false;

  /// `true` once we have animated the camera to the user's position.
  /// Prevents repeated jumps on subsequent rebuilds.
  bool _hasMovedToUser = false;

  /// Current location permission status, used to control UI state.
  LocationPermissionStatus _permissionStatus = LocationPermissionStatus.denied;

  /// Whether we are actively loading the user's location.
  bool _loadingLocation = false;

  // ── Lifecycle ────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _mapService.dispose();
    super.dispose();
  }

  // ── Location Flow ────────────────────────────────────────────────────

  /// Orchestrates the permission → fetch → display pipeline.
  ///
  /// Called once from [initState]. Safe to call again (e.g. retry button).
  Future<void> _initLocation() async {
    if (!mounted) return;
    setState(() => _loadingLocation = true);

    final status = await _locationService.requestPermission();
    if (!mounted) return;
    setState(() => _permissionStatus = status);

    if (status == LocationPermissionStatus.granted) {
      await _fetchAndApplyLocation();
    }

    if (mounted) {
      setState(() => _loadingLocation = false);
    }
  }

  /// Fetches the user's GPS position and updates map state.
  Future<void> _fetchAndApplyLocation() async {
    final location = await _locationService.getCurrentLocation(
      timeLimit: MapConfig.locationFetchTimeout,
    );

    if (!mounted || location == null) return;

    final latLng = location.toLatLng();

    // Add / update the user-location marker (stable MarkerId).
    _mapService.updateUserLocationMarker(latLng);

    // Animate camera exactly once.
    if (!_hasMovedToUser && _mapService.isReady) {
      await _mapService.animateTo(
        latLng,
        zoom: MapConfig.userLocationZoom,
      );
      _hasMovedToUser = true;
    }

    if (mounted) setState(() {});
  }

  // ── Callbacks ────────────────────────────────────────────────────────

  void _onMapCreated(controller) {
    _mapService.onMapCreated(controller);

    if (mounted) {
      setState(() => _mapReady = true);
    }

    // If the location was fetched before the map was ready, apply now.
    if (_permissionStatus == LocationPermissionStatus.granted &&
        !_hasMovedToUser) {
      _fetchAndApplyLocation();
    }
  }

  /// Called when the user taps on the map — adds a custom pin.
  void _onMapTap(latLng) {
    _mapService.addMarker(
      Marker(
        markerId: MarkerId('tap_${latLng.latitude}_${latLng.longitude}'),
        position: latLng,
        infoWindow: InfoWindow(
          title: 'Custom Pin',
          snippet: '${latLng.latitude.toStringAsFixed(4)}, '
              '${latLng.longitude.toStringAsFixed(4)}',
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  // ── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        centerTitle: true,
        actions: [
          // Refresh-location button.
          IconButton(
            icon: const Icon(Icons.my_location),
            tooltip: 'Centre on my location',
            onPressed: _loadingLocation
                ? null
                : () {
                    _hasMovedToUser = false;
                    _initLocation();
                  },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final bool locationAllowed =
        _permissionStatus == LocationPermissionStatus.granted;

    return Stack(
      children: [
        // ── Map ────────────────────────────────────────────────────
        MapViewWidget(
          onMapCreated: _onMapCreated,
          markers: _mapService.markers,
          onTap: _onMapTap,
          myLocationEnabled: locationAllowed,
          myLocationButtonEnabled: locationAllowed,
        ),

        // ── Loading overlay (map not yet ready) ────────────────────
        if (!_mapReady)
          const Center(child: CircularProgressIndicator.adaptive()),

        // ── Loading location indicator ─────────────────────────────
        if (_mapReady && _loadingLocation)
          const Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: Center(
              child: _PillChip(
                icon: Icons.gps_fixed,
                label: 'Locating…',
              ),
            ),
          ),

        // ── Permission banners ─────────────────────────────────────
        if (_mapReady && !_loadingLocation && !locationAllowed)
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: _PermissionBanner(
              status: _permissionStatus,
              onRetry: _initLocation,
              onOpenSettings: _locationService.openAppSettings,
              onOpenLocationSettings: _locationService.openLocationSettings,
            ),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Private helper widgets — kept in the same file for locality.
// ═══════════════════════════════════════════════════════════════════════

/// Small pill-shaped chip used for status messages.
class _PillChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PillChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(20),
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Icon(icon, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            Text(label, style: theme.textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}

/// Banner shown when location permission is not granted.
class _PermissionBanner extends StatelessWidget {
  final LocationPermissionStatus status;
  final VoidCallback onRetry;
  final Future<bool> Function() onOpenSettings;
  final Future<bool> Function() onOpenLocationSettings;

  const _PermissionBanner({
    required this.status,
    required this.onRetry,
    required this.onOpenSettings,
    required this.onOpenLocationSettings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (String message, String actionLabel, VoidCallback action) =
        switch (status) {
      LocationPermissionStatus.permanentlyDenied => (
          'Location permanently denied. Open settings to enable.',
          'Open Settings',
          () => onOpenSettings(),
        ),
      LocationPermissionStatus.serviceDisabled => (
          'Location services are turned off.',
          'Open Location Settings',
          () => onOpenLocationSettings(),
        ),
      _ => (
          'Location permission is required to show your position.',
          'Grant Permission',
          onRetry,
        ),
    };

    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(12),
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(Icons.location_off,
                color: theme.colorScheme.onErrorContainer),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: action,
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
