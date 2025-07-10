import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Appearance'),
          _buildThemeSelector(themeMode, themeNotifier),
          const SizedBox(height: 24),
          _buildSectionHeader('About'),
          _buildAboutTile(context),
          const SizedBox(height: 24),
          _buildSectionHeader('Data'),
          _buildDataTile(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.black,
        ),
      ),
    );
  }

  Widget _buildThemeSelector(AppThemeMode themeMode, ThemeNotifier themeNotifier) {
    return Card(
      child: Column(
        children: [
          RadioListTile<AppThemeMode>(
            title: const Text('Light Mode'),
            value: AppThemeMode.light,
            groupValue: themeMode,
            onChanged: (value) {
              if (value != null) {
                themeNotifier.setTheme(value);
              }
            },
          ),
          RadioListTile<AppThemeMode>(
            title: const Text('Dark Mode'),
            value: AppThemeMode.dark,
            groupValue: themeMode,
            onChanged: (value) {
              if (value != null) {
                themeNotifier.setTheme(value);
              }
            },
          ),
          RadioListTile<AppThemeMode>(
            title: const Text('System Default'),
            value: AppThemeMode.system,
            groupValue: themeMode,
            onChanged: (value) {
              if (value != null) {
                themeNotifier.setTheme(value);
              }
            },
          ),
        ],
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
              Text('A virtual business card manager with customizable profile cards.'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDataTile() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.storage),
        title: const Text('Clear All Data'),
        subtitle: const Text('Delete all profile cards and contacts'),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.red),
        onTap: () {
          // TODO: Implement clear data functionality
        },
      ),
    );
  }
}