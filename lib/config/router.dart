import 'package:flutter/material.dart';
import '../presentation/screens/splash_screen.dart';
import '../presentation/screens/login_screen.dart';
import '../presentation/screens/signup_screen.dart';
import '../presentation/screens/home_screen.dart';
import '../presentation/screens/profile_card_creation_screen.dart';
import '../presentation/screens/card_creation_wizard_screen.dart';
import '../presentation/screens/profile_card_edit_screen.dart';
import '../presentation/screens/contacts_screen.dart';
import '../presentation/screens/contact_detail_screen.dart';
import '../presentation/screens/settings_screen.dart';
import '../presentation/screens/qr_share_screen.dart';
import '../presentation/screens/qr_scanner_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String signUp = '/signup';
  static const String home = '/home';
  static const String createCard = '/create-card';
  static const String createCardWizard = '/create-card-wizard';
  static const String editCard = '/edit-card';
  static const String contacts = '/contacts';
  static const String contactDetail = '/contact-detail';
  static const String settings = '/settings';
  static const String qrShare = '/qr-share';
  static const String qrScanner = '/qr-scanner';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/signup':
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/create-card':
        return MaterialPageRoute(builder: (_) => const ProfileCardCreationScreen());
      case '/create-card-wizard':
        return MaterialPageRoute(builder: (_) => const CardCreationWizardScreen());
      case '/edit-card':
        final cardId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => ProfileCardEditScreen(cardId: cardId),
        );
      case '/contacts':
        return MaterialPageRoute(builder: (_) => const ContactsScreen());
      case '/contact-detail':
        final contactId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => ContactDetailScreen(contactId: contactId),
        );
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case '/qr-share':
        final cardId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => QRShareScreen(selectedCardId: cardId),
        );
      case '/qr-scanner':
        return MaterialPageRoute(builder: (_) => const QRScannerScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Page not found'),
            ),
          ),
        );
    }
  }
}