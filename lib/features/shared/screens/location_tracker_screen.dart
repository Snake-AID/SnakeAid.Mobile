import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../app/theme.dart';
import '../models/Class.dart';
import '../providers/signalr_repository_provider.dart';

class LocationTrackerScreen extends ConsumerStatefulWidget {
  const LocationTrackerScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LocationTrackerScreen> createState() =>
      _LocationTrackerScreenState();
}

class _LocationTrackerScreenState extends ConsumerState<LocationTrackerScreen> {
  bool _isConnected = false;
  String? _otherUserId;
  bool _isMapView = false; // Toggle between list and map view
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(connectionStateProvider);
    final userInfo = ref.watch(userInfoProvider);
    final userListAsync = ref.watch(userListProvider);
    final locationUpdatesAsync = ref.watch(locationUpdatesProvider);
    final latestLocationsAsync = ref.watch(latestUserLocationsProvider);
    final otherLocationsAsync = ref.watch(otherUserLocationsProvider);
    final isLocationSharing = ref.watch(locationServiceProvider);
    final errorMessagesAsync = ref.watch(errorMessagesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Tracker'),
        actions: [
          IconButton(
            icon: Icon(_isMapView ? Icons.list : Icons.map),
            onPressed: () => setState(() => _isMapView = !_isMapView),
            tooltip: _isMapView ? 'Switch to List View' : 'Switch to Map View',
          ),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingSmall),
            child: Center(
              child: Text(
                _getConnectionStatusText(connectionState),
                style: TextStyle(
                  fontSize: AppTheme.captionFontSize,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
          // Connection Controls
          Card(
            margin: const EdgeInsets.all(AppTheme.spacingSmall),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        color: AppTheme.getPrimaryColor(context),
                      ),
                      const SizedBox(width: AppTheme.spacingSmall),
                      Expanded(
                        child: Text(
                          '${userInfo.userName}',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingSmall),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed:
                              connectionState ==
                                  UserConnectionState.disconnected
                              ? _connectAndJoin
                              : null,
                          icon: const Icon(Icons.link),
                          label: const Text('Connect & Join'),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingSmall),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed:
                              connectionState == UserConnectionState.connected
                              ? _disconnect
                              : null,
                          icon: const Icon(Icons.link_off),
                          label: const Text('Disconnect'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.getErrorColor(context),
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onError,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Location Controls
          Card(
            margin: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingSmall,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: AppTheme.getSecondaryColor(context),
                      ),
                      const SizedBox(width: AppTheme.spacingSmall),
                      Text(
                        'Location Sharing',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingSmall),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed:
                              connectionState ==
                                      UserConnectionState.connected &&
                                  _isConnected &&
                                  !isLocationSharing
                              ? _startLocationSharing
                              : null,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start Tracking'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.getPrimaryColor(context),
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingSmall),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isLocationSharing
                              ? _stopLocationSharing
                              : null,
                          icon: const Icon(Icons.stop),
                          label: const Text('Stop Tracking'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingSmall),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed:
                              connectionState == UserConnectionState.connected
                              ? _sendCurrentLocation
                              : null,
                          icon: const Icon(Icons.send),
                          label: const Text('Send Now'),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingSmall),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _otherUserId != null
                              ? () => _requestLocationFromOther()
                              : null,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Request Update'),
                        ),
                      ),
                    ],
                  ),
                  if (isLocationSharing)
                    Container(
                      margin: const EdgeInsets.only(top: AppTheme.spacingSmall),
                      padding: const EdgeInsets.all(AppTheme.spacingSmall),
                      decoration: BoxDecoration(
                        color: AppTheme.getPrimaryColor(
                          context,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          AppTheme.borderRadius,
                        ),
                        border: Border.all(
                          color: AppTheme.getPrimaryColor(context),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.radio_button_checked,
                            color: AppTheme.getPrimaryColor(context),
                            size: 16,
                          ),
                          const SizedBox(width: AppTheme.spacingSmall),
                          Text(
                            'Location sharing active (every 5 seconds)',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppTheme.getPrimaryColor(context),
                                  fontSize: AppTheme.captionFontSize,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Connected Users Status
          userListAsync.when(
            data: (users) => Card(
              margin: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingSmall,
                vertical: 4,
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingSmall),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          color: AppTheme.getSecondaryColor(context),
                        ),
                        const SizedBox(width: AppTheme.spacingSmall),
                        Text(
                          'Connected Devices (${users.length})',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                        const Spacer(),
                        if (_isConnected &&
                            connectionState == UserConnectionState.connected)
                          IconButton(
                            icon: const Icon(Icons.refresh, size: 20),
                            onPressed: _refreshData,
                            tooltip: 'Refresh data',
                          ),
                      ],
                    ),
                    if (users.isNotEmpty) ...[
                      const SizedBox(height: AppTheme.spacingSmall),
                      ...users.map((user) {
                        final isCurrentUser = user == userInfo.userId;
                        if (!isCurrentUser) {
                          _otherUserId = user; // Store other user ID
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingSmall,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isCurrentUser
                                ? AppTheme.getPrimaryColor(
                                    context,
                                  ).withOpacity(0.1)
                                : AppTheme.getSecondaryColor(
                                    context,
                                  ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              AppTheme.borderRadius,
                            ),
                            border: Border.all(
                              color: isCurrentUser
                                  ? AppTheme.getPrimaryColor(context)
                                  : AppTheme.getSecondaryColor(context),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: isCurrentUser
                                    ? AppTheme.getPrimaryColor(context)
                                    : AppTheme.getSecondaryColor(context),
                                child: Icon(
                                  isCurrentUser
                                      ? Icons.smartphone
                                      : Icons.devices,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: AppTheme.spacingSmall),
                              Text(
                                isCurrentUser ? 'This Device' : 'Other Device',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      fontSize: AppTheme.captionFontSize,
                                      fontWeight: FontWeight.w500,
                                      color: isCurrentUser
                                          ? AppTheme.getPrimaryColor(context)
                                          : AppTheme.getSecondaryColor(context),
                                    ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ] else
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: AppTheme.spacingSmall,
                        ),
                        child: Text(
                          'Waiting for other device to connect...',
                          style: TextStyle(
                            fontSize: AppTheme.captionFontSize,
                            color: AppTheme.getTextSecondaryColor(context),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            loading: () => Card(
              margin: EdgeInsets.symmetric(
                horizontal: AppTheme.spacingSmall,
                vertical: 4,
              ),
              child: Padding(
                padding: EdgeInsets.all(AppTheme.spacingSmall),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.getPrimaryColor(context),
                      ),
                    ),
                    SizedBox(width: AppTheme.spacingSmall),
                    Text('Loading devices...'),
                  ],
                ),
              ),
            ),
            error: (error, _) => Card(
              margin: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingSmall,
                vertical: 4,
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingSmall),
                child: Text(
                  'Error loading devices: $error',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.getErrorColor(context),
                    fontSize: AppTheme.captionFontSize,
                  ),
                ),
              ),
            ),
          ),

          // Location Distance Tracking
          SizedBox(
            height: 500, // Fixed height for scrollable content
            child: locationUpdatesAsync.when(
              data: (locations) => _isMapView
                  ? _buildMapView(locations, userInfo.userId)
                  : _buildListView(locations, userInfo.userId),
              loading: () => Card(
                margin: EdgeInsets.all(AppTheme.spacingSmall),
                child: Padding(
                  padding: EdgeInsets.all(AppTheme.spacingMedium),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: AppTheme.getPrimaryColor(context),
                        ),
                        SizedBox(height: AppTheme.spacingMedium),
                        Text('Loading location data...'),
                      ],
                    ),
                  ),
                ),
              ),
              error: (error, _) => Card(
                margin: const EdgeInsets.all(AppTheme.spacingSmall),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingMedium),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: AppTheme.getErrorColor(context),
                        ),
                        const SizedBox(height: AppTheme.spacingMedium),
                        Text(
                          'Error loading locations: $error',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppTheme.getErrorColor(context),
                                fontSize: AppTheme.captionFontSize,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Error Messages
          errorMessagesAsync.when(
            data: (error) => error.isNotEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppTheme.spacingSmall),
                    margin: const EdgeInsets.all(AppTheme.spacingSmall),
                    decoration: BoxDecoration(
                      color: AppTheme.getErrorColor(context).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        AppTheme.borderRadius,
                      ),
                      border: Border.all(
                        color: AppTheme.getErrorColor(context),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error,
                          color: AppTheme.getErrorColor(context),
                          size: 16,
                        ),
                        const SizedBox(width: AppTheme.spacingSmall),
                        Expanded(
                          child: Text(
                            error,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppTheme.getErrorColor(context),
                                  fontSize: AppTheme.captionFontSize,
                                ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
          // Add bottom padding for scroll
          const SizedBox(height: 20),
        ],
      ),
      ),
    );
  }

  Widget _buildLocationComparison(
    List<UserLocationData> locations,
    String currentUserId,
  ) {
    final currentUserLocation = locations.firstWhere(
      (loc) => loc.userId == currentUserId,
      orElse: () => locations.first,
    );

    final otherUserLocation = locations.firstWhere(
      (loc) => loc.userId != currentUserId,
      orElse: () => locations.last,
    );

    final distance = _calculateDistance(
      currentUserLocation.latitude,
      currentUserLocation.longitude,
      otherUserLocation.latitude,
      otherUserLocation.longitude,
    );

    return Column(
      children: [
        // Distance Display
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getDistanceColor(distance).withOpacity(0.1),
                _getDistanceColor(distance).withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            border: Border.all(color: _getDistanceColor(distance)),
          ),
          child: Column(
            children: [
              Icon(
                _getDistanceIcon(distance),
                size: 48,
                color: _getDistanceColor(distance),
              ),
              const SizedBox(height: AppTheme.spacingSmall),
              Text(
                _formatDistance(distance),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _getDistanceColor(distance),
                ),
              ),
              Text(
                'Distance between devices',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: AppTheme.captionFontSize,
                  color: AppTheme.getTextSecondaryColor(context),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppTheme.spacingMedium),

        // Device Details
        Expanded(
          child: Row(
            children: [
              // Current Device
              Expanded(
                child: _buildDeviceLocationCard(currentUserLocation, true),
              ),

              const SizedBox(width: AppTheme.spacingSmall),

              // Distance Arrow
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.compare_arrows,
                    color: _getDistanceColor(distance),
                    size: 32,
                  ),
                  Text(
                    '${distance.toStringAsFixed(0)}m',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getDistanceColor(distance),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: AppTheme.spacingSmall),

              // Other Device
              Expanded(
                child: _buildDeviceLocationCard(otherUserLocation, false),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceLocationCard(
    UserLocationData location,
    bool isCurrentUser,
  ) {
    final secondsAgo = DateTime.now().difference(location.timestamp).inSeconds;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingSmall),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppTheme.getPrimaryColor(context).withOpacity(0.05)
            : AppTheme.getSecondaryColor(context).withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        border: Border.all(
          color: isCurrentUser
              ? AppTheme.getPrimaryColor(context)
              : AppTheme.getSecondaryColor(context),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: isCurrentUser
                    ? AppTheme.getPrimaryColor(context)
                    : AppTheme.getSecondaryColor(context),
                child: Icon(
                  isCurrentUser ? Icons.smartphone : Icons.devices,
                  size: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: AppTheme.spacingSmall),
              Expanded(
                child: Text(
                  isCurrentUser ? 'This Device' : 'Other Device',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: AppTheme.captionFontSize,
                    color: isCurrentUser
                        ? AppTheme.getPrimaryColor(context)
                        : AppTheme.getSecondaryColor(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          Text(
            'Lat: ${location.latitude.toStringAsFixed(6)}',
            style: const TextStyle(fontSize: 10),
          ),
          Text(
            'Lng: ${location.longitude.toStringAsFixed(6)}',
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: secondsAgo < 30 ? Colors.green : Colors.orange,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              secondsAgo < 60
                  ? '${secondsAgo}s ago'
                  : '${(secondsAgo / 60).floor()}m ago',
              style: const TextStyle(
                fontSize: 8,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getConnectionStatusText(UserConnectionState state) {
    switch (state) {
      case UserConnectionState.connected:
        return '🟢 Connected';
      case UserConnectionState.connecting:
        return '🟡 Connecting';
      case UserConnectionState.reconnecting:
        return '🟡 Reconnecting';
      case UserConnectionState.disconnected:
        return '🔴 Disconnected';
    }
  }

  Future<void> _connectAndJoin() async {
    final repository = ref.read(signalRRepositoryProvider);
    final userInfo = ref.read(userInfoProvider);

    // Connect to SignalR
    await ref.read(connectionStateProvider.notifier).connect();

    // Wait a bit then join
    await Future.delayed(const Duration(milliseconds: 1000));

    if (mounted) {
      // Join chat
      await repository.joinChat(userInfo.userId, userInfo.userName);

      // Request latest data
      await Future.delayed(const Duration(milliseconds: 1000));
      await repository.requestUserList();
      await repository.getAllLocations();

      setState(() => _isConnected = true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Connected successfully! 🎉'),
            backgroundColor: AppTheme.getPrimaryColor(context),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _disconnect() async {
    setState(() {
      _isConnected = false;
      _otherUserId = null;
    });
    await ref.read(connectionStateProvider.notifier).disconnect();
  }

  Future<void> _startLocationSharing() async {
    final locationNotifier = ref.read(locationServiceProvider.notifier);

    final hasPermission = await locationNotifier.requestLocationPermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Location permission required'),
            backgroundColor: AppTheme.getErrorColor(context),
          ),
        );
      }
      return;
    }

    locationNotifier.startLocationSharing();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Location sharing started 📍'),
          backgroundColor: AppTheme.getPrimaryColor(context),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _stopLocationSharing() {
    ref.read(locationServiceProvider.notifier).stopLocationSharing();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location sharing stopped'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _sendCurrentLocation() async {
    final repository = ref.read(signalRRepositoryProvider);
    final userInfo = ref.read(userInfoProvider);
    final locationNotifier = ref.read(locationServiceProvider.notifier);

    final position = await locationNotifier.getCurrentLocation();
    if (position != null) {
      await repository.updateLocation(
        userInfo.userId,
        userInfo.userName,
        position.latitude,
        position.longitude,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Location sent successfully 📍'),
            backgroundColor: AppTheme.getPrimaryColor(context),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to get current location'),
            backgroundColor: AppTheme.getErrorColor(context),
          ),
        );
      }
    }
  }

  Future<void> _requestLocationFromOther() async {
    if (_otherUserId != null) {
      final locationNotifier = ref.read(locationServiceProvider.notifier);
      await locationNotifier.requestLocationFromUser(_otherUserId!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Requested location update from other device'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  Future<void> _broadcastLatestLocations() async {
    final locationNotifier = ref.read(locationServiceProvider.notifier);
    await locationNotifier.broadcastLatestLocations();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Broadcasting latest locations...'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _refreshData() async {
    final repository = ref.read(signalRRepositoryProvider);
    await repository.requestUserList();
    await repository.getAllLocations();
    await repository.broadcastLatestLocations();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data refreshed'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  // Calculate distance between two coordinates using Haversine formula
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  // Format distance for display
  String _formatDistance(double distance) {
    if (distance < 1000) {
      return '${distance.toStringAsFixed(1)} meters';
    } else {
      return '${(distance / 1000).toStringAsFixed(2)} km';
    }
  }

  // Get color based on distance
  Color _getDistanceColor(double distance) {
    if (distance < 100) {
      return AppTheme.getPrimaryColor(context); // Very close
    } else if (distance < 500) {
      return Colors.orange; // Moderate distance
    } else {
      return AppTheme.getErrorColor(context); // Far
    }
  }

  // Get icon based on distance
  IconData _getDistanceIcon(double distance) {
    if (distance < 100) {
      return Icons.people; // Very close
    } else if (distance < 500) {
      return Icons.directions_walk; // Moderate distance
    } else {
      return Icons.directions_car; // Far
    }
  }

  Widget _buildMapView(List<UserLocationData> locations, String currentUserId) {
    if (locations.isEmpty) {
      return Card(
        margin: const EdgeInsets.all(AppTheme.spacingSmall),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off,
                size: 64,
                color: AppTheme.getTextSecondaryColor(context).withOpacity(0.5),
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              Text(
                'No location data available',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.getTextSecondaryColor(context),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Calculate map center and zoom level
    final center = _calculateMapCenter(locations);
    final zoom = _calculateMapZoom(locations);

    return Card(
      margin: const EdgeInsets.all(AppTheme.spacingSmall),
      child: Column(
        children: [
          // Map header
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingSmall),
            decoration: BoxDecoration(
              color: AppTheme.getSurfaceColor(context),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.borderRadius),
                topRight: Radius.circular(AppTheme.borderRadius),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.map, color: AppTheme.getPrimaryColor(context)),
                const SizedBox(width: AppTheme.spacingSmall),
                Expanded(
                  child: Text(
                    'Live Location Map',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.getOnSurfaceColor(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingSmall,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.getPrimaryColor(context).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${locations.length} device${locations.length != 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.getPrimaryColor(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Map view
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: zoom,
                minZoom: 3.0,
                maxZoom: 18.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.snakeaid_mobile',
                ),
                MarkerLayer(
                  markers: _buildLocationMarkers(locations, currentUserId),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  LatLng _calculateMapCenter(List<UserLocationData> locations) {
    if (locations.isEmpty) return LatLng(21.0285, 105.8542); // Default to Hanoi

    double totalLat = 0;
    double totalLng = 0;

    for (final location in locations) {
      totalLat += location.latitude;
      totalLng += location.longitude;
    }

    return LatLng(totalLat / locations.length, totalLng / locations.length);
  }

  double _calculateMapZoom(List<UserLocationData> locations) {
    if (locations.length <= 1) return 15.0; // Close zoom for single location

    // Calculate the maximum distance between any two points
    double maxDistance = 0;
    for (int i = 0; i < locations.length; i++) {
      for (int j = i + 1; j < locations.length; j++) {
        final distance = _calculateDistance(
          locations[i].latitude,
          locations[i].longitude,
          locations[j].latitude,
          locations[j].longitude,
        );
        maxDistance = maxDistance > distance ? maxDistance : distance;
      }
    }

    // Adjust zoom based on max distance (in meters)
    if (maxDistance < 100) return 18.0; // Very close
    if (maxDistance < 500) return 16.0; // Close
    if (maxDistance < 2000) return 14.0; // Medium
    if (maxDistance < 10000) return 12.0; // Far
    return 10.0; // Very far
  }

  List<Marker> _buildLocationMarkers(
    List<UserLocationData> locations,
    String currentUserId,
  ) {
    return locations.map((location) {
      final isCurrentUser = location.userId == currentUserId;
      final position = LatLng(location.latitude, location.longitude);

      return Marker(
        point: position,
        width: 120,
        height: 80,
        child: GestureDetector(
          onTap: () {
            // Show location details when marker is tapped
            _showLocationDetails(location, isCurrentUser);
          },
          child: Column(
            children: [
              // User info card above marker
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCurrentUser
                      ? AppTheme.getPrimaryColor(context)
                      : AppTheme.getSecondaryColor(context),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  isCurrentUser ? 'You' : 'User ${location.userId}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Marker pin
              Icon(
                isCurrentUser ? Icons.location_pin : Icons.location_on,
                color: isCurrentUser
                    ? AppTheme.getPrimaryColor(context)
                    : AppTheme.getSecondaryColor(context),
                size: 40,
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  void _showLocationDetails(UserLocationData location, bool isCurrentUser) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isCurrentUser ? 'Your Location' : 'User Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User ID: ${location.userId}'),
            const SizedBox(height: 8),
            Text('Latitude: ${location.latitude.toStringAsFixed(6)}'),
            Text('Longitude: ${location.longitude.toStringAsFixed(6)}'),
            const SizedBox(height: 8),
            Text('Last Updated: ${_formatTimestamp(location.timestamp)}'),
            if (isCurrentUser) ...[
              const SizedBox(height: 8),
              Text(
                'This is your current location',
                style: TextStyle(
                  color: AppTheme.getPrimaryColor(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(
    List<UserLocationData> locations,
    String currentUserId,
  ) {
    return Card(
      margin: const EdgeInsets.all(AppTheme.spacingSmall),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.track_changes,
                  color: AppTheme.getPrimaryColor(context),
                ),
                const SizedBox(width: AppTheme.spacingSmall),
                Text(
                  'Distance Tracking',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                if (locations.length > 1)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingSmall,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.getPrimaryColor(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${locations.length} devices',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            if (locations.length >= 2)
              Expanded(
                child: _buildLocationComparison(locations, currentUserId),
              )
            else
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_searching,
                        size: 64,
                        color: AppTheme.getTextSecondaryColor(
                          context,
                        ).withOpacity(0.5),
                      ),
                      const SizedBox(height: AppTheme.spacingMedium),
                      Text(
                        locations.length == 1
                            ? 'Waiting for the other device to share location...'
                            : 'Start location sharing to track distance between devices',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: AppTheme.captionFontSize,
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingMedium),
                      if (locations.length == 1)
                        OutlinedButton.icon(
                          onPressed: _broadcastLatestLocations,
                          icon: const Icon(Icons.broadcast_on_personal),
                          label: const Text('Broadcast Location'),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
