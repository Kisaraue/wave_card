import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/profile_card_widget.dart';
import '../widgets/glassmorphism_container.dart';
import '../widgets/neumorphism_container.dart';
import '../../providers/profile_card_provider.dart';
import '../../providers/contact_provider.dart';
import '../../data/storage/secure_storage_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/toast_utils.dart';
import '../../config/router.dart';
import '../../data/models/contact.dart';
import '../../data/models/profile_card.dart';
import 'qr_scanner_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Initialize toast for this context
    ToastUtils.init(context);
    
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.surface.withOpacity(0.8)],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 100), // Add padding for floating nav
                child: IndexedStack(
                  index: _selectedIndex,
                  children: const [
                    _MyCardsTab(),
                    _MyContactsTab(),
                    _SettingsTab(),
                  ],
                ),
              ),
            ),
            _buildQRScanButton(),
            _buildFloatingBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingBottomNavigationBar() {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 20,
      child: GlassmorphismContainer(
        height: 70,
        borderRadius: 35,
        blur: 15.0,
        opacity: 0.2,
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
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isSelected 
                ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                : Colors.transparent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.grey
                      : AppColors.black,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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

  Widget _buildQRScanButton() {
    return Positioned(
      right: 20,
      bottom: 110, // Above the floating navigation bar
      child: NeumorphismButton(
        onTap: _scanQRCode,
        width: 56,
        height: 56,
        borderRadius: 28,
        backgroundColor: AppColors.buttonColor,
        intensity: 0.5,
        child: Icon(
          Icons.qr_code_scanner,
          color: Theme.of(context).colorScheme.onSurface,
          size: 28,
        ),
      ),
    );
  }

  void _scanQRCode() async {
    final contact = await Navigator.push<Contact>(
      context,
      MaterialPageRoute(
        builder: (context) => const QRScannerScreen(),
      ),
    );

    if (contact != null && mounted) {
      // Show success message
      ToastUtils.showSuccess(
        'Received ${contact.profileCard.fullName}\'s card!',
        isDarkMode: false,
      );
    }
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
                data: (cards) => _buildCardsList(context, ref, cards),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        if (canAddMore)
          NeumorphismButton(
            onTap: () => Navigator.pushNamed(context, AppRouter.createCardWizard),
            padding: const EdgeInsets.all(8),
            borderRadius: 12,
            child: Icon(Icons.add, color: AppColors.grey, size: 32),
          ),
      ],
    );
  }

  Widget _buildCardsList(BuildContext context, WidgetRef ref, List<ProfileCard> cards) {
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
            showActions: true,
            onTap: () => Navigator.pushNamed(
              context,
              AppRouter.editCard,
              arguments: card.id,
            ),
            onEdit: () => Navigator.pushNamed(
              context,
              AppRouter.editCard,
              arguments: card.id,
            ),
            onDuplicate: () => _duplicateCard(context, ref, card),
            onDelete: () => _deleteCard(context, ref, card),
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
          Icon(
            Icons.credit_card_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(height: AppConstants.mediumSpacing),
          Text(
            'No cards yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: AppConstants.smallSpacing),
          Text(
            'Create your first profile card to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.largeSpacing),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonColor,
              foregroundColor: AppColors.black,
            ),
            onPressed: () => Navigator.pushNamed(context, AppRouter.createCardWizard),
            child: const Text('Create Card'),
          ),
        ],
      ),
    );
  }

  void _duplicateCard(BuildContext context, WidgetRef ref, ProfileCard card) async {
    await ref.read(profileCardProvider.notifier).duplicateProfileCard(card);
    ToastUtils.showSuccess(
      'Card duplicated successfully!',
      isDarkMode: false,
    );
  }

  void _deleteCard(BuildContext context, WidgetRef ref, ProfileCard card) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Card'),
          content: Text('Are you sure you want to delete "${card.fullName}" card? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await ref.read(profileCardProvider.notifier).deleteProfileCard(card.id);
                ToastUtils.showSuccess(
                  'Card deleted successfully!',
                  isDarkMode: false,
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

class _MyContactsTab extends ConsumerStatefulWidget {
  const _MyContactsTab();

  @override
  ConsumerState<_MyContactsTab> createState() => _MyContactsTabState();
}

class _MyContactsTabState extends ConsumerState<_MyContactsTab> {
  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(contactProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mediumSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
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
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                NeumorphismButton(
                  onTap: () => Navigator.pushNamed(context, AppRouter.contacts),
                  padding: const EdgeInsets.all(8),
                  borderRadius: 12,
                  child: Icon(Icons.view_list, color: AppColors.grey, size: 24),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.largeSpacing),
            Expanded(
              child: contactsAsync.when(
                data: (contacts) => _buildContactsList(contacts),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildErrorState(error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactsList(List<Contact> contacts) {
    if (contacts.isEmpty) {
      return _buildEmptyState();
    }

    // Show first 5 contacts for preview
    final displayContacts = contacts.take(5).toList();

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: displayContacts.length,
            itemBuilder: (context, index) {
              final contact = displayContacts[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.mediumSpacing),
                child: _buildContactCard(contact),
              );
            },
          ),
        ),
        if (contacts.length > 5)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: AppConstants.smallSpacing),
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRouter.contacts),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.view_list, color: AppColors.grey,),
              label: Text('View All ${contacts.length} Contacts'),
            ),
          ),
      ],
    );
  }

  Widget _buildContactCard(Contact contact) {
    return NeumorphismContainer(
      borderRadius: 16,
      padding: const EdgeInsets.all(AppConstants.smallSpacing),
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          '/contact-detail',
          arguments: contact.id,
        ),
        borderRadius: BorderRadius.circular(16),
        child: Row(
                children: [
                  _buildContactAvatar(contact),
                  const SizedBox(width: AppConstants.smallSpacing),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contact.profileCard.fullName,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          contact.profileCard.jobTitle,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          contact.profileCard.company,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactAvatar(Contact contact) {
    final profileImageUrl = contact.profileCard.profileImageUrl;
    
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
            Theme.of(context).colorScheme.primary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipOval(
        child: _buildAvatarImage(profileImageUrl, contact.profileCard.fullName),
      ),
    );
  }

  Widget _buildAvatarImage(String? profileImageUrl, String fullName) {
    // If no image URL or it's a broken local path, show initials
    if (profileImageUrl == null || 
        profileImageUrl.isEmpty || 
        profileImageUrl.contains('C:\\') || 
        profileImageUrl.contains('c:\\')) {
      return _buildInitialsAvatar(fullName);
    }

    // Try to load the image, with fallback to initials
    if (profileImageUrl.startsWith('http://') || profileImageUrl.startsWith('https://')) {
      return Image.network(
        profileImageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildInitialsAvatar(fullName),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onPrimary),
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    } else {
      // Local file - show initials as fallback since local paths often break
      return _buildInitialsAvatar(fullName);
    }
  }

  Widget _buildInitialsAvatar(String fullName) {
    final initials = _getInitials(fullName);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
            Theme.of(context).colorScheme.primary,
          ],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getInitials(String fullName) {
    final names = fullName.trim().split(' ');
    if (names.isEmpty) return '?';
    if (names.length == 1) return names[0][0].toUpperCase();
    return '${names[0][0].toUpperCase()}${names[names.length - 1][0].toUpperCase()}';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.contacts_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(height: AppConstants.mediumSpacing),
          Text(
            'No contacts yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.smallSpacing),
          Text(
            'Scan QR codes to receive profile cards from others',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.largeSpacing),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const QRScannerScreen()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonColor,
              foregroundColor: AppColors.black,

              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Scan QR Code'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: AppConstants.mediumSpacing),
          Text(
            'Error loading contacts',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.smallSpacing),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.largeSpacing),
          ElevatedButton(
            onPressed: () => ref.refresh(contactProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _SettingsTab extends ConsumerStatefulWidget {
  const _SettingsTab();

  @override
  ConsumerState<_SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends ConsumerState<_SettingsTab> {
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
              content: Text('Backup disabled. Cards will only be saved locally.'),
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
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: AppConstants.largeSpacing),
            Expanded(
              child: ListView(
                children: [
                  _buildSectionHeader(context, 'Backup'),
                  _buildBackupTile(context),
                  const SizedBox(height: 24),
                  _buildSectionHeader(context, 'About'),
                  _buildAboutTile(context),
                  const SizedBox(height: 24),
                  _buildSectionHeader(context, 'Data'),
                  _buildDataTile(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupTile(BuildContext context) {
    return NeumorphismContainer(
      borderRadius: 16,
      intensity: 0.8,
      child: ListTile(
        leading: const Icon(Icons.cloud_upload),
        title: const Text('Backup Cards'),
        subtitle: const Text('Save cards to Firebase Cloud'),
        trailing: _isLoading 
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Switch(
              value: _isBackupEnabled,
              onChanged: _toggleBackup,
            ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }


  Widget _buildAboutTile(BuildContext context) {
    return NeumorphismContainer(
      borderRadius: 16,
      intensity: 0.8,
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

  Widget _buildDataTile(BuildContext context) {
    return NeumorphismContainer(
      borderRadius: 16,
      intensity: 0.8,
      child: ListTile(
        leading: const Icon(Icons.storage),
        title: const Text('Clear All Data'),
        subtitle: const Text('Delete all profile cards and contacts'),
        trailing: Icon(Icons.arrow_forward_ios, color: Theme.of(context).colorScheme.error),
        onTap: () {
          // TODO: Implement clear data functionality
        },
      ),
    );
  }
}