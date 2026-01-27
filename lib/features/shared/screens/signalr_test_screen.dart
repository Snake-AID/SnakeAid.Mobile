import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../app/theme.dart';
import '../models/Class.dart';
import '../providers/signalr_repository_provider.dart';

class SignalRTestScreen extends ConsumerStatefulWidget {
  const SignalRTestScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SignalRTestScreen> createState() => _SignalRTestScreenState();
}

class _SignalRTestScreenState extends ConsumerState<SignalRTestScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isJoined = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(connectionStateProvider);
    final userInfo = ref.watch(userInfoProvider);
    final messagesAsync = ref.watch(messagesProvider);
    final userListAsync = ref.watch(userListProvider);
    final locationUpdatesAsync = ref.watch(locationUpdatesProvider);
    final isLocationSharing = ref.watch(locationServiceProvider);
    final errorMessagesAsync = ref.watch(errorMessagesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SignalR Test'),
        actions: [
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
      body: Column(
        children: [
          // User Info Card
          Card(
            margin: const EdgeInsets.all(AppTheme.spacingSmall),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User ID: ${userInfo.userId}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.getTextSecondaryColor(context),
                    ),
                  ),
                  Text(
                    'User Name: ${userInfo.userName}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSmall),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed:
                            connectionState == UserConnectionState.disconnected
                            ? _connect
                            : null,
                        child: const Text('Connect'),
                      ),
                      const SizedBox(width: AppTheme.spacingSmall),
                      ElevatedButton(
                        onPressed:
                            connectionState == UserConnectionState.connected &&
                                !_isJoined
                            ? _joinChat
                            : null,
                        child: const Text('Join Chat'),
                      ),
                      const SizedBox(width: AppTheme.spacingSmall),
                      ElevatedButton(
                        onPressed:
                            connectionState == UserConnectionState.connected
                            ? _disconnect
                            : null,
                        child: const Text('Disconnect'),
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
                  Text(
                    'Location Sharing',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSmall),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed:
                            connectionState == UserConnectionState.connected &&
                                _isJoined &&
                                !isLocationSharing
                            ? _startLocationSharing
                            : null,
                        child: const Text('Start Location'),
                      ),
                      const SizedBox(width: AppTheme.spacingSmall),
                      ElevatedButton(
                        onPressed: isLocationSharing
                            ? _stopLocationSharing
                            : null,
                        child: const Text('Stop Location'),
                      ),
                      const SizedBox(width: AppTheme.spacingSmall),
                      ElevatedButton(
                        onPressed:
                            connectionState == UserConnectionState.connected
                            ? _sendCurrentLocation
                            : null,
                        child: const Text('Send Now'),
                      ),
                    ],
                  ),
                  if (isLocationSharing)
                    Padding(
                      padding: const EdgeInsets.only(
                        top: AppTheme.spacingSmall,
                      ),
                      child: Text(
                        'Location sharing active (every 5 seconds)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.getPrimaryColor(context),
                          fontSize: AppTheme.captionFontSize,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Connected Users
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Connected Users (${users.length})${users.isEmpty ? ' - Waiting...' : ''}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                        if (_isJoined &&
                            connectionState == UserConnectionState.connected)
                          IconButton(
                            icon: const Icon(Icons.refresh, size: 20),
                            onPressed: () async {
                              final repository = ref.read(
                                signalRRepositoryProvider,
                              );
                              // await repository.requestUserList();
                              await repository.getAllLocations();

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Refreshing user list and locations...',
                                  ),
                                  duration: const Duration(seconds: 1),
                                  backgroundColor: AppTheme.getPrimaryColor(
                                    context,
                                  ),
                                ),
                              );
                            },
                            tooltip: 'Refresh user list and locations',
                          ),
                      ],
                    ),
                    if (users.isNotEmpty)
                      Wrap(
                        children: users
                            .map(
                              (user) => Chip(
                                label: Text(
                                  user == userInfo.userId
                                      ? '$user (You)'
                                      : user,
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        fontSize: 10,
                                        color: user == userInfo.userId
                                            ? AppTheme.getPrimaryColor(context)
                                            : AppTheme.getSecondaryColor(
                                                context,
                                              ),
                                      ),
                                ),
                                backgroundColor: user == userInfo.userId
                                    ? AppTheme.getPrimaryColor(
                                        context,
                                      ).withOpacity(0.2)
                                    : AppTheme.getSecondaryColor(
                                        context,
                                      ).withOpacity(0.2),
                                avatar: user == userInfo.userId
                                    ? Icon(
                                        Icons.person,
                                        size: 16,
                                        color: AppTheme.getPrimaryColor(
                                          context,
                                        ),
                                      )
                                    : Icon(
                                        Icons.people,
                                        size: 16,
                                        color: AppTheme.getSecondaryColor(
                                          context,
                                        ),
                                      ),
                              ),
                            )
                            .toList(),
                      )
                    else
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: AppTheme.spacingSmall,
                        ),
                        child: Text(
                          'No users connected yet. Join chat to see other users.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontSize: AppTheme.captionFontSize,
                                color: AppTheme.getTextSecondaryColor(context),
                              ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            loading: () => const Card(
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
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    SizedBox(width: AppTheme.spacingSmall),
                    Text('Loading users...'),
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
                  'Error loading users: $error',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.getErrorColor(context),
                    fontSize: AppTheme.captionFontSize,
                  ),
                ),
              ),
            ),
          ),

          // Location Updates with Distance Comparison
          locationUpdatesAsync.when(
            data: (locations) => Card(
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'User Locations (${locations.length})${locations.isEmpty ? ' - No locations yet' : ''}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                        if (locations.isNotEmpty)
                          Text(
                            'Compare Distances',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  fontSize: 10,
                                  color: AppTheme.getSecondaryColor(context),
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingSmall),
                    if (locations.isNotEmpty)
                      Column(
                        children: locations.map((loc) {
                          // Find current user's location for distance calculation
                          final currentUserLocation = locations.firstWhere(
                            (l) => l.userId == userInfo.userId,
                            orElse: () => loc,
                          );

                          final distance = loc.userId != userInfo.userId
                              ? _calculateDistance(
                                  currentUserLocation.latitude,
                                  currentUserLocation.longitude,
                                  loc.latitude,
                                  loc.longitude,
                                )
                              : null;

                          final isCurrentUser = loc.userId == userInfo.userId;
                          final secondsAgo = DateTime.now()
                              .difference(loc.timestamp)
                              .inSeconds;

                          return Container(
                            margin: const EdgeInsets.only(
                              bottom: AppTheme.spacingSmall,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isCurrentUser
                                    ? AppTheme.getPrimaryColor(context)
                                    : AppTheme.getSecondaryColor(context),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(
                                AppTheme.borderRadius,
                              ),
                              color: isCurrentUser
                                  ? AppTheme.getPrimaryColor(
                                      context,
                                    ).withOpacity(0.1)
                                  : AppTheme.getSecondaryColor(
                                      context,
                                    ).withOpacity(0.1),
                            ),
                            child: ListTile(
                              dense: true,
                              leading: CircleAvatar(
                                radius: 16,
                                backgroundColor: isCurrentUser
                                    ? AppTheme.getPrimaryColor(context)
                                    : AppTheme.getSecondaryColor(context),
                                child: Icon(
                                  isCurrentUser
                                      ? Icons.my_location
                                      : Icons.location_on,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      isCurrentUser
                                          ? '${loc.userName} (You)'
                                          : loc.userName,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isCurrentUser
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  if (distance != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getDistanceColor(distance),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '${distance.toStringAsFixed(0)}m',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Lat: ${loc.latitude.toStringAsFixed(6)}\nLng: ${loc.longitude.toStringAsFixed(6)}',
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  if (distance != null)
                                    Text(
                                      'Distance from you: ${_formatDistance(distance)}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: _getDistanceColor(distance),
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: secondsAgo < 30
                                          ? AppTheme.primaryGreenLight
                                          : Colors.orange,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      secondsAgo < 60
                                          ? '${secondsAgo}s'
                                          : '${(secondsAgo / 60).floor()}m',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.location_off,
                                size: 32,
                                color: AppTheme.getTextSecondaryColor(context),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No location data available.\nStart sharing location to see comparisons.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      fontSize: 12,
                                      color: AppTheme.getTextSecondaryColor(
                                        context,
                                      ),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            loading: () => const Card(
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
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    SizedBox(width: AppTheme.spacingSmall),
                    Text('Loading locations...'),
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
                  'Error loading locations: $error',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.getErrorColor(context),
                    fontSize: AppTheme.captionFontSize,
                  ),
                ),
              ),
            ),
          ),

          // Messages List
          Expanded(
            child: messagesAsync.when(
              data: (messages) => ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(AppTheme.spacingSmall),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isMyMessage = message.userId == userInfo.userId;

                  return Align(
                    alignment: isMyMessage
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      padding: const EdgeInsets.all(AppTheme.spacingSmall),
                      decoration: BoxDecoration(
                        color: isMyMessage
                            ? AppTheme.getPrimaryColor(context).withOpacity(0.1)
                            : AppTheme.getSurfaceColor(context),
                        borderRadius: BorderRadius.circular(
                          AppTheme.borderRadius,
                        ),
                        border: !isMyMessage
                            ? Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outline.withOpacity(0.3),
                              )
                            : null,
                      ),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isMyMessage)
                            Text(
                              message.userName,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: AppTheme.captionFontSize,
                                    color: AppTheme.getSecondaryColor(context),
                                  ),
                            ),
                          Text(
                            message.message,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                          ),
                          Text(
                            '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  fontSize: 10,
                                  color: AppTheme.getTextSecondaryColor(
                                    context,
                                  ),
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              loading: () => Center(
                child: CircularProgressIndicator(
                  color: AppTheme.getPrimaryColor(context),
                ),
              ),
              error: (error, _) => Center(
                child: Text(
                  'Error: $error',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.getErrorColor(context),
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
                    child: Text(
                      'Error: $error',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.getErrorColor(context),
                        fontSize: AppTheme.captionFontSize,
                      ),
                    ),
                  )
                : const SizedBox(),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),

          // Message Input
          if (_isJoined && connectionState == UserConnectionState.connected)
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingSmall),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingSmall),
                  ElevatedButton(
                    onPressed: _sendMessage,
                    child: const Text('Send'),
                  ),
                ],
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

  Future<void> _connect() async {
    await ref.read(connectionStateProvider.notifier).connect();

    // Auto refresh after connecting
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      final repository = ref.read(signalRRepositoryProvider);
      await repository.requestUserList();
      await repository.getAllLocations();
    }
  }

  Future<void> _disconnect() async {
    setState(() => _isJoined = false);
    await ref.read(connectionStateProvider.notifier).disconnect();
  }

  Future<void> _joinChat() async {
    final repository = ref.read(signalRRepositoryProvider);
    final userInfo = ref.read(userInfoProvider);

    await repository.joinChat(userInfo.userId, userInfo.userName);

    // Request updated user list and all locations after joining
    await Future.delayed(const Duration(milliseconds: 1000));
    await repository.requestUserList();
    await repository.getAllLocations();

    setState(() => _isJoined = true);

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Joined chat successfully! 🎉'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final repository = ref.read(signalRRepositoryProvider);
    final userInfo = ref.read(userInfoProvider);

    await repository.sendMessage(userInfo.userId, userInfo.userName, text);
    _messageController.clear();

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _startLocationSharing() async {
    final locationNotifier = ref.read(locationServiceProvider.notifier);

    final hasPermission = await locationNotifier.requestLocationPermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission required')),
      );
      return;
    }

    locationNotifier.startLocationSharing();
  }

  void _stopLocationSharing() {
    ref.read(locationServiceProvider.notifier).stopLocationSharing();
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Location sent: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: AppTheme.getPrimaryColor(context),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to get current location'),
          backgroundColor: AppTheme.getErrorColor(context),
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
      return '${distance.toStringAsFixed(0)} meters';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)} km';
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
}
