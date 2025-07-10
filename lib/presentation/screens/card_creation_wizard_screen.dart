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
import '../../core/utils/toast_utils.dart';

class CardCreationWizardScreen extends ConsumerStatefulWidget {
  const CardCreationWizardScreen({super.key});

  @override
  ConsumerState<CardCreationWizardScreen> createState() => _CardCreationWizardScreenState();
}

class _CardCreationWizardScreenState extends ConsumerState<CardCreationWizardScreen> {
  int _currentStep = 0;
  final _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  
  final _fullNameController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _companyController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  
  final _facebookController = TextEditingController();
  final _twitterController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _instagramController = TextEditingController();
  final _websiteController = TextEditingController();
  
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _pageController.dispose();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Initialize toast for this context
    ToastUtils.init(context);
    
    final cardForm = ref.watch(cardFormProvider);
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Card - Step ${_currentStep + 1} of 4'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surface,
              colorScheme.surfaceContainerLowest,
            ],
          ),
        ),
        child: Column(
          children: [
            _buildStepIndicator(),
            _buildCardPreview(cardForm),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                children: [
                  _buildPersonalDetailsStep(),
                  _buildProfilePictureStep(),
                  _buildSocialMediaStep(),
                  _buildCustomizationStep(),
                ],
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppConstants.mediumSpacing),
      child: Row(
        children: List.generate(4, (index) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 4,
              decoration: BoxDecoration(
                color: index <= _currentStep ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCardPreview(ProfileCard profileCard) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.mediumSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Card Preview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppConstants.smallSpacing),
          Center(
            child: Transform.scale(
              scale: 0.8,
              child: ProfileCardWidget(
                profileCard: profileCard,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalDetailsStep() {
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.mediumSpacing),
      child: GlassmorphismContainer(
        padding: const EdgeInsets.all(AppConstants.mediumSpacing),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personal Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppConstants.smallSpacing),
              Text(
                'Please provide your basic information (Required)',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: AppConstants.largeSpacing),
              _buildTextField(
                controller: _fullNameController,
                label: 'Full Name *',
                icon: Icons.person,
                required: true,
                onChanged: (value) => _updateCardForm(),
              ),
              const SizedBox(height: AppConstants.mediumSpacing),
              _buildTextField(
                controller: _jobTitleController,
                label: 'Job Title *',
                icon: Icons.work,
                required: true,
                onChanged: (value) => _updateCardForm(),
              ),
              const SizedBox(height: AppConstants.mediumSpacing),
              _buildTextField(
                controller: _companyController,
                label: 'Company *',
                icon: Icons.business,
                required: true,
                onChanged: (value) => _updateCardForm(),
              ),
              const SizedBox(height: AppConstants.mediumSpacing),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) => _updateCardForm(),
              ),
              const SizedBox(height: AppConstants.mediumSpacing),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                onChanged: (value) => _updateCardForm(),
              ),
              const SizedBox(height: AppConstants.mediumSpacing),
              _buildTextField(
                controller: _addressController,
                label: 'Address',
                icon: Icons.location_on,
                maxLines: 2,
                onChanged: (value) => _updateCardForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePictureStep() {
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.mediumSpacing),
      child: GlassmorphismContainer(
        padding: const EdgeInsets.all(AppConstants.mediumSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile Picture',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppConstants.smallSpacing),
            Text(
              'Add a profile picture to personalize your card (Optional)',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: AppConstants.largeSpacing),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.onSurface.withOpacity(0.6), width: 2),
                      image: _profileImage != null
                          ? DecorationImage(
                              image: FileImage(_profileImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _profileImage == null
                        ? Icon(
                            Icons.person,
                            size: 60,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          )
                        : null,
                  ),
                  const SizedBox(height: AppConstants.largeSpacing),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Camera'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonColor,
                          foregroundColor: AppColors.black,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Gallery'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonColor,
                          foregroundColor: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                  if (_profileImage != null) ...[
                    const SizedBox(height: AppConstants.mediumSpacing),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _profileImage = null;
                        });
                        _updateCardForm();
                      },
                      child: Text(
                        'Remove Photo',
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialMediaStep() {
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.mediumSpacing),
      child: GlassmorphismContainer(
        padding: const EdgeInsets.all(AppConstants.mediumSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Social Media',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppConstants.smallSpacing),
            Text(
              'Add your social media links (Optional)',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: AppConstants.largeSpacing),
            _buildTextField(
              controller: _facebookController,
              label: 'Facebook',
              icon: Icons.facebook,
              onChanged: (value) => _updateCardForm(),
            ),
            const SizedBox(height: AppConstants.mediumSpacing),
            _buildTextField(
              controller: _twitterController,
              label: 'Twitter',
              icon: Icons.alternate_email,
              onChanged: (value) => _updateCardForm(),
            ),
            const SizedBox(height: AppConstants.mediumSpacing),
            _buildTextField(
              controller: _linkedinController,
              label: 'LinkedIn',
              icon: Icons.business_center,
              onChanged: (value) => _updateCardForm(),
            ),
            const SizedBox(height: AppConstants.mediumSpacing),
            _buildTextField(
              controller: _instagramController,
              label: 'Instagram',
              icon: Icons.photo_camera,
              onChanged: (value) => _updateCardForm(),
            ),
            const SizedBox(height: AppConstants.mediumSpacing),
            _buildTextField(
              controller: _websiteController,
              label: 'Website',
              icon: Icons.web,
              onChanged: (value) => _updateCardForm(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomizationStep() {
    final cardForm = ref.watch(cardFormProvider);
    final cardFormNotifier = ref.watch(cardFormProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.mediumSpacing),
      child: GlassmorphismContainer(
        padding: const EdgeInsets.all(AppConstants.mediumSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customization',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppConstants.smallSpacing),
            Text(
              'Customize your card appearance (Optional)',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: AppConstants.largeSpacing),
            _buildStyleCustomization(cardForm.cardStyle, cardFormNotifier),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppConstants.mediumSpacing),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: ElevatedButton(
                onPressed: _previousStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.onSurface.withOpacity(0.6),
                  foregroundColor: colorScheme.onPrimary,
                ),
                child: const Text('Previous'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: AppConstants.mediumSpacing),
          if (_currentStep < 3) ...[
            if (_currentStep == 0)
              Expanded(
                child: ElevatedButton(
                  onPressed: _canProceedFromStep0() ? _nextStep : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonColor,
                    foregroundColor: AppColors.black,
                  ),
                  child: const Text('Next'),
                ),
              )
            else
              Expanded(
                child: ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonColor,
                    foregroundColor: AppColors.black,
                  ),
                  child: const Text('Next'),
                ),
              ),
            if (_currentStep > 0)
              const SizedBox(width: AppConstants.mediumSpacing),
            if (_currentStep > 0)
              Expanded(
                child: TextButton(
                  onPressed: _nextStep,
                  child: const Text('Skip'),
                ),
              ),
          ] else
            Expanded(
              child: ElevatedButton(
                onPressed: _saveCard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor,
                  foregroundColor: AppColors.black,
                ),
                child: const Text('Create Card'),
              ),
            ),
        ],
      ),
    );
  }

  bool _canProceedFromStep0() {
    return _fullNameController.text.isNotEmpty &&
           _jobTitleController.text.isNotEmpty &&
           _companyController.text.isNotEmpty;
  }

  void _nextStep() {
    if (_currentStep == 0 && !_canProceedFromStep0()) {
      ToastUtils.showError('Please fill in all required fields', isDarkMode: false);
      return;
    }
    
    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      // Try to pick image directly first, as image_picker handles permissions internally
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
        // Show user-friendly error message
        String errorMessage = 'Unable to access ${source == ImageSource.camera ? 'camera' : 'gallery'}';
        
        if (e.toString().contains('Permission')) {
          errorMessage = '${source == ImageSource.camera ? 'Camera' : 'Gallery'} permission denied. Please enable it in device settings.';
        }
        
        ToastUtils.showError(errorMessage, isDarkMode: false);
      }
    }
  }

  void _updateCardForm() {
    final cardFormNotifier = ref.read(cardFormProvider.notifier);
    
    cardFormNotifier.updateMultipleFields(
      fullName: _fullNameController.text,
      jobTitle: _jobTitleController.text,
      company: _companyController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      socialLinks: {
        if (_facebookController.text.isNotEmpty) 'facebook': _facebookController.text,
        if (_twitterController.text.isNotEmpty) 'twitter': _twitterController.text,
        if (_linkedinController.text.isNotEmpty) 'linkedin': _linkedinController.text,
        if (_instagramController.text.isNotEmpty) 'instagram': _instagramController.text,
        if (_websiteController.text.isNotEmpty) 'website': _websiteController.text,
      },
      profileImageUrl: _profileImage?.path,
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
    final colorScheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: colorScheme.onSurface.withOpacity(0.6)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      validator: required
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

  Widget _buildStyleCustomization(CardStyle currentStyle, CardFormNotifier cardFormNotifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFontFamilySelector(currentStyle, cardFormNotifier),
        const SizedBox(height: AppConstants.mediumSpacing),
        _buildFontSizeSlider(currentStyle, cardFormNotifier),
        const SizedBox(height: AppConstants.mediumSpacing),
        _buildTextColorSelector(currentStyle, cardFormNotifier),
        const SizedBox(height: AppConstants.mediumSpacing),
        _buildBackgroundTypeSelector(currentStyle, cardFormNotifier),
        const SizedBox(height: AppConstants.mediumSpacing),
        if (currentStyle.backgroundType == 'solid')
          _buildBackgroundColorSelector(currentStyle, cardFormNotifier)
        else if (currentStyle.backgroundType == 'gradient')
          _buildGradientColorSelector(currentStyle, cardFormNotifier),
      ],
    );
  }

  Widget _buildFontFamilySelector(CardStyle currentStyle, CardFormNotifier cardFormNotifier) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Font Family',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppConstants.smallSpacing),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.onSurface.withOpacity(0.6)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            value: currentStyle.fontFamily,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: AppConstants.fontFamilies.map((font) {
              return DropdownMenuItem<String>(
                value: font,
                child: Text(font),
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

  Widget _buildFontSizeSlider(CardStyle currentStyle, CardFormNotifier cardFormNotifier) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Font Size: ${currentStyle.fontSize.toInt()}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppConstants.smallSpacing),
        Slider(
          value: currentStyle.fontSize,
          min: 10.0,
          max: 24.0,
          divisions: 14,
          activeColor: colorScheme.primary,
          onChanged: (value) {
            final updatedStyle = currentStyle.copyWith(fontSize: value);
            cardFormNotifier.updateCardStyle(updatedStyle);
          },
        ),
      ],
    );
  }

  Widget _buildTextColorSelector(CardStyle currentStyle, CardFormNotifier cardFormNotifier) {
    final colorScheme = Theme.of(context).colorScheme;
    final colors = [
      colorScheme.onSurface,
      colorScheme.onPrimary,
      colorScheme.onSurface.withOpacity(0.8),
      colorScheme.primary,
      Colors.blue,
      colorScheme.error,
      colorScheme.tertiary,
      Colors.purple,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Text Color',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppConstants.smallSpacing),
        Wrap(
          spacing: 8.0,
          children: colors.map((color) {
            final isSelected = currentStyle.textColor == color;
            return GestureDetector(
              onTap: () {
                final updatedStyle = currentStyle.copyWith(textColor: color);
                cardFormNotifier.updateCardStyle(updatedStyle);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.6),
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        color: colorScheme.onPrimary,
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

  Widget _buildBackgroundTypeSelector(CardStyle currentStyle, CardFormNotifier cardFormNotifier) {
    final colorScheme = Theme.of(context).colorScheme;
    const backgroundTypes = ['solid', 'gradient'];
    const backgroundTypeNames = ['Solid', 'Gradient'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Background Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppConstants.smallSpacing),
        Row(
          children: backgroundTypes.asMap().entries.map((entry) {
            final index = entry.key;
            final type = entry.value;
            final isSelected = currentStyle.backgroundType == type;
            
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  final updatedStyle = currentStyle.copyWith(backgroundType: type);
                  cardFormNotifier.updateCardStyle(updatedStyle);
                },
                child: Container(
                  margin: EdgeInsets.only(right: index == 0 ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? colorScheme.primary : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.6),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    backgroundTypeNames[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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

  Widget _buildBackgroundColorSelector(CardStyle currentStyle, CardFormNotifier cardFormNotifier) {
    final colorScheme = Theme.of(context).colorScheme;
    final colors = [
      colorScheme.surface,
      colorScheme.surfaceContainerLowest,
      Colors.blue[50]!,
      colorScheme.tertiary.withOpacity(0.1),
      colorScheme.primary.withOpacity(0.1),
      colorScheme.error.withOpacity(0.1),
      Colors.purple[50]!,
      Colors.orange[50]!,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Background Color',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppConstants.smallSpacing),
        Wrap(
          spacing: 8.0,
          children: colors.map((color) {
            final isSelected = currentStyle.backgroundColor == color;
            return GestureDetector(
              onTap: () {
                final updatedStyle = currentStyle.copyWith(backgroundColor: color);
                cardFormNotifier.updateCardStyle(updatedStyle);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.6),
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        color: colorScheme.primary,
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

  Widget _buildGradientColorSelector(CardStyle currentStyle, CardFormNotifier cardFormNotifier) {
    final colorScheme = Theme.of(context).colorScheme;
    final gradientPresets = [
      [colorScheme.surface, colorScheme.surfaceContainerLowest],
      [Colors.blue[50]!, Colors.blue[100]!],
      [colorScheme.tertiary.withOpacity(0.1), colorScheme.tertiary.withOpacity(0.2)],
      [colorScheme.primary.withOpacity(0.1), colorScheme.primary.withOpacity(0.2)],
      [colorScheme.error.withOpacity(0.1), colorScheme.error.withOpacity(0.2)],
      [Colors.purple[50]!, Colors.purple[100]!],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gradient Colors',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppConstants.smallSpacing),
        Wrap(
          spacing: 8.0,
          children: gradientPresets.map((gradient) {
            final isSelected = currentStyle.gradientColors.length == 2 &&
                currentStyle.gradientColors[0] == gradient[0] &&
                currentStyle.gradientColors[1] == gradient[1];
            
            return GestureDetector(
              onTap: () {
                final updatedStyle = currentStyle.copyWith(gradientColors: gradient);
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
                    color: isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.6),
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        color: colorScheme.primary,
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

  Future<void> _saveCard() async {
    try {
      final cardForm = ref.read(cardFormProvider);
      final profileCardNotifier = ref.read(profileCardProvider.notifier);
      
      await profileCardNotifier.addProfileCard(cardForm);
      
      if (mounted) {
        ref.read(cardFormProvider.notifier).reset();
        Navigator.pop(context);
        ToastUtils.showSuccess('Profile card created successfully!', isDarkMode: false);
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showError('Error saving card: $e', isDarkMode: false);
      }
    }
  }
}