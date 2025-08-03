import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/storage/secure_storage_service.dart';
import '../../providers/profile_card_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final SecureStorageService _storageService = SecureStorageService();
  bool _isBackupEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBackupSetting();
  }

  Future<void> _loadBackupSetting() async {
    try {
      final enabled = await _storageService.getBackupCardsEnabled();
      setState(() {
        _isBackupEnabled = enabled;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleBackup(bool value) async {
    try {
      await _storageService.setBackupCardsEnabled(value);
      setState(() {
        _isBackupEnabled = value;
      });

      if (value) {
        await ref.read(profileCardProvider.notifier).syncLocalCardsToFirebase();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Backup enabled. Local cards synced to Firebase.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Backup disabled. Cards will only be saved locally.',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update backup setting: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionHeader('Backup'),
            _buildBackupTile(),
            const SizedBox(height: 24),
            _buildSectionHeader('About'),
            _buildAboutTile(context),
            const SizedBox(height: 24),
            _buildSectionHeader('Data'),
            _buildDataTile(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupTile() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.cloud_upload),
        title: const Text('Backup Cards'),
        subtitle: const Text('Save cards to Firebase Cloud'),
        trailing:
            _isLoading
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : Switch(value: _isBackupEnabled, onChanged: _toggleBackup),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Builder(
      builder:
          (context) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
    );
  }

  Widget _buildAboutTile(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.info_outline),
        title: const Text('About CardWave'),
        subtitle: const Text('Version 1.0.1'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          showAboutDialog(
            context: context,
            applicationName: 'CardWave',
            applicationVersion: '1.0.0',
            applicationIcon: const Icon(Icons.credit_card, size: 48),
            children: const [
              Text(
                'A virtual business card manager with customizable profile cards.',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDataTile() {
    return Builder(
      builder:
          (context) => Card(
            child: ListTile(
              leading: const Icon(Icons.storage),
              title: const Text('Clear All Data'),
              subtitle: const Text('Delete all profile cards and contacts'),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.error,
              ),
              onTap: () {
                // TODO: Implement clear data functionality
              },
            ),
          ),
    );
  }
}
