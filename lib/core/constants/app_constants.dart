class AppConstants {
  static const String appName = 'CardWave';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String userProfilesKey = 'user_profiles';
  static const String contactsKey = 'contacts';
  static const String securityKey = 'security_settings';
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Card Dimensions
  static const double cardWidth = 340.0;
  static const double cardHeight = 200.0;
  static const double cardBorderRadius = 20.0;
  
  // Spacing
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 16.0;
  static const double largeSpacing = 24.0;
  static const double extraLargeSpacing = 32.0;
  
  // Social Media Platforms
  static const List<String> socialPlatforms = [
    'LinkedIn',
    'Twitter',
    'Instagram',
    'GitHub',
    'Facebook',
    'YouTube',
    'TikTok',
    'Website',
  ];
  
  // Profile Card Templates
  static const List<String> cardTemplates = [
    'Classic',
    'Modern',
    'Minimalist',
    'Creative',
    'Professional',
    'Vibrant',
  ];
  
  // Font Families
  static const List<String> fontFamilies = [
    'Inter',
    'Poppins',
    'Roboto',
    'Montserrat',
    'Open Sans',
    'Lato',
  ];
  
  // Maximum limits
  static const int maxProfileCards = 5;
  static const int maxContacts = 100;
  static const int maxCustomFields = 10;
  static const int maxSocialLinks = 8;
}