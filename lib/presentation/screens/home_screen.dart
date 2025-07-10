import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/profile_card_widget.dart';
import '../widgets/glassmorphism_container.dart';
import '../../providers/profile_card_provider.dart';
import '../../providers/contact_provider.dart';
import '../../providers/theme_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../config/router.dart';
import '../../data/models/contact.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.white,
                  AppColors.lightGrey,
                ],
              ),
            ),
            child: IndexedStack(
              index: _selectedIndex,
              children: const [
                _MyCardsTab(),
                _MyContactsTab(),
                _SettingsTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        gradient: AppColors.glassGradient,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            icon: Icons.credit_card,
            label: 'My Cards',
            isSelected: _selectedIndex == 0,
            onTap: () => setState(() => _selectedIndex = 0),
          ),
          _buildNavItem(
            icon: Icons.contacts,
            label: 'Contacts',
            isSelected: _selectedIndex == 1,
            onTap: () => setState(() => _selectedIndex = 1),
          ),
          _buildNavItem(
            icon: Icons.settings,
            label: 'Settings',
            isSelected: _selectedIndex == 2,
            onTap: () => setState(() => _selectedIndex = 2),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.yellow : AppColors.grey,
                size: 22,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.yellow : AppColors.grey,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class _MyCardsTab extends ConsumerWidget {
  const _MyCardsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileCardsAsync = ref.watch(profileCardProvider);
    final canAddMore = ref.watch(canAddMoreCardsProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mediumSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, canAddMore),
            const SizedBox(height: AppConstants.largeSpacing),
            Expanded(
              child: profileCardsAsync.when(
                data: (cards) => _buildCardsList(context, cards),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.grey,
                      ),
                      const SizedBox(height: AppConstants.mediumSpacing),
                      Text(
                        'Error loading cards',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AppConstants.smallSpacing),
                      Text(
                        error.toString(),
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool canAddMore) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Cards',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.smallSpacing),
            Text(
              'Create and manage your profile cards',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.grey,
              ),
            ),
          ],
        ),
        if (canAddMore)
          GlassmorphismContainer(
            child: IconButton(
              onPressed: () => Navigator.pushNamed(context, AppRouter.createCardWizard),
              icon: const Icon(Icons.add, color: AppColors.yellow),
              iconSize: 32,
            ),
          ),
      ],
    );
  }

  Widget _buildCardsList(BuildContext context, List cards) {
    if (cards.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.mediumSpacing),
          child: ProfileCardWidget(
            profileCard: card,
            onTap: () => Navigator.pushNamed(
              context,
              AppRouter.editCard,
              arguments: card.id,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.credit_card_outlined,
            size: 80,
            color: AppColors.grey,
          ),
          const SizedBox(height: AppConstants.mediumSpacing),
          Text(
            'No cards yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: AppConstants.smallSpacing),
          Text(
            'Create your first profile card to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.largeSpacing),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRouter.createCardWizard),
            icon: const Icon(Icons.add),
            label: const Text('Create Card'),
          ),
        ],
      ),
    );
  }
}

class _MyContactsTab extends StatelessWidget {
  const _MyContactsTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mediumSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Contacts',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.smallSpacing),
            Text(
              'View and manage received cards',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.grey,
              ),
            ),
            const SizedBox(height: AppConstants.largeSpacing),
            Expanded(
              child: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, AppRouter.contacts),
                  child: const Text('View All Contacts'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mediumSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.smallSpacing),
            Text(
              'Customize your app experience',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.grey,
              ),
            ),
            const SizedBox(height: AppConstants.largeSpacing),
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final themeMode = ref.watch(themeProvider);
                  final themeNotifier = ref.read(themeProvider.notifier);
                  
                  return ListView(
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
                  );
                },
              ),
            ),
          ],
        ),
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