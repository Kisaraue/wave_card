import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/profile_card.dart';

class FirebaseProfileService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _profileCardsCollection = 'profile_cards';
  static const String _receivedCardsCollection = 'received_cards';

  static String? get currentUserId => _auth.currentUser?.uid;

  static Future<void> saveUserProfileCard(ProfileCard profileCard) async {
    try {
      print('FirebaseProfileService: Starting to save user profile card');
      print('FirebaseProfileService: Current user ID: $currentUserId');
      
      final userId = currentUserId;
      if (userId == null) {
        print('FirebaseProfileService: No user ID, signing in anonymously');
        await _signInAnonymously();
        print('FirebaseProfileService: Anonymous sign-in completed. New user ID: $currentUserId');
      }

      if (currentUserId == null) {
        throw Exception('Failed to get user ID after authentication');
      }

      print('FirebaseProfileService: Creating collection reference');
      final userCollection = _firestore
          .collection(_profileCardsCollection)
          .doc(currentUserId)
          .collection('cards');

      print('FirebaseProfileService: Collection path: ${_profileCardsCollection}/$currentUserId/cards');
      print('FirebaseProfileService: Document ID: ${profileCard.id}');

      final cardData = {
        ...profileCard.toJson(),
        'savedAt': FieldValue.serverTimestamp(),
        'userId': currentUserId,
      };

      print('FirebaseProfileService: Card data to save: ${cardData.keys.toList()}');

      await userCollection.doc(profileCard.id).set(cardData);
      print('FirebaseProfileService: Successfully saved card to Firebase');
    } catch (e) {
      print('FirebaseProfileService: Error saving card: $e');
      throw Exception('Failed to save profile card to Firebase: $e');
    }
  }

  static Future<void> saveReceivedCard(ProfileCard profileCard) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        await _signInAnonymously();
      }

      final receivedCollection = _firestore
          .collection(_receivedCardsCollection)
          .doc(currentUserId)
          .collection('cards');

      await receivedCollection.doc(profileCard.id).set({
        ...profileCard.toJson(),
        'receivedAt': FieldValue.serverTimestamp(),
        'userId': currentUserId,
      });
    } catch (e) {
      throw Exception('Failed to save received card to Firebase: $e');
    }
  }

  static Future<List<ProfileCard>> getUserProfileCards() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return [];
      }

      final userCollection = _firestore
          .collection(_profileCardsCollection)
          .doc(userId)
          .collection('cards');

      final querySnapshot = await userCollection
          .orderBy('savedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            data.remove('savedAt');
            data.remove('userId');
            
            // Convert Firestore Timestamps to ISO strings
            if (data['createdAt'] is Timestamp) {
              data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
            }
            if (data['updatedAt'] is Timestamp) {
              data['updatedAt'] = (data['updatedAt'] as Timestamp).toDate().toIso8601String();
            }
            
            return ProfileCard.fromJson(data);
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch profile cards from Firebase: $e');
    }
  }

  static Future<List<ProfileCard>> getReceivedCards() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return [];
      }

      final receivedCollection = _firestore
          .collection(_receivedCardsCollection)
          .doc(userId)
          .collection('cards');

      final querySnapshot = await receivedCollection
          .orderBy('receivedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            data.remove('receivedAt');
            data.remove('userId');
            
            // Convert Firestore Timestamps to ISO strings
            if (data['createdAt'] is Timestamp) {
              data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
            }
            if (data['updatedAt'] is Timestamp) {
              data['updatedAt'] = (data['updatedAt'] as Timestamp).toDate().toIso8601String();
            }
            
            return ProfileCard.fromJson(data);
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch received cards from Firebase: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getReceivedCardsWithMetadata() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return [];
      }

      final receivedCollection = _firestore
          .collection(_receivedCardsCollection)
          .doc(userId)
          .collection('cards');

      final querySnapshot = await receivedCollection
          .orderBy('receivedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            final receivedAt = data['receivedAt'] as Timestamp?;
            
            // Remove Firebase-specific fields from card data
            final cardData = Map<String, dynamic>.from(data);
            cardData.remove('receivedAt');
            cardData.remove('userId');
            
            // Convert Firestore Timestamps to ISO strings
            if (cardData['createdAt'] is Timestamp) {
              cardData['createdAt'] = (cardData['createdAt'] as Timestamp).toDate().toIso8601String();
            }
            if (cardData['updatedAt'] is Timestamp) {
              cardData['updatedAt'] = (cardData['updatedAt'] as Timestamp).toDate().toIso8601String();
            }
            
            return {
              'profileCard': ProfileCard.fromJson(cardData),
              'receivedAt': receivedAt?.toDate() ?? DateTime.now(),
            };
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch received cards with metadata from Firebase: $e');
    }
  }

  static Future<void> updateProfileCard(ProfileCard profileCard) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final userCollection = _firestore
          .collection(_profileCardsCollection)
          .doc(userId)
          .collection('cards');

      final cardData = profileCard.toJson();
      cardData['updatedAt'] = FieldValue.serverTimestamp();
      
      await userCollection.doc(profileCard.id).update(cardData);
    } catch (e) {
      throw Exception('Failed to update profile card in Firebase: $e');
    }
  }

  static Future<void> deleteProfileCard(String cardId) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final userCollection = _firestore
          .collection(_profileCardsCollection)
          .doc(userId)
          .collection('cards');

      await userCollection.doc(cardId).delete();
    } catch (e) {
      throw Exception('Failed to delete profile card from Firebase: $e');
    }
  }

  static Future<void> deleteReceivedCard(String cardId) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final receivedCollection = _firestore
          .collection(_receivedCardsCollection)
          .doc(userId)
          .collection('cards');

      await receivedCollection.doc(cardId).delete();
    } catch (e) {
      throw Exception('Failed to delete received card from Firebase: $e');
    }
  }

  static Future<void> _signInAnonymously() async {
    try {
      print('FirebaseProfileService: Attempting anonymous sign-in');
      final userCredential = await _auth.signInAnonymously();
      print('FirebaseProfileService: Anonymous sign-in successful. User ID: ${userCredential.user?.uid}');
    } catch (e) {
      print('FirebaseProfileService: Anonymous sign-in failed: $e');
      throw Exception('Failed to sign in anonymously: $e');
    }
  }

  static Future<void> syncLocalData() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        await _signInAnonymously();
      }
    } catch (e) {
      throw Exception('Failed to sync local data: $e');
    }
  }
}