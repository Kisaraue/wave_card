import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../widgets/profile_card_widget.dart';
import '../widgets/glassmorphism_container.dart';
import '../../providers/profile_card_provider.dart';
import '../../data/models/profile_card.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

class ProfileCardEditScreen extends ConsumerStatefulWidget {
  final String? cardId;

  const ProfileCardEditScreen({super.key, this.cardId});

  @override
  ConsumerState<ProfileCardEditScreen> createState() =>
      _ProfileCardEditScreenState();
}

class _ProfileCardEditScreenState extends ConsumerState<ProfileCardEditScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _companyController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  // Social media controllers
  final _facebookController = TextEditingController();
  final _twitterController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _instagramController = TextEditingController();
  final _websiteController = TextEditingController();
  final _githubController = TextEditingController();
  final _youtubeController = TextEditingController();
  final _tiktokController = TextEditingController();

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  bool _isInitialized = false;

  // Tab controller
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fullNameController.dispose();
    _jobTitleController.dispose();
    _companyController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _facebookController.dispose();
    _twitterController.dispose();
    _linkedinController.dispose();
    _instagramController.dispose();
    _websiteController.dispose();
    _githubController.dispose();
    _youtubeController.dispose();
    _tiktokController.dispose();
    super.dispose();
  }

  void _initializeForm(ProfileCard card) {
    if (_isInitialized) return;

    _fullNameController.text = card.fullName;
    _jobTitleController.text = card.jobTitle;
    _companyController.text = card.company;
    _emailController.text = card.email ?? '';
    _phoneController.text = card.phone ?? '';
    _addressController.text = card.address ?? '';

    // Initialize social media fields
    _facebookController.text = card.socialLinks['facebook'] ?? '';
    _twitterController.text = card.socialLinks['twitter'] ?? '';
    _linkedinController.text = card.socialLinks['linkedin'] ?? '';
    _instagramController.text = card.socialLinks['instagram'] ?? '';
    _websiteController.text = card.socialLinks['website'] ?? '';
    _githubController.text = card.socialLinks['github'] ?? '';
    _youtubeController.text = card.socialLinks['youtube'] ?? '';
    _tiktokController.text = card.socialLinks['tiktok'] ?? '';

    // Initialize profile image if it exists and is a local file
    if (card.profileImageUrl != null &&
        !card.profileImageUrl!.startsWith('http') &&
        File(card.profileImageUrl!).existsSync()) {
      _profileImage = File(card.profileImageUrl!);
    }

    // Initialize form state with existing card data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cardFormProvider.notifier).setCard(card);
    });

    _isInitialized = true;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
        _updateCardForm();
      }
    } catch (e) {
      if (mounted) {
        String errorMessage =
            'Unable to access ${source == ImageSource.camera ? 'camera' : 'gallery'}';

        if (e.toString().contains('Permission')) {
          errorMessage =
              '${source == ImageSource.camera ? 'Camera' : 'Gallery'} permission denied. Please enable it in device settings.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      }
    }
  }

  void _updateCardForm() {
    final cardFormNotifier = ref.read(cardFormProvider.notifier);
    final currentCard = ref.read(cardFormProvider);

    // Update social media links
    _updateSocialLinks(cardFormNotifier);

    cardFormNotifier.updateMultipleFields(
      fullName: _fullNameController.text,
      jobTitle: _jobTitleController.text,
      company: _companyController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      profileImageUrl: _profileImage?.path ?? currentCard.profileImageUrl,
    );
  }

  void _updateSocialLinks(cardFormNotifier) {
    cardFormNotifier.updateSocialLink('facebook', _facebookController.text);
    cardFormNotifier.updateSocialLink('twitter', _twitterController.text);
    cardFormNotifier.updateSocialLink('linkedin', _linkedinController.text);
    cardFormNotifier.updateSocialLink('instagram', _instagramController.text);
    cardFormNotifier.updateSocialLink('website', _websiteController.text);
    cardFormNotifier.updateSocialLink('github', _githubController.text);
    cardFormNotifier.updateSocialLink('youtube', _youtubeController.text);
    cardFormNotifier.updateSocialLink('tiktok', _tiktokController.text);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cardId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Profile Card')),
        body: const Center(child: Text('No card ID provided')),
      );
    }

    final card = ref.watch(profileCardByIdProvider(widget.cardId!));

    if (card == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Profile Card')),
        body: const Center(child: Text('Card not found')),
      );
    }

    // Initialize form with existing card data
    _initializeForm(card);

    final cardForm = ref.watch(cardFormProvider);
    final cardFormNotifier = ref.watch(cardFormProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile Card'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed:
                () => _updateCard(context, ref, _formKey, widget.cardId!),
            child: const Text(
              'Save',
              style: TextStyle(
                color: AppColors.yellow,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.white, AppColors.lightGrey],
          ),
        ),
        child: Column(
          children: [
            // Card Preview
            Padding(
              padding: const EdgeInsets.all(AppConstants.mediumSpacing),
              child: _buildCardPreview(cardForm),
            ),

            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppConstants.mediumSpacing,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade400, width: 1),
              ),
              child: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text('Personal'),
                    ),
                  ),
                  Tab(
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text('Profile'),
                    ),
                  ),
                  Tab(
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text('Social'),
                    ),
                  ),
                  Tab(
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text('Style'),
                    ),
                  ),
                ],
                labelColor: Colors.black,
                unselectedLabelColor: AppColors.grey,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.yellow.withOpacity(0.2),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                isScrollable: false,
              ),
            ),

            // Tab Content
            Expanded(
              child: Form(
                key: _formKey,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPersonalDetailsTab(cardFormNotifier),
                    _buildProfileImageTab(),
                    _buildSocialMediaTab(cardFormNotifier),
                    _buildStyleCustomizationTab(cardFormNotifier),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardPreview(ProfileCard profileCard) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Card Preview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: AppConstants.mediumSpacing),
        Center(child: ProfileCardWidget(profileCard: profileCard)),
      ],
    );
  }

  Widget _buildPersonalDetailsTab(CardFormNotifier cardFormNotifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.mediumSpacing),
      child: GlassmorphismContainer(
        padding: const EdgeInsets.all(AppConstants.mediumSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: AppConstants.mediumSpacing),
            _buildTextField(
              controller: _fullNameController,
              label: 'Full Name',
              icon: Icons.person,
              required: true,
              onChanged: (value) => cardFormNotifier.updateFullName(value),
            ),
            const SizedBox(height: AppConstants.mediumSpacing),
            _buildTextField(
              controller: _jobTitleController,
              label: 'Job Title',
              icon: Icons.work,
              required: true,
              onChanged: (value) => cardFormNotifier.updateJobTitle(value),
            ),
            const SizedBox(height: AppConstants.mediumSpacing),
            _buildTextField(
              controller: _companyController,
              label: 'Company',
              icon: Icons.business,
              required: true,
              onChanged: (value) => cardFormNotifier.updateCompany(value),
            ),
            const SizedBox(height: AppConstants.largeSpacing),
            const Text(
              'Contact Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: AppConstants.mediumSpacing),
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) => cardFormNotifier.updateEmail(value),
            ),
            const SizedBox(height: AppConstants.mediumSpacing),
            _buildTextField(
              controller: _phoneController,
              label: 'Phone',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              onChanged: (value) => cardFormNotifier.updatePhone(value),
            ),
            const SizedBox(height: AppConstants.mediumSpacing),
            _buildTextField(
              controller: _addressController,
              label: 'Address',
              icon: Icons.location_on,
              maxLines: 2,
              onChanged: (value) => cardFormNotifier.updateAddress(value),
            ),
            const SizedBox(height: AppConstants.largeSpacing),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    () => _updateCard(context, ref, _formKey, widget.cardId!),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Update Card',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImageTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.mediumSpacing),
      child: GlassmorphismContainer(
        padding: const EdgeInsets.all(AppConstants.mediumSpacing),
        child: _buildProfilePictureSection(),
      ),
    );
  }

  Widget _buildSocialMediaTab(CardFormNotifier cardFormNotifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.mediumSpacing),
      child: GlassmorphismContainer(
        padding: const EdgeInsets.all(AppConstants.mediumSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Social Media',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: AppConstants.smallSpacing),
            const Text(
              'Add your social media links (Optional)',
              style: TextStyle(fontSize: 14, color: AppColors.grey),
            ),
            const SizedBox(height: AppConstants.largeSpacing),
            _buildTextField(
              controller: _facebookController,
              label: 'Facebook',
              icon: Icons.facebook,
              onChanged: (value) {
                cardFormNotifier.updateSocialLink('facebook', value);
              },
            ),
            const SizedBox(height: AppConstants.mediumSpacing),
            _buildTextField(
              controller: _twitterController,
              label: 'Twitter',
              icon: Icons.alternate_email,
              onChanged: (value) {
                cardFormNotifier.updateSocialLink('twitter', value);
              },
            ),
            const SizedBox(height: AppConstants.mediumSpacing),
            _buildTextField(
              controller: _linkedinController,
              label: 'LinkedIn',
              icon: Icons.business_center,
              onChanged: (value) {
                cardFormNotifier.updateSocialLink('linkedin', value);
              },
            ),
            const SizedBox(height: AppConstants.mediumSpacing),
            _buildTextField(
              controller: _instagramController,
              label: 'Instagram',
              icon: Icons.photo_camera,
              onChanged: (value) {
                cardFormNotifier.updateSocialLink('instagram', value);
              },
            ),
            const SizedBox(height: AppConstants.mediumSpacing),
            _buildTextField(
              controller: _websiteController,
              label: 'Website',
              icon: Icons.web,
              onChanged: (value) {
                cardFormNotifier.updateSocialLink('website', value);
              },
            ),
            const SizedBox(height: AppConstants.mediumSpacing),
            _buildTextField(
              controller: _githubController,
              label: 'GitHub',
              icon: Icons.code,
              onChanged: (value) {
                cardFormNotifier.updateSocialLink('github', value);
              },
            ),
            const SizedBox(height: AppConstants.mediumSpacing),
            _buildTextField(
              controller: _youtubeController,
              label: 'YouTube',
              icon: Icons.video_library,
              onChanged: (value) {
                cardFormNotifier.updateSocialLink('youtube', value);
              },
            ),
            const SizedBox(height: AppConstants.mediumSpacing),
            _buildTextField(
              controller: _tiktokController,
              label: 'TikTok',
              icon: Icons.music_video,
              onChanged: (value) {
                cardFormNotifier.updateSocialLink('tiktok', value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyleCustomizationTab(CardFormNotifier cardFormNotifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.mediumSpacing),
      child: GlassmorphismContainer(
        padding: const EdgeInsets.all(AppConstants.mediumSpacing),
        child: _buildStyleCustomization(context, cardFormNotifier),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.yellow, width: 2),
        ),
      ),
      validator:
          required
              ? (value) {
                if (value == null || value.isEmpty) {
                  return 'This field is required';
                }
                return null;
              }
              : null,
      onChanged: onChanged,
    );
  }

  Future<void> _updateCard(
    BuildContext context,
    WidgetRef? ref,
    GlobalKey<FormState> formKey,
    String cardId,
  ) async {
    if (formKey.currentState == null || !formKey.currentState!.validate()) {
      return;
    }

    try {
      if (ref != null) {
        final cardForm = ref.read(cardFormProvider);
        final profileCardNotifier = ref.read(profileCardProvider.notifier);

        // Create updated card with the same ID
        final updatedCard = ProfileCard(
          id: cardId,
          fullName: cardForm.fullName,
          jobTitle: cardForm.jobTitle,
          company: cardForm.company,
          profileImageUrl: cardForm.profileImageUrl,
          email: cardForm.email,
          phone: cardForm.phone,
          address: cardForm.address,
          socialLinks: cardForm.socialLinks,
          customFields: cardForm.customFields,
          cardStyle: cardForm.cardStyle,
        );

        await profileCardNotifier.updateProfileCard(updatedCard);

        if (context.mounted) {
          ref.read(cardFormProvider.notifier).reset();
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile card updated successfully!'),
              backgroundColor: AppColors.yellow,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating card: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildProfilePictureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Profile Picture',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: AppConstants.smallSpacing),
        const Text(
          'Add or update your profile picture (Optional)',
          style: TextStyle(fontSize: 14, color: AppColors.grey),
        ),
        const SizedBox(height: AppConstants.mediumSpacing),
        Center(
          child: Column(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.grey, width: 2),
                ),
                child: ClipOval(child: _buildProfileImageWidget()),
              ),
              const SizedBox(height: AppConstants.mediumSpacing),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.yellow,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.yellow,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              if (_hasProfileImage()) ...[
                const SizedBox(height: AppConstants.mediumSpacing),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _profileImage = null;
                    });
                    // Clear the profile image from the form
                    ref.read(cardFormProvider.notifier).updateProfileImage('');
                    _updateCardForm();
                  },
                  child: const Text(
                    'Remove Photo',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  bool _hasProfileImage() {
    if (_profileImage != null) return true;

    final cardForm = ref.watch(cardFormProvider);
    return cardForm.profileImageUrl != null &&
        cardForm.profileImageUrl!.isNotEmpty;
  }

  Widget _buildProfileImageWidget() {
    // If user has selected a new image, show it
    if (_profileImage != null) {
      return Image.file(
        _profileImage!,
        fit: BoxFit.cover,
        width: 120,
        height: 120,
        errorBuilder:
            (context, error, stackTrace) =>
                const Icon(Icons.person, size: 60, color: AppColors.grey),
      );
    }

    // If card has existing profile image URL, show it
    final cardForm = ref.watch(cardFormProvider);
    if (cardForm.profileImageUrl != null &&
        cardForm.profileImageUrl!.isNotEmpty) {
      final imageUrl = cardForm.profileImageUrl!;

      // Check if it's a network URL
      if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: 120,
          height: 120,
          errorBuilder:
              (context, error, stackTrace) =>
                  const Icon(Icons.person, size: 60, color: AppColors.grey),
        );
      } else {
        // Handle local file
        final file = File(imageUrl);
        if (file.existsSync()) {
          return Image.file(
            file,
            fit: BoxFit.cover,
            width: 120,
            height: 120,
            errorBuilder:
                (context, error, stackTrace) =>
                    const Icon(Icons.person, size: 60, color: AppColors.grey),
          );
        }
      }
    }

    // Default: no image
    return Container(
      width: 120,
      height: 120,
      color: AppColors.lightGrey,
      child: const Icon(Icons.person, size: 60, color: AppColors.grey),
    );
  }

  Widget _buildStyleCustomization(
    BuildContext context,
    CardFormNotifier cardFormNotifier,
  ) {
    final currentStyle = ref.watch(cardFormProvider).cardStyle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Card Style Customization',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: AppConstants.mediumSpacing),

        // Font Family Selection
        _buildFontFamilySelector(currentStyle, cardFormNotifier),
        const SizedBox(height: AppConstants.mediumSpacing),

        // Font Size Slider
        _buildFontSizeSlider(currentStyle, cardFormNotifier),
        const SizedBox(height: AppConstants.mediumSpacing),

        // Font Weight Selection
        _buildFontWeightSelector(currentStyle, cardFormNotifier),
        const SizedBox(height: AppConstants.mediumSpacing),

        // Text Color Selection
        _buildTextColorSelector(currentStyle, cardFormNotifier),
        const SizedBox(height: AppConstants.mediumSpacing),

        // Background Type Selection
        _buildBackgroundTypeSelector(currentStyle, cardFormNotifier),
        const SizedBox(height: AppConstants.mediumSpacing),

        // Background Color/Gradient based on type
        if (currentStyle.backgroundType == 'solid')
          _buildBackgroundColorSelector(currentStyle, cardFormNotifier)
        else if (currentStyle.backgroundType == 'gradient')
          _buildGradientColorSelector(currentStyle, cardFormNotifier),

        const SizedBox(height: AppConstants.mediumSpacing),

        // Template Selection
        _buildTemplateSelector(currentStyle, cardFormNotifier),
      ],
    );
  }

  Widget _buildFontFamilySelector(
    CardStyle currentStyle,
    CardFormNotifier cardFormNotifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Font Family',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: AppConstants.smallSpacing),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.grey),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            value: currentStyle.fontFamily,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items:
                AppConstants.fontFamilies.map((font) {
                  return DropdownMenuItem<String>(
                    value: font,
                    child: Text(font, style: TextStyle(fontFamily: font)),
                  );
                }).toList(),
            onChanged: (value) {
              if (value != null) {
                final updatedStyle = currentStyle.copyWith(fontFamily: value);
                cardFormNotifier.updateCardStyle(updatedStyle);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFontSizeSlider(
    CardStyle currentStyle,
    CardFormNotifier cardFormNotifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Font Size: ${currentStyle.fontSize.toInt()}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: AppConstants.smallSpacing),
        Slider(
          value: currentStyle.fontSize,
          min: 10.0,
          max: 24.0,
          divisions: 14,
          activeColor: AppColors.yellow,
          onChanged: (value) {
            final updatedStyle = currentStyle.copyWith(fontSize: value);
            cardFormNotifier.updateCardStyle(updatedStyle);
          },
        ),
      ],
    );
  }

  Widget _buildFontWeightSelector(
    CardStyle currentStyle,
    CardFormNotifier cardFormNotifier,
  ) {
    const fontWeights = [
      FontWeight.w300,
      FontWeight.w400,
      FontWeight.w500,
      FontWeight.w600,
      FontWeight.w700,
    ];

    const fontWeightNames = ['Light', 'Regular', 'Medium', 'Semi-Bold', 'Bold'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Font Weight',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: AppConstants.smallSpacing),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.grey),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<FontWeight>(
            value: currentStyle.fontWeight,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items:
                fontWeights.asMap().entries.map((entry) {
                  final index = entry.key;
                  final weight = entry.value;
                  return DropdownMenuItem<FontWeight>(
                    value: weight,
                    child: Text(
                      fontWeightNames[index],
                      style: TextStyle(fontWeight: weight),
                    ),
                  );
                }).toList(),
            onChanged: (value) {
              if (value != null) {
                final updatedStyle = currentStyle.copyWith(fontWeight: value);
                cardFormNotifier.updateCardStyle(updatedStyle);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTextColorSelector(
    CardStyle currentStyle,
    CardFormNotifier cardFormNotifier,
  ) {
    final colors = [
      Colors.black,
      Colors.white,
      Colors.grey[800]!,
      AppColors.yellow,
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Text Color',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: AppConstants.smallSpacing),
        Wrap(
          spacing: 8.0,
          children:
              colors.map((color) {
                final isSelected = currentStyle.textColor == color;
                return GestureDetector(
                  onTap: () {
                    final updatedStyle = currentStyle.copyWith(
                      textColor: color,
                    );
                    cardFormNotifier.updateCardStyle(updatedStyle);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.yellow : Colors.grey,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child:
                        isSelected
                            ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                            : null,
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildBackgroundTypeSelector(
    CardStyle currentStyle,
    CardFormNotifier cardFormNotifier,
  ) {
    const backgroundTypes = ['solid', 'gradient'];
    const backgroundTypeNames = ['Solid Color', 'Gradient'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Background Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: AppConstants.smallSpacing),
        Row(
          children:
              backgroundTypes.asMap().entries.map((entry) {
                final index = entry.key;
                final type = entry.value;
                final isSelected = currentStyle.backgroundType == type;

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      final updatedStyle = currentStyle.copyWith(
                        backgroundType: type,
                      );
                      cardFormNotifier.updateCardStyle(updatedStyle);
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: index == 0 ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? AppColors.yellow : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? AppColors.yellow : AppColors.grey,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        backgroundTypeNames[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.black,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildBackgroundColorSelector(
    CardStyle currentStyle,
    CardFormNotifier cardFormNotifier,
  ) {
    final colors = [
      Colors.white,
      Colors.grey[100]!,
      Colors.grey[200]!,
      Colors.blue[50]!,
      Colors.green[50]!,
      Colors.yellow[50]!,
      Colors.red[50]!,
      Colors.purple[50]!,
      Colors.orange[50]!,
      Colors.teal[50]!,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Background Color',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: AppConstants.smallSpacing),
        Wrap(
          spacing: 8.0,
          children:
              colors.map((color) {
                final isSelected = currentStyle.backgroundColor == color;
                return GestureDetector(
                  onTap: () {
                    final updatedStyle = currentStyle.copyWith(
                      backgroundColor: color,
                    );
                    cardFormNotifier.updateCardStyle(updatedStyle);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.yellow : Colors.grey,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child:
                        isSelected
                            ? const Icon(
                              Icons.check,
                              color: AppColors.yellow,
                              size: 20,
                            )
                            : null,
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildGradientColorSelector(
    CardStyle currentStyle,
    CardFormNotifier cardFormNotifier,
  ) {
    final gradientPresets = [
      [Colors.white, Colors.grey[100]!],
      [Colors.blue[50]!, Colors.blue[100]!],
      [Colors.green[50]!, Colors.green[100]!],
      [Colors.yellow[50]!, Colors.yellow[100]!],
      [Colors.red[50]!, Colors.red[100]!],
      [Colors.purple[50]!, Colors.purple[100]!],
      [Colors.orange[50]!, Colors.orange[100]!],
      [Colors.teal[50]!, Colors.teal[100]!],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gradient Colors',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: AppConstants.smallSpacing),
        Wrap(
          spacing: 8.0,
          children:
              gradientPresets.map((gradient) {
                final isSelected =
                    currentStyle.gradientColors.length == 2 &&
                    currentStyle.gradientColors[0] == gradient[0] &&
                    currentStyle.gradientColors[1] == gradient[1];

                return GestureDetector(
                  onTap: () {
                    final updatedStyle = currentStyle.copyWith(
                      gradientColors: gradient,
                    );
                    cardFormNotifier.updateCardStyle(updatedStyle);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.yellow : Colors.grey,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child:
                        isSelected
                            ? const Icon(
                              Icons.check,
                              color: AppColors.yellow,
                              size: 20,
                            )
                            : null,
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildTemplateSelector(
    CardStyle currentStyle,
    CardFormNotifier cardFormNotifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Card Template',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: AppConstants.smallSpacing),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.grey),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            value: currentStyle.template,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items:
                AppConstants.cardTemplates.map((template) {
                  return DropdownMenuItem<String>(
                    value: template,
                    child: Text(template),
                  );
                }).toList(),
            onChanged: (value) {
              if (value != null) {
                final updatedStyle = currentStyle.copyWith(template: value);
                cardFormNotifier.updateCardStyle(updatedStyle);
              }
            },
          ),
        ),
      ],
    );
  }
}
