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

class ContactDetailScreen extends ConsumerStatefulWidget {
  final String? contactId;

  const ContactDetailScreen({super.key, this.contactId});

  @override
  ConsumerState<ContactDetailScreen> createState() =>
      _ContactDetailScreenState();
}

class _ContactDetailScreenState extends ConsumerState<ContactDetailScreen> {
  final TextEditingController _notesController = TextEditingController();
  bool _isEditingNotes = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Initialize toast for this context
    ToastUtils.init(context);

    if (widget.contactId == null) {
      return _buildErrorScaffold('No contact ID provided');
    }

    final contact = ref.watch(contactByIdProvider(widget.contactId!));

    if (contact == null) {
      return _buildErrorScaffold('Contact not found');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(contact.profileCard.fullName),
        // backgroundColor: Theme.of(context).colorScheme.primary,
        // foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              contact.isFavorite ? Icons.favorite : Icons.favorite_border,
              color:
                  contact.isFavorite
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: () => _toggleFavorite(contact),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'delete':
                  _showDeleteConfirmation(contact);
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete,
                          color: Theme.of(context).colorScheme.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Delete Contact',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surfaceContainerLow,
              ],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.mediumSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileCard(contact),
                const SizedBox(height: AppConstants.largeSpacing),
                _buildContactInfo(contact),
                const SizedBox(height: AppConstants.largeSpacing),
                _buildSocialLinks(contact),
                const SizedBox(height: AppConstants.largeSpacing),
                _buildNotes(contact),
                const SizedBox(height: AppConstants.largeSpacing),
                _buildReceivedInfo(contact),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScaffold(String message) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Details'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Center(
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
              message,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.largeSpacing),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(Contact contact) {
    return NeumorphismContainer(
      borderRadius: 20,
      intensity: 1.1,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largeSpacing),
        child: Center(
          child: ProfileCardWidget(profileCard: contact.profileCard),
        ),
      ),
    );
  }

  Widget _buildContactInfo(Contact contact) {
    final card = contact.profileCard;

    return NeumorphismContainer(
      borderRadius: 16,
      intensity: 0.9,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mediumSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.mediumSpacing),
            _buildInfoRow(Icons.person, 'Name', card.fullName),
            _buildInfoRow(Icons.work, 'Job Title', card.jobTitle),
            _buildInfoRow(Icons.business, 'Company', card.company),
            if (card.email != null)
              _buildInfoRow(
                Icons.email,
                'Email',
                card.email!,
                onTap: () => _sendEmail(card.email!),
              ),
            if (card.phone != null)
              _buildInfoRow(
                Icons.phone,
                'Phone',
                card.phone!,
                onTap: () => _makePhoneCall(card.phone!),
              ),
            if (card.address != null)
              _buildInfoRow(Icons.location_on, 'Address', card.address!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.smallSpacing),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color:
                    onTap != null
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: AppConstants.mediumSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color:
                            onTap != null
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.open_in_new,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLinks(Contact contact) {
    final socialLinks = contact.profileCard.socialLinks;

    if (socialLinks.isEmpty) {
      return const SizedBox.shrink();
    }

    return NeumorphismContainer(
      borderRadius: 16,
      intensity: 0.9,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mediumSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Social Links',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.mediumSpacing),
            ...socialLinks.entries.map(
              (entry) => _buildSocialLinkRow(entry.key, entry.value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialLinkRow(String platform, String url) {
    return Consumer(
      builder: (context, ref, child) {
        IconData icon;
        Color color;

        switch (platform.toLowerCase()) {
          case 'linkedin':
            icon = Icons.business;
            // Use brand color for LinkedIn
            color = const Color(0xFF0077B5);
            break;
          case 'twitter':
            icon = Icons.alternate_email;
            // Use brand color for Twitter/X
            color = const Color(0xFF1DA1F2);
            break;
          case 'instagram':
            icon = Icons.camera_alt;
            // Use brand color for Instagram
            color = const Color(0xFFE4405F);
            break;
          case 'github':
            icon = Icons.code;
            // Use GitHub color for light mode
            color = const Color(0xFF333333);
            break;
          case 'facebook':
            icon = Icons.facebook;
            // Use brand color for Facebook
            color = const Color(0xFF1877F2);
            break;
          default:
            icon = Icons.link;
            color = Theme.of(context).colorScheme.primary;
        }

        return _buildSocialLinkRowContent(icon, color, platform, url);
      },
    );
  }

  Widget _buildSocialLinkRowContent(
    IconData icon,
    Color color,
    String platform,
    String url,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.smallSpacing),
      child: InkWell(
        onTap: () => _openUrl(url),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: AppConstants.mediumSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      platform.toUpperCase(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      url,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.open_in_new, size: 16, color: color.withOpacity(0.7)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotes(Contact contact) {
    return NeumorphismContainer(
      borderRadius: 16,
      intensity: 0.9,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mediumSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Notes',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(_isEditingNotes ? Icons.check : Icons.edit),
                  onPressed: () => _toggleNotesEditing(contact),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: AppConstants.mediumSpacing),
            _isEditingNotes
                ? TextField(
                  controller: _notesController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Add notes about this contact...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                )
                : Text(
                  contact.notes?.isNotEmpty == true
                      ? contact.notes!
                      : 'No notes added yet. Tap the edit button to add notes.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color:
                        contact.notes?.isNotEmpty == true
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                    fontStyle:
                        contact.notes?.isNotEmpty == true
                            ? FontStyle.normal
                            : FontStyle.italic,
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceivedInfo(Contact contact) {
    return NeumorphismContainer(
      borderRadius: 16,
      intensity: 0.9,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mediumSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Details',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.mediumSpacing),
            _buildInfoRow(
              Icons.calendar_today,
              'Received',
              _formatDate(contact.receivedAt),
            ),
            _buildInfoRow(Icons.qr_code, 'Contact ID', contact.id),
          ],
        ),
      ),
    );
  }

  void _toggleFavorite(Contact contact) {
    ref.read(contactProvider.notifier).toggleFavorite(contact.id);
  }

  void _toggleNotesEditing(Contact contact) {
    if (_isEditingNotes) {
      // Save notes
      ref
          .read(contactProvider.notifier)
          .updateContactNotes(contact.id, _notesController.text);
    } else {
      // Start editing
      _notesController.text = contact.notes ?? '';
    }

    setState(() {
      _isEditingNotes = !_isEditingNotes;
    });
  }

  void _showDeleteConfirmation(Contact contact) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Contact'),
            content: Text(
              'Are you sure you want to delete ${contact.profileCard.fullName}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  ref.read(contactProvider.notifier).deleteContact(contact.id);
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Go back to contacts list
                },
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
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

  void _openUrl(String url) async {
    Uri uri;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      uri = Uri.parse('https://$url');
    } else {
      uri = Uri.parse(url);
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showError('Could not open URL');
    }
  }

  void _showError(String message) {
    ToastUtils.showError(message, isDarkMode: false);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today at ${_formatTime(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${_formatTime(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
