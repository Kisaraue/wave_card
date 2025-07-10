import 'package:flutter/material.dart';
import '../presentation/screens/home_screen.dart';
import '../presentation/screens/profile_card_creation_screen.dart';
import '../presentation/screens/card_creation_wizard_screen.dart';
import '../presentation/screens/profile_card_edit_screen.dart';
import '../presentation/screens/contacts_screen.dart';
import '../presentation/screens/contact_detail_screen.dart';
import '../presentation/screens/settings_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String createCard = '/create-card';
  static const String createCardWizard = '/create-card-wizard';
  static const String editCard = '/edit-card';
  static const String contacts = '/contacts';
  static const String contactDetail = '/contact-detail';
  static const String settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
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