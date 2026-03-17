import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

import '../../core/config/base_url_config.dart';

/// Debug Settings Screen for configuring BASE_URL and other debug options.
///
/// This screen is ONLY visible in debug mode and provides a UI for:
/// - Viewing current BASE_URL configuration
/// - Overriding BASE_URL for testing
/// - Resetting to default BASE_URL
/// - Viewing configuration info
///
/// Access this screen by navigating to /debug/settings in debug mode
class DebugSettingsScreen extends ConsumerStatefulWidget {
  const DebugSettingsScreen({super.key});

  @override
  ConsumerState<DebugSettingsScreen> createState() =>
      _DebugSettingsScreenState();
}

class _DebugSettingsScreenState extends ConsumerState<DebugSettingsScreen> {
  final _urlController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final currentUrl = ref.read(currentBaseUrlProvider);
    _urlController.text = currentUrl;
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Security check: Only allow in debug mode
    if (!kDebugMode) {
      return Scaffold(
        appBar: AppBar(title: const Text('Debug Settings')),
        body: const Center(
          child: Text('Debug settings only available in debug mode'),
        ),
      );
    }

    final baseUrlConfig = ref.watch(baseUrlConfigProvider);
    final configInfo = baseUrlConfig.getConfigInfo();

    return Scaffold(
      appBar: AppBar(
        title: const Text('🔧 Debug Settings'),
        backgroundColor: Colors.orange[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Warning banner
            _buildWarningBanner(),

            const SizedBox(height: 24),

            // Current Configuration Section
            _buildSectionTitle('Current Configuration'),
            const SizedBox(height: 12),
            _buildConfigCard(configInfo),

            const SizedBox(height: 24),

            // BASE_URL Override Section
            _buildSectionTitle('Override BASE_URL'),
            const SizedBox(height: 12),
            _buildUrlInput(baseUrlConfig),

            const SizedBox(height: 16),
            _buildActionButtons(baseUrlConfig),

            const SizedBox(height: 24),

            // Quick Actions Section
            _buildSectionTitle('Quick Actions'),
            const SizedBox(height: 12),
            _buildQuickActions(),

            const SizedBox(height: 24),

            // Deep Link Info Section
            _buildSectionTitle('Deep Link Commands'),
            const SizedBox(height: 12),
            _buildDeepLinkInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[400]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Debug Mode Only',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[900],
                  ),
                ),
                Text(
                  'These settings only work in debug mode and will not affect production builds.',
                  style: TextStyle(fontSize: 12, color: Colors.orange[800]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildConfigCard(Map<String, dynamic> configInfo) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConfigRow(
              'Current URL',
              configInfo['currentUrl'] as String,
              Icons.link,
            ),
            const Divider(height: 24),
            _buildConfigRow(
              'Default URL',
              configInfo['defaultUrl'] as String,
              Icons.home,
            ),
            const Divider(height: 24),
            _buildConfigRow(
              'Overridden',
              configInfo['isOverridden'] as bool ? 'Yes' : 'No',
              Icons.settings,
              valueColor: configInfo['isOverridden'] as bool
                  ? Colors.green
                  : Colors.grey,
            ),
            const Divider(height: 24),
            _buildConfigRow(
              'Debug Mode',
              configInfo['isDebugMode'] as bool ? 'Active' : 'Inactive',
              Icons.bug_report,
              valueColor: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigRow(
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.blue[700],
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildUrlInput(BaseUrlConfig config) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'New BASE_URL',
                hintText: 'http://your-server:port',
                prefixIcon: const Icon(Icons.dns),
                border: const OutlineInputBorder(),
                helperText: 'Enter the backend URL you want to use',
              ),
              keyboardType: TextInputType.url,
              enabled: !_isSaving,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BaseUrlConfig config) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isSaving ? null : _handleSaveUrl,
            icon: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: Text(_isSaving ? 'Saving...' : 'Save URL'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isSaving ? null : _handleReset,
            icon: const Icon(Icons.refresh),
            label: const Text('Reset'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.dns, color: Colors.green),
            title: const Text('Local Development Server'),
            subtitle: const Text('http://localhost:8080'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _urlController.text = 'http://10.0.2.2:8080';
              _handleSaveUrl();
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.cloud, color: Colors.blue),
            title: const Text('Development Server'),
            subtitle: const Text('https://dev.snakeaid.tech'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _urlController.text = 'https://dev.snakeaid.tech';
              _handleSaveUrl();
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.security, color: Colors.purple),
            title: const Text('Production Server'),
            subtitle: const Text('https://snakeaid.duykhiem.id.vn'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _urlController.text = 'https://snakeaid.duykhiem.id.vn';
              _handleSaveUrl();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDeepLinkInfo() {
    return Card(
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Android ADB:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 4),
            _buildCodeSnippet(
              'adb shell am start -W -a android.intent.action.VIEW \\\n  -d "snakeaid://config/baseurl?url=http://192.168.1.100:8080" \\\n  com.snakeaid.mobile',
            ),
            const SizedBox(height: 12),
            const Text(
              'iOS Simulator:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 4),
            _buildCodeSnippet(
              'xcrun simctl openurl booted "snakeaid://config/baseurl?url=http://192.168.1.100:8080"',
            ),
            const SizedBox(height: 12),
            const Text(
              'Reset to default:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 4),
            _buildCodeSnippet('snakeaid://config/reset'),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeSnippet(String code) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              code,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleSaveUrl() async {
    final newUrl = _urlController.text.trim();

    if (newUrl.isEmpty) {
      _showSnackBar('Please enter a URL', isError: true);
      return;
    }

    if (!newUrl.startsWith('http://') && !newUrl.startsWith('https://')) {
      _showSnackBar('URL must start with http:// or https://', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final config = ref.read(baseUrlConfigProvider);
      final success = await config.overrideBaseUrl(newUrl);

      if (success && mounted) {
        _showSnackBar('✅ BASE_URL updated to: $newUrl');
      } else if (mounted) {
        _showSnackBar('❌ Failed to update BASE_URL', isError: true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('❌ Error: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _handleReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset BASE_URL?'),
        content: const Text(
          'This will reset the BASE_URL to the default value from .env file.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final config = ref.read(baseUrlConfigProvider);
      await config.resetToDefault();

      if (mounted) {
        _urlController.text = ref.read(currentBaseUrlProvider);
        _showSnackBar('✅ BASE_URL reset to default');
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
