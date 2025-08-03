// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseTestService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> testFirebaseConnection() async {
    try {
      print('=== Firebase Connection Test ===');
      
      // Test 1: Check if Firebase is initialized
      print('1. Firebase initialized: ${_firestore.app.name}');
      
      // Test 2: Check authentication
      print('2. Current user: ${_auth.currentUser?.uid ?? "Not authenticated"}');
      
      // Test 3: Sign in anonymously if needed
      if (_auth.currentUser == null) {
        print('3. Signing in anonymously...');
        final userCredential = await _auth.signInAnonymously();
        print('3. Anonymous sign-in successful: ${userCredential.user?.uid}');
      } else {
        print('3. Already authenticated: ${_auth.currentUser?.uid}');
      }
      
      // Test 4: Try to write a simple test document
      print('4. Testing Firestore write...');
      final DocumentReference testDoc = _firestore.collection('test').doc('connection_test');
      await testDoc.set({
        'timestamp': FieldValue.serverTimestamp(),
        'test': true,
        'userId': _auth.currentUser?.uid,
      });
      print('4. Test document written successfully');
      
      // Test 5: Try to read the test document
      print('5. Testing Firestore read...');
      final DocumentSnapshot docSnapshot = await testDoc.get();
      if (docSnapshot.exists) {
        print('5. Test document read successfully: ${docSnapshot.data()}');
      } else {
        print('5. Test document not found');
      }
      
      // Test 6: Clean up test document
      await testDoc.delete();
      print('6. Test document cleaned up');
      
      print('=== Firebase Connection Test Completed Successfully ===');
    } catch (e) {
      print('=== Firebase Connection Test Failed ===');
      print('Error: $e');
      rethrow;
    }
  }

  static Future<void> testProfileCardSave() async {
    try {
      print('=== Profile Card Save Test ===');
      
      // Ensure user is authenticated
      if (_auth.currentUser == null) {
        await _auth.signInAnonymously();
      }
      
      final String userId = _auth.currentUser!.uid;
      print('User ID: $userId');
      
      // Test the exact collection structure used in the app
      final CollectionReference userCollection = _firestore
          .collection('profile_cards')
          .doc(userId)
          .collection('cards');
      
      print('Collection path: profile_cards/$userId/cards');
      
      // Create a test card document
      final Map<String, dynamic> testCardData = {
        'id': 'test_card_${DateTime.now().millisecondsSinceEpoch}',
        'fullName': 'Test User',
        'jobTitle': 'Test Job',
        'company': 'Test Company',
        'savedAt': FieldValue.serverTimestamp(),
        'userId': userId,
      };
      
      print('Test card data: $testCardData');
      
      await userCollection.doc(testCardData['id'] as String).set(testCardData);
      print('Test profile card saved successfully');
      
      // Verify the document exists
      final DocumentSnapshot docSnapshot = await userCollection.doc(testCardData['id'] as String).get();
      if (docSnapshot.exists) {
        print('Test profile card verified: ${docSnapshot.data()}');
      } else {
        print('Test profile card not found after save');
      }
      
      // Clean up
      await userCollection.doc(testCardData['id'] as String).delete();
      print('Test profile card cleaned up');
      
      print('=== Profile Card Save Test Completed Successfully ===');
    } catch (e) {
      print('=== Profile Card Save Test Failed ===');
      print('Error: $e');
      rethrow;
    }
  }
}