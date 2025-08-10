import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/profile_card.dart';
import '../models/contact.dart';
import '../services/auth_service.dart';
import '../../core/constants/app_constants.dart';

class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      accountName: AppConstants.appName,
    ),
  );

  // Profile Cards Management
  Future<List<ProfileCard>> getProfileCards() async {
    try {
      final jsonString = await _secureStorage.read(key: AppConstants.userProfilesKey);
      if (jsonString == null) return [];
      
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => ProfileCard.fromJson(json)).toList();
    } catch (e) {
      throw StorageException('Failed to load profile cards: $e');
    }
  }

  Future<void> saveProfileCards(List<ProfileCard> cards) async {
    try {
      final jsonString = json.encode(cards.map((card) => card.toJson()).toList());
      await _secureStorage.write(key: AppConstants.userProfilesKey, value: jsonString);
    } catch (e) {
      throw StorageException('Failed to save profile cards: $e');
    }
  }

  Future<void> addProfileCard(ProfileCard card) async {
    try {
      final cards = await getProfileCards();
      cards.add(card);
      await saveProfileCards(cards);
    } catch (e) {
      throw StorageException('Failed to add profile card: $e');
    }
  }

  Future<void> updateProfileCard(ProfileCard updatedCard) async {
    try {
      final cards = await getProfileCards();
      final index = cards.indexWhere((card) => card.id == updatedCard.id);
      if (index != -1) {
        cards[index] = updatedCard;
        await saveProfileCards(cards);
      } else {
        throw StorageException('Profile card not found');
      }
    } catch (e) {
      throw StorageException('Failed to update profile card: $e');
    }
  }

  Future<void> deleteProfileCard(String cardId) async {
    try {
      final cards = await getProfileCards();
      cards.removeWhere((card) => card.id == cardId);
      await saveProfileCards(cards);
    } catch (e) {
      throw StorageException('Failed to delete profile card: $e');
    }
  }

  Future<void> clearProfileCards() async {
    try {
      await saveProfileCards([]);
    } catch (e) {
      throw StorageException('Failed to clear profile cards: $e');
    }
  }

  // Contacts Management
  Future<List<Contact>> getContacts() async {
    try {
      final jsonString = await _secureStorage.read(key: AppConstants.contactsKey);
      if (jsonString == null) return [];
      
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => Contact.fromJson(json)).toList();
    } catch (e) {
      throw StorageException('Failed to load contacts: $e');
    }
  }

  Future<void> saveContacts(List<Contact> contacts) async {
    try {
      final jsonString = json.encode(contacts.map((contact) => contact.toJson()).toList());
      await _secureStorage.write(key: AppConstants.contactsKey, value: jsonString);
    } catch (e) {
      throw StorageException('Failed to save contacts: $e');
    }
  }

  Future<void> addContact(Contact contact) async {
    try {
      final contacts = await getContacts();
      contacts.add(contact);
      await saveContacts(contacts);
    } catch (e) {
      throw StorageException('Failed to add contact: $e');
    }
  }

  Future<void> updateContact(Contact updatedContact) async {
    try {
      final contacts = await getContacts();
      final index = contacts.indexWhere((contact) => contact.id == updatedContact.id);
      if (index != -1) {
        contacts[index] = updatedContact;
        await saveContacts(contacts);
      } else {
        throw StorageException('Contact not found');
      }
    } catch (e) {
      throw StorageException('Failed to update contact: $e');
    }
  }

  Future<void> deleteContact(String contactId) async {
    try {
      final contacts = await getContacts();
      contacts.removeWhere((contact) => contact.id == contactId);
      await saveContacts(contacts);
    } catch (e) {
      throw StorageException('Failed to delete contact: $e');
    }
  }

  // Backup Settings
  Future<bool> getBackupCardsEnabled() async {
    try {
      // First try to get from Firebase if user is authenticated
      final firebaseEnabled = await getBackupEnabledFromFirebase();
      if (firebaseEnabled != null) {
        return firebaseEnabled;
      }
      
      // Fallback to local storage
      final value = await _secureStorage.read(key: 'backup_cards_enabled');
      return value == 'true';
    } catch (e) {
      throw StorageException('Failed to get backup setting: $e');
    }
  }

  Future<void> setBackupCardsEnabled(bool enabled, {bool updateFirebase = true}) async {
    try {
      // Save to Firebase if user is authenticated and updateFirebase is true
      if (updateFirebase) {
        await saveBackupEnabledToFirebase(enabled);
      }
      
      // Also save locally as backup
      await _secureStorage.write(key: 'backup_cards_enabled', value: enabled.toString());
    } catch (e) {
      throw StorageException('Failed to set backup setting: $e');
    }
  }

  Future<bool?> getBackupEnabledFromFirebase() async {
    try {
      final authService = AuthService();
      final currentUser = authService.currentUser;
      
      if (currentUser == null || currentUser.isAnonymous) {
        return null;
      }
      
      final preferences = await authService.getUserPreferences(currentUser.uid);
      return preferences['backupCardsEnabled'] as bool?;
    } catch (e) {
      print('Error getting backup preference from Firebase: $e');
      return null;
    }
  }

  Future<void> saveBackupEnabledToFirebase(bool enabled) async {
    try {
      final authService = AuthService();
      final currentUser = authService.currentUser;
      
      if (currentUser == null || currentUser.isAnonymous) {
        print('User not authenticated or anonymous, skipping Firebase backup preference save');
        return;
      }
      
      final currentPreferences = await authService.getUserPreferences(currentUser.uid);
      currentPreferences['backupCardsEnabled'] = enabled;
      
      final result = await authService.updateUserPreferences(
        uid: currentUser.uid,
        preferences: currentPreferences,
      );
      
      if (!result.isSuccess) {
        print('Failed to save backup preference to Firebase: ${result.errorMessage}');
      }
    } catch (e) {
      print('Error saving backup preference to Firebase: $e');
    }
  }

  // Initialize backup preference from Firebase for already logged-in users
  Future<void> initializeBackupPreferenceFromFirebase() async {
    try {
      final firebaseEnabled = await getBackupEnabledFromFirebase();
      
      if (firebaseEnabled != null) {
        // Update local storage with Firebase value (don't update Firebase again)
        await setBackupCardsEnabled(firebaseEnabled, updateFirebase: false);
      }
    } catch (e) {
      print('Error initializing backup preference from Firebase: $e');
    }
  }

  // Security Settings
  Future<Map<String, dynamic>?> getSecuritySettings() async {
    try {
      final jsonString = await _secureStorage.read(key: AppConstants.securityKey);
      if (jsonString == null) return null;
      return json.decode(jsonString);
    } catch (e) {
      throw StorageException('Failed to get security settings: $e');
    }
  }

  Future<void> setSecuritySettings(Map<String, dynamic> settings) async {
    try {
      final jsonString = json.encode(settings);
      await _secureStorage.write(key: AppConstants.securityKey, value: jsonString);
    } catch (e) {
      throw StorageException('Failed to set security settings: $e');
    }
  }

  // Utility methods
  Future<void> clearAllData() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      throw StorageException('Failed to clear all data: $e');
    }
  }

  Future<bool> containsKey(String key) async {
    try {
      return await _secureStorage.containsKey(key: key);
    } catch (e) {
      throw StorageException('Failed to check key existence: $e');
    }
  }

  Future<Map<String, String>> getAllData() async {
    try {
      return await _secureStorage.readAll();
    } catch (e) {
      throw StorageException('Failed to read all data: $e');
    }
  }
}

class StorageException implements Exception {
  final String message;
  
  StorageException(this.message);
  
  @override
  String toString() => 'StorageException: $message';
}