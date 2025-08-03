import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<AuthResult> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;
      if (user != null) {
        // Update display name
        await user.updateDisplayName(fullName);

        // Create user document in Firestore
        final appUser = AppUser(
          uid: user.uid,
          email: email,
          fullName: fullName,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(appUser.toJson());

        return AuthResult.success(appUser);
      }

      return AuthResult.failure('Failed to create user');
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred: ${e.toString()}');
    }
  }

  // Sign in with email and password
  Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;
      if (user != null) {
        // Get user data from Firestore
        final userData = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (userData.exists) {
          final appUser = AppUser.fromJson(userData.data()!);
          return AuthResult.success(appUser);
        } else {
          // Create user document if it doesn't exist (legacy users)
          final appUser = AppUser(
            uid: user.uid,
            email: user.email ?? email,
            fullName: user.displayName ?? 'User',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          await _firestore
              .collection('users')
              .doc(user.uid)
              .set(appUser.toJson());

          return AuthResult.success(appUser);
        }
      }

      return AuthResult.failure('Failed to sign in');
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Send password reset email
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return AuthResult.success(null);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred: ${e.toString()}');
    }
  }

  // Get current user data
  Future<AppUser?> getCurrentUserData() async {
    final user = currentUser;
    if (user != null) {
      try {
        final userData = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (userData.exists) {
          return AppUser.fromJson(userData.data()!);
        }
      } catch (e) {
        print('Error getting user data: $e');
      }
    }
    return null;
  }

  // Update user profile
  Future<AuthResult> updateUserProfile({
    required String uid,
    String? fullName,
    String? profileImageUrl,
  }) async {
    try {
      final Map<String, dynamic> updates = {
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (fullName != null) {
        updates['fullName'] = fullName;
        // Also update Firebase Auth display name
        await currentUser?.updateDisplayName(fullName);
      }

      if (profileImageUrl != null) {
        updates['profileImageUrl'] = profileImageUrl;
      }

      await _firestore
          .collection('users')
          .doc(uid)
          .update(updates);

      return AuthResult.success(null);
    } catch (e) {
      return AuthResult.failure('Failed to update profile: ${e.toString()}');
    }
  }

  // Delete user account
  Future<AuthResult> deleteAccount() async {
    try {
      final user = currentUser;
      if (user != null) {
        // Delete user document from Firestore
        await _firestore.collection('users').doc(user.uid).delete();
        
        // Delete the user account
        await user.delete();
        
        return AuthResult.success(null);
      }
      return AuthResult.failure('No user signed in');
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('Failed to delete account: ${e.toString()}');
    }
  }

  // Convert Firebase Auth errors to user-friendly messages
  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'Signing in with email and password is not enabled.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return e.message ?? 'An unknown error occurred.';
    }
  }
}

// Result wrapper for authentication operations
class AuthResult {
  final bool isSuccess;
  final String? errorMessage;
  final AppUser? user;

  AuthResult._(this.isSuccess, this.errorMessage, this.user);

  factory AuthResult.success(AppUser? user) {
    return AuthResult._(true, null, user);
  }

  factory AuthResult.failure(String errorMessage) {
    return AuthResult._(false, errorMessage, null);
  }
}