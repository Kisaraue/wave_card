import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import 'dart:io';
import '../../data/models/profile_card.dart';
import '../../providers/profile_card_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../widgets/glassmorphism_container.dart';
import '../widgets/profile_card_widget.dart';

class QRShareScreen extends ConsumerStatefulWidget {
  final String? selectedCardId;

  const QRShareScreen({
    super.key,
    this.selectedCardId,
  });

  @override
  ConsumerState<QRShareScreen> createState() => _QRShareScreenState();
}

class _QRShareScreenState extends ConsumerState<QRShareScreen> {
  ProfileCard? selectedCard;
  String? qrData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSelectedCard();
    });
  }

  void _initializeSelectedCard() {
    final cardsAsync = ref.read(profileCardProvider);
    cardsAsync.whenData((cards) {
      if (widget.selectedCardId != null) {
        final card = cards.firstWhere(
          (c) => c.id == widget.selectedCardId,
          orElse: () => cards.isNotEmpty ? cards.first : throw Exception('No cards available'),
        );
        _selectCard(card);
      } else if (cards.isNotEmpty) {
        _selectCard(cards.first);
      }
    });
  }

  void _selectCard(ProfileCard card) {
    setState(() {
      selectedCard = card;
      qrData = _generateQRData(card);
    });
  }

  String _generateQRData(ProfileCard card) {
    // Create a compact version with minimal key names to reduce size
    final compactCard = {
      'i': card.id,
      'n': card.fullName,
      'j': card.jobTitle,
      'c': card.company,
      'e': card.email,
      'p': card.phone,
      'a': card.address,
      'img': _getImageDataForSharing(card.profileImageUrl),
      's': card.socialLinks,
      'cf': card.customFields,
      'cs': card.cardStyle.toJson(),
      'ca': card.createdAt.toIso8601String(),
      'ua': card.updatedAt.toIso8601String(),
    };

    // Remove null values to reduce size
    compactCard.removeWhere((key, value) => value == null);

    final data = {
      'v': '1.0',
      't': 'pc',
      'd': compactCard,
    };
    
    final jsonString = jsonEncode(data);
    debugPrint('QR Data length: ${jsonString.length}');
    
    // If still too large, try to reduce further
    if (jsonString.length > 2000) {
      debugPrint('QR data too large, creating minimal version');
      final minimalCard = {
        'i': card.id,
        'n': card.fullName,
        'j': card.jobTitle,
        'c': card.company,
        'e': card.email,
        'p': card.phone,
        's': card.socialLinks,
        // Exclude image from minimal version to reduce size
        // Only essential card style info
        'cs': {
          'template': card.cardStyle.template,
          'backgroundColor': card.cardStyle.backgroundColor.value,
          'textColor': card.cardStyle.textColor.value,
          'fontSize': card.cardStyle.fontSize,
          'fontFamily': card.cardStyle.fontFamily,
          'borderRadius': card.cardStyle.borderRadius,
        }
      };
      minimalCard.removeWhere((key, value) => value == null);
      
      final minimalData = {
        'v': '1.0',
        't': 'pc',
        'd': minimalCard,
      };
      
      final minimalJsonString = jsonEncode(minimalData);
      debugPrint('Minimal QR Data length: ${minimalJsonString.length}');
      return minimalJsonString;
    }
    
    return jsonString;
  }

  String? _getImageDataForSharing(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return null;
    }

    // If it's already a network URL, keep it as is
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }

    // If it's a local file, convert to base64
    try {
      final file = File(imageUrl);
      if (file.existsSync()) {
        final bytes = file.readAsBytesSync();
        // Limit image size to prevent QR code from becoming too large
        // We'll compress if the file is larger than 50KB
        if (bytes.length > 50 * 1024) {
          debugPrint('Image too large (${bytes.length} bytes), excluding from QR code');
          return null;
        }
        
        final base64String = base64Encode(bytes);
        debugPrint('Image converted to base64, size: ${base64String.length} characters');
        return 'data:image/jpeg;base64,$base64String';
      }
    } catch (e) {
      debugPrint('Error converting image to base64: $e');
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final cardsAsync = ref.watch(profileCardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Profile Card'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.black,
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.mediumSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select a card to share',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppConstants.smallSpacing),
                Text(
                  'Others can scan this QR code to receive your profile card',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.grey,
                  ),
                ),
                const SizedBox(height: AppConstants.largeSpacing),
                _buildCardSelector(cardsAsync),
                const SizedBox(height: AppConstants.largeSpacing),
                if (selectedCard != null && qrData != null) _buildQRCode(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardSelector(AsyncValue<List<ProfileCard>> cardsAsync) {
    return cardsAsync.when(
      data: (cards) {
        if (cards.isEmpty) {
          return Center(
            child: Column(
              children: [
                const Icon(
                  Icons.credit_card_outlined,
                  size: 64,
                  color: AppColors.grey,
                ),
                const SizedBox(height: AppConstants.mediumSpacing),
                Text(
                  'No cards available',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.grey,
                  ),
                ),
                const SizedBox(height: AppConstants.smallSpacing),
                Text(
                  'Create a profile card first to share it',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              final isSelected = selectedCard?.id == card.id;

              return Padding(
                padding: EdgeInsets.only(
                  right: index < cards.length - 1 ? AppConstants.mediumSpacing : 0,
                ),
                child: GestureDetector(
                  onTap: () => _selectCard(card),
                  child: Container(
                    width: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.yellow : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: Transform.scale(
                      scale: 0.6,
                      child: ProfileCardWidget(
                        profileCard: card,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text(
          'Error loading cards: $error',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  Widget _buildQRCode() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GlassmorphismContainer(
              borderRadius: 20,
              child: Container(
                padding: const EdgeInsets.all(AppConstants.largeSpacing),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppConstants.mediumSpacing),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: qrData!,
                        version: QrVersions.auto,
                        size: 280.0,
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.black,
                        errorCorrectionLevel: QrErrorCorrectLevel.L, // Lower error correction for more data
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: AppColors.black,
                        ),
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.mediumSpacing),
                    Text(
                      selectedCard!.fullName,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.smallSpacing),
                    Text(
                      'Scan this QR code to receive this profile card',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}