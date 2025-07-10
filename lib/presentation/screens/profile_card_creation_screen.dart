import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/profile_card_widget.dart';
import '../widgets/glassmorphism_container.dart';
import '../../providers/profile_card_provider.dart';
import '../../data/models/profile_card.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

class ProfileCardCreationScreen extends ConsumerStatefulWidget {
  const ProfileCardCreationScreen({super.key});

  @override
  ConsumerState<ProfileCardCreationScreen> createState() => _ProfileCardCreationScreenState();
}

class _ProfileCardCreationScreenState extends ConsumerState<ProfileCardCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _companyController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _jobTitleController.dispose();
    _companyController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    final cardForm = ref.watch(cardFormProvider);
    final cardFormNotifier = ref.watch(cardFormProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Profile Card'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () => _saveCard(context, ref, _formKey),
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
            colors: [
              AppColors.white,
              AppColors.lightGrey,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.mediumSpacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardPreview(cardForm),
              const SizedBox(height: AppConstants.largeSpacing),
              _buildForm(
                context,
                _formKey,
                _fullNameController,
                _jobTitleController,
                _companyController,
                _emailController,
                _phoneController,
                _addressController,
                cardFormNotifier,
              ),
            ],
          ),
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
        Center(
          child: ProfileCardWidget(
            profileCard: profileCard,
          ),
        ),
      ],
    );
  }

  Widget _buildForm(
    BuildContext context,
    GlobalKey<FormState> formKey,
    TextEditingController fullNameController,
    TextEditingController jobTitleController,
    TextEditingController companyController,
    TextEditingController emailController,
    TextEditingController phoneController,
    TextEditingController addressController,
    CardFormNotifier cardFormNotifier,
  ) {
    return GlassmorphismContainer(
      padding: const EdgeInsets.all(AppConstants.mediumSpacing),
      child: Form(
        key: formKey,
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
            _buildStyleCustomization(context, cardFormNotifier),
            const SizedBox(height: AppConstants.largeSpacing),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _saveCard(context, ref, _formKey),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Card',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.yellow, width: 2),
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

  Future<void> _saveCard(
    BuildContext context,
    WidgetRef? ref,
    GlobalKey<FormState> formKey,
  ) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      if (ref != null) {
        final cardForm = ref.read(cardFormProvider);
        final profileCardNotifier = ref.read(profileCardProvider.notifier);
        
        await profileCardNotifier.addProfileCard(cardForm);
        
        if (context.mounted) {
          ref.read(cardFormProvider.notifier).reset();
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile card created successfully!'),
              backgroundColor: AppColors.yellow,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving card: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildStyleCustomization(BuildContext context, CardFormNotifier cardFormNotifier) {
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

  Widget _buildFontFamilySelector(CardStyle currentStyle, CardFormNotifier cardFormNotifier) {
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
            items: AppConstants.fontFamilies.map((font) {
              return DropdownMenuItem<String>(
                value: font,
                child: Text(
                  font,
                  style: TextStyle(fontFamily: font),
                ),
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

  Widget _buildFontWeightSelector(CardStyle currentStyle, CardFormNotifier cardFormNotifier) {
    const fontWeights = [
      FontWeight.w300,
      FontWeight.w400,
      FontWeight.w500,
      FontWeight.w600,
      FontWeight.w700,
    ];
    
    const fontWeightNames = [
      'Light',
      'Regular',
      'Medium',
      'Semi-Bold',
      'Bold',
    ];

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
            items: fontWeights.asMap().entries.map((entry) {
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

  Widget _buildTextColorSelector(CardStyle currentStyle, CardFormNotifier cardFormNotifier) {
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
                    color: isSelected ? AppColors.yellow : Colors.grey,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: isSelected
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

  Widget _buildBackgroundTypeSelector(CardStyle currentStyle, CardFormNotifier cardFormNotifier) {
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
                    color: isSelected ? AppColors.yellow : Colors.transparent,
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
                    color: isSelected ? AppColors.yellow : Colors.grey,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: isSelected
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

  Widget _buildGradientColorSelector(CardStyle currentStyle, CardFormNotifier cardFormNotifier) {
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
                    color: isSelected ? AppColors.yellow : Colors.grey,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: isSelected
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

  Widget _buildTemplateSelector(CardStyle currentStyle, CardFormNotifier cardFormNotifier) {
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
            items: AppConstants.cardTemplates.map((template) {
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