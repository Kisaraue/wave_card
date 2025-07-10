import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert';
import '../../data/models/profile_card.dart';
import '../../data/models/contact.dart';
import '../../providers/contact_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/toast_utils.dart';
import '../widgets/profile_card_widget.dart';
import '../widgets/glassmorphism_container.dart';

class QRScannerScreen extends ConsumerStatefulWidget {
  const QRScannerScreen({super.key});

  @override
  ConsumerState<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends ConsumerState<QRScannerScreen> {
  MobileScannerController controller = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool isScanning = true;
  bool isTorchOn = false;
  ProfileCard? scannedCard;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Initialize toast for this context
    ToastUtils.init(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              isTorchOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
            onPressed: _toggleTorch,
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          if (isScanning) _buildScanner(),
          if (scannedCard != null) _buildCardPreview(),
          if (isScanning) _buildOverlay(),
        ],
      ),
    );
  }

  Widget _buildScanner() {
    return MobileScanner(
      controller: controller,
      onDetect: _handleScanResult,
    );
  }

  Widget _buildOverlay() {
    final scanArea = MediaQuery.of(context).size.width * 0.8;
    
    return IgnorePointer(
      child: Container(
        child: Stack(
          children: [
            // Simple scan area indicator
            Center(
              child: Container(
                width: scanArea,
                height: scanArea,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.buttonColor,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    // Corner indicators
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: AppColors.buttonColor, width: 4),
                            left: BorderSide(color: AppColors.buttonColor, width: 4),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: AppColors.buttonColor, width: 4),
                            right: BorderSide(color: AppColors.buttonColor, width: 4),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: AppColors.buttonColor, width: 4),
                            left: BorderSide(color: AppColors.buttonColor, width: 4),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: AppColors.buttonColor, width: 4),
                            right: BorderSide(color: AppColors.buttonColor, width: 4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Instructions at the bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(AppConstants.largeSpacing),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.qr_code_scanner,
                        color: Colors.white,
                        size: 48,
                      ),
                      const SizedBox(height: AppConstants.mediumSpacing),
                      Text(
                        'Point your camera at a QR code',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.smallSpacing),
                      Text(
                        'Make sure the QR code is well-lit and within the frame',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
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

  Widget _buildCardPreview() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.largeSpacing),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GlassmorphismContainer(
                borderRadius: 20,
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.largeSpacing),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 64,
                      ),
                      const SizedBox(height: AppConstants.mediumSpacing),
                      Text(
                        'Card Received!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppConstants.mediumSpacing),
                      ProfileCardWidget(
                        profileCard: scannedCard!,
                      ),
                      const SizedBox(height: AppConstants.largeSpacing),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _saveCard,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.buttonColor,
                                foregroundColor: AppColors.black,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Save Card',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppConstants.mediumSpacing),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _scanAgain,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Scan Again'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleScanResult(BarcodeCapture capture) {
    if (!isScanning || !mounted) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    
    for (final barcode in barcodes) {
      final String? qrData = barcode.rawValue;
      if (qrData != null && qrData.isNotEmpty) {
        debugPrint('QR Code detected: $qrData');
        _processQRData(qrData);
        return; // Process only the first valid barcode
      }
    }
  }

  void _processQRData(String qrData) {
    try {
      debugPrint('Processing QR data: $qrData');
      final data = jsonDecode(qrData);
      
      if (data is! Map<String, dynamic>) {
        debugPrint('QR data is not a valid JSON object');
        _showError('Invalid QR code format.');
        return;
      }

      // Handle different formats
      Map<String, dynamic> cardData;
      
      // New compact format
      if (data['t'] == 'pc') {
        debugPrint('Processing new compact format');
        final compactData = data['d'] ?? data['c']; // Try both keys
        
        // Convert compact format back to full format
        cardData = {
          'id': compactData['i'],
          'fullName': compactData['n'],
          'jobTitle': compactData['j'],
          'company': compactData['c'],
          'email': compactData['e'],
          'phone': compactData['p'],
          'address': compactData['a'],
          'profileImageUrl': compactData['img'],
          'socialLinks': compactData['s'] ?? {},
          'customFields': compactData['cf'] ?? {},
          'cardStyle': _expandCardStyle(compactData['cs']),
          'createdAt': compactData['ca'] ?? DateTime.now().toIso8601String(),
          'updatedAt': compactData['ua'] ?? DateTime.now().toIso8601String(),
        };
        
        // Remove null values
        cardData.removeWhere((key, value) => value == null);
      }
      // Old format (backward compatibility)
      else if (data['type'] == 'profile_card') {
        debugPrint('Processing old format');
        cardData = data['card'];
      }
      else {
        debugPrint('QR code type is not profile_card: ${data['type'] ?? data['t']}');
        _showError('Invalid QR code. This is not a profile card.');
        return;
      }

      if (cardData == null) {
        debugPrint('No card data found in QR code');
        _showError('No card data found in QR code.');
        return;
      }

      debugPrint('Creating ProfileCard from data: $cardData');
      final profileCard = ProfileCard.fromJson(cardData);

      setState(() {
        isScanning = false;
        scannedCard = profileCard;
      });

      controller.stop();
      debugPrint('QR code processed successfully');
    } catch (e) {
      debugPrint('Error processing QR data: $e');
      _showError('Invalid QR code format: $e');
    }
  }

  void _showError(String message) {
    ToastUtils.showError(message, isDarkMode: false);
  }

  void _saveCard() async {
    if (scannedCard != null) {
      try {
        final contact = Contact(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          profileCard: scannedCard!,
          receivedAt: DateTime.now(),
        );

        await ref.read(contactProvider.notifier).addContact(contact);

        if (mounted) {
          Navigator.of(context).pop(contact);
        }
      } catch (e) {
        _showError('Failed to save card: $e');
      }
    }
  }

  void _scanAgain() {
    setState(() {
      isScanning = true;
      scannedCard = null;
    });
    controller.start();
  }

  void _toggleTorch() async {
    await controller.toggleTorch();
    setState(() {
      isTorchOn = !isTorchOn;
    });
  }

  Map<String, dynamic> _expandCardStyle(dynamic compactStyle) {
    if (compactStyle == null) {
      // Return default style if not provided
      return {
        'template': 'Classic',
        'backgroundColor': Colors.white.value,
        'textColor': Colors.black.value,
        'fontSize': 14.0,
        'fontFamily': 'Default',
        'borderRadius': 12.0,
      };
    }

    // If it's already a full CardStyle object, return as is
    if (compactStyle is Map<String, dynamic> && compactStyle.containsKey('template')) {
      return compactStyle;
    }

    // Expand minimal style to full style
    return {
      'template': compactStyle['template'] ?? 'Classic',
      'backgroundColor': compactStyle['backgroundColor'] ?? Colors.white.value,
      'textColor': compactStyle['textColor'] ?? Colors.black.value,
      'fontSize': compactStyle['fontSize'] ?? 14.0,
      'fontFamily': compactStyle['fontFamily'] ?? 'Default',
      'fontWeight': FontWeight.normal.index,
      'borderRadius': compactStyle['borderRadius'] ?? 12.0,
      'backgroundType': 'solid',
      'gradientColors': [Colors.white.value, Colors.grey.value],
      'hasGlassmorphism': false,
      'has3DEffect': false,
    };
  }
}