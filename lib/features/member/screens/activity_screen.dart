import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/incident_history_list.dart';
import '../widgets/snake_catching_request_list.dart';

/// Activity Screen - Shows user's snake catching requests
class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  bool _showIncident = false;
  int _refreshVersion = 0;

  void _switchMode(bool showIncident) {
    if (_showIncident == showIncident) return;
    setState(() {
      _showIncident = showIncident;
      _refreshVersion += 1;
    });
  }

  void _refreshChild() {
    setState(() {
      _refreshVersion += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // App Bar
        Container(
          color: Colors.white,
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 56,
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const Text(
                    'Hoạt Động',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF228B22),
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => context.push('/member-history'),
                    icon: const Icon(
                      Icons.history_rounded,
                      size: 18,
                      color: Color(0xFF228B22),
                    ),
                    label: const Text(
                      'Lịch sử',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF228B22),
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Mode switch tabs
        _buildModeToggle(),

        // Content
        Expanded(
          child: ref.read(currentUserProvider) == null
              ? const Center(child: Text('Vui lòng đăng nhập để xem dữ liệu'))
              : _showIncident
              ? IncidentHistoryList(
                  key: ValueKey('incident-${_refreshVersion}'),
                  userId: ref.read(currentUserProvider)!.id,
                  showHistory: false,
                )
              : SnakeCatchingRequestList(
                  key: ValueKey('catching-${_refreshVersion}'),
                  userId: ref.read(currentUserProvider)!.id,
                  showHistory: false,
                ),
        ),
      ],
    );
  }

  Widget _buildModeToggle() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _switchMode(false),
              style: OutlinedButton.styleFrom(
                backgroundColor: _showIncident
                    ? Colors.white
                    : const Color(0xFF228B22),
                foregroundColor: _showIncident ? Colors.black : Colors.white,
                side: BorderSide(
                  color: _showIncident
                      ? const Color(0xFFCCCCCC)
                      : const Color(0xFF228B22),
                ),
              ),
              child: const Text('Bắt rắn'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: () => _switchMode(true),
              style: OutlinedButton.styleFrom(
                backgroundColor: _showIncident
                    ? const Color(0xFF228B22)
                    : Colors.white,
                foregroundColor: _showIncident ? Colors.white : Colors.black,
                side: BorderSide(
                  color: _showIncident
                      ? const Color(0xFF228B22)
                      : const Color(0xFFCCCCCC),
                ),
              ),
              child: const Text('Sự cố'),
            ),
          ),
        ],
      ),
    );
  }
}
