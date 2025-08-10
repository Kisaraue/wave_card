import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/contact.dart';
import '../data/models/profile_card.dart';
import '../data/storage/secure_storage_service.dart';
import '../data/services/firebase_profile_service.dart';

final contactProvider = StateNotifierProvider<ContactNotifier, AsyncValue<List<Contact>>>((ref) {
  return ContactNotifier();
});

class ContactNotifier extends StateNotifier<AsyncValue<List<Contact>>> {
  ContactNotifier() : super(const AsyncValue.loading()) {
    loadContacts();
  }

  final SecureStorageService _storageService = SecureStorageService();

  Future<void> loadContacts() async {
    try {
      state = const AsyncValue.loading();
      
      // Load contacts from Firebase first
      List<Contact> allContacts = [];
      try {
        final firebaseCardsWithMetadata = await FirebaseProfileService.getReceivedCardsWithMetadata();
        allContacts = firebaseCardsWithMetadata.map((data) => Contact(
          id: data['profileCard'].id,
          profileCard: data['profileCard'] as ProfileCard,
          receivedAt: data['receivedAt'] as DateTime,
        )).toList();
      } catch (firebaseError) {
        print('Failed to load from Firebase: $firebaseError');
        // If Firebase fails, fall back to local storage only
      }
      
      // Load from local storage and merge
      final localContacts = await _storageService.getContacts();
      
      // Create a map to avoid duplicates (Firebase takes precedence)
      final Map<String, Contact> contactMap = {};
      
      // Add local contacts first
      for (final contact in localContacts) {
        contactMap[contact.profileCard.id] = contact;
      }
      
      // Add/overwrite with Firebase contacts (they take precedence)
      for (final contact in allContacts) {
        contactMap[contact.profileCard.id] = contact;
      }
      
      final mergedContacts = contactMap.values.toList();
      mergedContacts.sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
      
      state = AsyncValue.data(mergedContacts);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addContact(Contact contact) async {
    try {
      // Save to local storage first
      await _storageService.addContact(contact);
      
      // Save to Firebase
      try {
        await FirebaseProfileService.saveReceivedCard(contact.profileCard);
      } catch (firebaseError) {
        print('Failed to save to Firebase: $firebaseError');
        // Continue even if Firebase fails - local storage succeeded
      }
      
      await loadContacts();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateContact(Contact updatedContact) async {
    try {
      await _storageService.updateContact(updatedContact);
      await loadContacts();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteContact(String contactId) async {
    try {
      // Delete from local storage
      await _storageService.deleteContact(contactId);
      
      // Delete from Firebase
      try {
        // Need to find the profile card ID from the contact
        final contacts = await _storageService.getContacts();
        final contact = contacts.firstWhere((c) => c.id == contactId);
        await FirebaseProfileService.deleteReceivedCard(contact.profileCard.id);
      } catch (firebaseError) {
        print('Failed to delete from Firebase: $firebaseError');
        // Continue even if Firebase fails - local storage succeeded
      }
      
      await loadContacts();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> toggleFavorite(String contactId) async {
    try {
      final contacts = await _storageService.getContacts();
      final contact = contacts.firstWhere((c) => c.id == contactId);
      final updatedContact = contact.copyWith(isFavorite: !contact.isFavorite);
      await updateContact(updatedContact);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addTagToContact(String contactId, String tag) async {
    try {
      final contacts = await _storageService.getContacts();
      final contact = contacts.firstWhere((c) => c.id == contactId);
      final updatedTags = List<String>.from(contact.tags);
      if (!updatedTags.contains(tag)) {
        updatedTags.add(tag);
        final updatedContact = contact.copyWith(tags: updatedTags);
        await updateContact(updatedContact);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> removeTagFromContact(String contactId, String tag) async {
    try {
      final contacts = await _storageService.getContacts();
      final contact = contacts.firstWhere((c) => c.id == contactId);
      final updatedTags = List<String>.from(contact.tags);
      updatedTags.remove(tag);
      final updatedContact = contact.copyWith(tags: updatedTags);
      await updateContact(updatedContact);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateContactNotes(String contactId, String notes) async {
    try {
      final contacts = await _storageService.getContacts();
      final contact = contacts.firstWhere((c) => c.id == contactId);
      final updatedContact = contact.copyWith(notes: notes);
      await updateContact(updatedContact);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Provider for contact filtering
final contactFilterProvider = StateProvider<ContactFilter>((ref) {
  return ContactFilter();
});

// Provider for filtered contacts
final filteredContactsProvider = Provider<List<Contact>>((ref) {
  final contactsAsync = ref.watch(contactProvider);
  final filter = ref.watch(contactFilterProvider);
  
  return contactsAsync.maybeWhen(
    data: (contacts) {
      var filteredContacts = contacts.where((contact) => filter.matches(contact)).toList();
      
      // Apply sorting
      filteredContacts.sort((a, b) {
        int comparison = 0;
        
        switch (filter.sortBy) {
          case ContactSortBy.receivedAt:
            comparison = a.receivedAt.compareTo(b.receivedAt);
            break;
          case ContactSortBy.name:
            comparison = a.profileCard.fullName.compareTo(b.profileCard.fullName);
            break;
          case ContactSortBy.company:
            comparison = a.profileCard.company.compareTo(b.profileCard.company);
            break;
          case ContactSortBy.favorite:
            comparison = a.isFavorite == b.isFavorite ? 0 : (a.isFavorite ? -1 : 1);
            break;
        }
        
        return filter.isAscending ? comparison : -comparison;
      });
      
      return filteredContacts;
    },
    orElse: () => [],
  );
});

// Provider for favorite contacts
final favoriteContactsProvider = Provider<List<Contact>>((ref) {
  final contactsAsync = ref.watch(contactProvider);
  
  return contactsAsync.maybeWhen(
    data: (contacts) => contacts.where((contact) => contact.isFavorite).toList(),
    orElse: () => [],
  );
});

// Provider for contact count
final contactCountProvider = Provider<int>((ref) {
  final contactsAsync = ref.watch(contactProvider);
  return contactsAsync.maybeWhen(
    data: (contacts) => contacts.length,
    orElse: () => 0,
  );
});

// Provider for all unique tags
final allTagsProvider = Provider<List<String>>((ref) {
  final contactsAsync = ref.watch(contactProvider);
  
  return contactsAsync.maybeWhen(
    data: (contacts) {
      final allTags = <String>{};
      for (final contact in contacts) {
        allTags.addAll(contact.tags);
      }
      final tagsList = allTags.toList();
      tagsList.sort();
      return tagsList;
    },
    orElse: () => [],
  );
});

// Provider for getting a specific contact by ID
final contactByIdProvider = Provider.family<Contact?, String>((ref, contactId) {
  final contactsAsync = ref.watch(contactProvider);
  return contactsAsync.maybeWhen(
    data: (contacts) => contacts.firstWhere(
      (contact) => contact.id == contactId,
      orElse: () => Contact(
        profileCard: ProfileCard(
          fullName: '',
          jobTitle: '',
          company: '',
        ),
      ),
    ),
    orElse: () => null,
  );
});

// Provider for search functionality
final contactSearchProvider = StateProvider<String>((ref) => '');

// Provider for searched contacts
final searchedContactsProvider = Provider<List<Contact>>((ref) {
  final searchQuery = ref.watch(contactSearchProvider);
  final contacts = ref.watch(filteredContactsProvider);
  
  if (searchQuery.isEmpty) {
    return contacts;
  }
  
  final query = searchQuery.toLowerCase();
  return contacts.where((contact) {
    final card = contact.profileCard;
    return card.fullName.toLowerCase().contains(query) ||
           card.jobTitle.toLowerCase().contains(query) ||
           card.company.toLowerCase().contains(query) ||
           (card.email?.toLowerCase().contains(query) ?? false) ||
           contact.tags.any((tag) => tag.toLowerCase().contains(query));
  }).toList();
});