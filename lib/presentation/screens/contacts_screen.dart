import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/toast_utils.dart';
import '../../providers/contact_provider.dart';
import '../../data/models/contact.dart';
import '../widgets/profile_card_widget.dart';
import '../widgets/glassmorphism_container.dart';
import '../widgets/neumorphism_container.dart';

class ContactsScreen extends ConsumerStatefulWidget {
  const ContactsScreen({super.key});

  @override
  ConsumerState<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<ContactsScreen> {
  final TextEditingController _searchController = TextEditingController();
  ContactSortBy _sortBy = ContactSortBy.receivedAt;
  bool _isAscending = false;
  bool _showFavoritesOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Initialize toast for this context
    ToastUtils.init(context);

    final contactsAsync = ref.watch(contactProvider);
    final searchQuery = ref.watch(contactSearchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Contacts'),
        // backgroundColor: Theme.of(context).colorScheme.primary,
        // foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
            ),
            onPressed: () {
              setState(() {
                _showFavoritesOnly = !_showFavoritesOnly;
              });
            },
          ),
          PopupMenuButton<ContactSortBy>(
            icon: const Icon(Icons.sort),
            onSelected: (sortBy) {
              setState(() {
                if (_sortBy == sortBy) {
                  _isAscending = !_isAscending;
                } else {
                  _sortBy = sortBy;
                  _isAscending = false;
                }
              });
            },
            itemBuilder:
                (context) =>
                    ContactSortBy.values.map((sortBy) {
                      return PopupMenuItem(
                        value: sortBy,
                        child: Row(
                          children: [
                            Icon(
                              _sortBy == sortBy
                                  ? (_isAscending
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward)
                                  : Icons.radio_button_unchecked,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(sortBy.displayName),
                          ],
                        ),
                      );
                    }).toList(),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          children: [
            _buildSearchBar(),
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

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.mediumSpacing),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          ref.read(contactSearchProvider.notifier).state = value;
        },
        decoration: InputDecoration(
          hintText: 'Search contacts...',
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(contactSearchProvider.notifier).state = '';
                    },
                  )
                  : null,
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildContactsList(List<Contact> allContacts) {
    // Apply filters
    List<Contact> filteredContacts = allContacts;

    // Filter by search query
    final searchQuery = ref.watch(contactSearchProvider);
    if (searchQuery.isNotEmpty) {
      filteredContacts =
          filteredContacts.where((contact) {
            final query = searchQuery.toLowerCase();
            final card = contact.profileCard;
            return card.fullName.toLowerCase().contains(query) ||
                card.jobTitle.toLowerCase().contains(query) ||
                card.company.toLowerCase().contains(query) ||
                (card.email?.toLowerCase().contains(query) ?? false);
          }).toList();
    }

    // Filter by favorites
    if (_showFavoritesOnly) {
      filteredContacts =
          filteredContacts.where((contact) => contact.isFavorite).toList();
    }

    // Apply sorting
    filteredContacts.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case ContactSortBy.receivedAt:
          comparison = a.receivedAt.compareTo(b.receivedAt);
          break;
        case ContactSortBy.name:
          comparison = a.profileCard.fullName.compareTo(b.profileCard.fullName);
          break;
        case ContactSortBy.company:
          comparison = a.profileCard.company.compareTo(b.profileCard.company);
          break;
        case ContactSortBy.favorite:
          comparison =
              a.isFavorite == b.isFavorite ? 0 : (a.isFavorite ? -1 : 1);
          break;
      }
      return _isAscending ? comparison : -comparison;
    });

    if (filteredContacts.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.mediumSpacing,
      ),
      itemCount: filteredContacts.length,
      itemBuilder: (context, index) {
        final contact = filteredContacts[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.mediumSpacing),
          child: _buildContactCard(contact),
        );
      },
    );
  }

  Widget _buildContactCard(Contact contact) {
    return NeumorphismContainer(
      borderRadius: 20,
      intensity: 1.1,
      child: InkWell(
        onTap: () => _showContactDetails(contact),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.mediumSpacing),
          child: Row(
            children: [
              // Profile image
              _buildContactAvatar(contact),
              const SizedBox(width: AppConstants.mediumSpacing),
              // Contact info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            contact.profileCard.fullName,
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color:
                                contact.isFavorite
                                    ? Theme.of(
                                      context,
                                    ).colorScheme.error.withOpacity(0.1)
                                    : Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            icon: Icon(
                              contact.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color:
                                  contact.isFavorite
                                      ? Theme.of(context).colorScheme.error
                                      : Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.6),
                              size: 20,
                            ),
                            onPressed: () => _toggleFavorite(contact),
                            padding: const EdgeInsets.all(6),
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      contact.profileCard.jobTitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      contact.profileCard.company,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 12,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Received ${_formatDate(contact.receivedAt)}',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.6),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Quick actions
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (contact.profileCard.phone != null)
                      NeumorphismButton(
                        margin: const EdgeInsets.only(bottom: 8),
                        onTap: () => _makePhoneCall(contact.profileCard.phone!),
                        borderRadius: 22,
                        intensity: 0.8,
                        child: Icon(
                          Icons.phone,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    if (contact.profileCard.email != null)
                      NeumorphismButton(
                        onTap: () => _sendEmail(contact.profileCard.email!),
                        borderRadius: 22,
                        intensity: 0.8,
                        child: Icon(
                          Icons.email,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactAvatar(Contact contact) {
    final profileImageUrl = contact.profileCard.profileImageUrl;

    return Container(
      width: 60,
      height: 60,
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
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
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
    if (profileImageUrl.startsWith('http://') ||
        profileImageUrl.startsWith('https://')) {
      return Image.network(
        profileImageUrl,
        fit: BoxFit.cover,
        errorBuilder:
            (context, error, stackTrace) => _buildInitialsAvatar(fullName),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              value:
                  loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
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
            fontSize: 20,
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
    String message;
    String subtitle;

    if (_showFavoritesOnly) {
      message = 'No favorite contacts';
      subtitle = 'Mark contacts as favorites to see them here';
    } else if (ref.watch(contactSearchProvider).isNotEmpty) {
      message = 'No contacts found';
      subtitle = 'Try adjusting your search terms';
    } else {
      message = 'No contacts yet';
      subtitle = 'Scan QR codes to receive profile cards from others';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _showFavoritesOnly
                ? Icons.favorite_border
                : Icons.contacts_outlined,
            size: 80,
            color: AppColors.grey,
          ),
          const SizedBox(height: AppConstants.mediumSpacing),
          Text(
            message,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.smallSpacing),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          if (!_showFavoritesOnly &&
              ref.watch(contactSearchProvider).isEmpty) ...[
            const SizedBox(height: AppConstants.largeSpacing),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
                foregroundColor: AppColors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan QR Code'),
            ),
          ],
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

  void _showContactDetails(Contact contact) {
    Navigator.pushNamed(context, '/contact-detail', arguments: contact.id);
  }

  void _toggleFavorite(Contact contact) {
    ref.read(contactProvider.notifier).toggleFavorite(contact.id);
  }

  void _makePhoneCall(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showError('Could not make phone call');
    }
  }

  void _sendEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showError('Could not send email');
    }
  }

  void _showError(String message) {
    ToastUtils.showError(message, isDarkMode: false);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1 year ago' : '$years years ago';
    }
  }
}
