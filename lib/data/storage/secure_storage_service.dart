import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/profile_card.dart';
import '../models/contact.dart';
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

  // Theme and Settings
  Future<String?> getThemePreference() async {
    try {
      return await _secureStorage.read(key: AppConstants.themeKey);
    } catch (e) {
      throw StorageException('Failed to get theme preference: $e');
    }
  }

  Future<void> setThemePreference(String theme) async {
    try {
      await _secureStorage.write(key: AppConstants.themeKey, value: theme);
    } catch (e) {
      throw StorageException('Failed to set theme preference: $e');
    }
  }

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