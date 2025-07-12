import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
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
        subtitle: const Text('Version 1.0.0'),
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
