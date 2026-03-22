import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/incident_history_list.dart';
import '../widgets/snake_catching_request_list.dart';
import '../../auth/providers/auth_provider.dart';

/// History Screen — shows only completed / paid / dispute requests
class MemberHistoryScreen extends ConsumerStatefulWidget {
  const MemberHistoryScreen({super.key});

  @override
  ConsumerState<MemberHistoryScreen> createState() =>
      _MemberHistoryScreenState();
}

class _MemberHistoryScreenState extends ConsumerState<MemberHistoryScreen> {
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

  // ── Build ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF228B22),
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Lịch Sử',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF228B22),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF228B22)),
            onPressed: _refreshChild,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: ref.read(currentUserProvider) == null
          ? const Center(child: Text('Vui lòng đăng nhập để xem dữ liệu'))
          : Column(
              children: [
                _buildModeToggle(),
                Expanded(
                  child: _showIncident
                      ? IncidentHistoryList(
                          key: ValueKey('incident-${_refreshVersion}'),
                          userId: ref.read(currentUserProvider)!.id,
                          showHistory: true,
                        )
                      : SnakeCatchingRequestList(
                          key: ValueKey('catching-${_refreshVersion}'),
                          userId: ref.read(currentUserProvider)!.id,
                          showHistory: true,
                        ),
                ),
              ],
            ),
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
