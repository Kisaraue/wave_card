import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/auth_service.dart';
import '../data/models/app_user.dart';
import '../data/storage/secure_storage_service.dart';

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Firebase user stream provider
final firebaseUserProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// App user provider
final appUserProvider = FutureProvider<AppUser?>((ref) async {
  final firebaseUser = ref.watch(firebaseUserProvider).asData?.value;
  
  if (firebaseUser == null) {
    return null;
  }
  
  final authService = ref.watch(authServiceProvider);
  return await authService.getCurrentUserData();
});

// Auth state provider
final authStateProvider = Provider<AuthState>((ref) {
  final firebaseUserAsync = ref.watch(firebaseUserProvider);
  final appUserAsync = ref.watch(appUserProvider);
  
  return firebaseUserAsync.when(
    data: (firebaseUser) {
      if (firebaseUser == null) {
        return AuthState.unauthenticated();
      }
      
      return appUserAsync.when(
        data: (appUser) {
          if (appUser != null) {
            return AuthState.authenticated(appUser);
          } else {
            return AuthState.loading();
          }
        },
        loading: () => AuthState.loading(),
        error: (error, stackTrace) => AuthState.error(error.toString()),
      );
    },
    loading: () => AuthState.loading(),
    error: (error, stackTrace) => AuthState.error(error.toString()),
  );
});

// Auth controller provider
final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref);
});

// Auth controller class
class AuthController {
  final Ref _ref;
  
  AuthController(this._ref);
  
  AuthService get _authService => _ref.read(authServiceProvider);
  
  // Sign up
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final result = await _authService.signUpWithEmailAndPassword(
      email: email,
      password: password,
      fullName: fullName,
    );
    
    if (result.isSuccess) {
      // Refresh providers after successful signup
      _ref.invalidate(firebaseUserProvider);
      _ref.invalidate(appUserProvider);
      
      // For new users, initialize backup preference as false
      await _initializeBackupPreferenceForNewUser();
    }
    
    return result;
  }

  // Initialize backup preference for new users
  Future<void> _initializeBackupPreferenceForNewUser() async {
    try {
      final storageService = SecureStorageService();
      // Set backup as disabled by default for new users
      await storageService.setBackupCardsEnabled(false);
    } catch (e) {
      print('Error initializing backup preference for new user: $e');
    }
  }
  
  // Sign in
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    final result = await _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    if (result.isSuccess) {
      // Refresh providers after successful signin
      _ref.invalidate(firebaseUserProvider);
      _ref.invalidate(appUserProvider);
      
      // Sync backup preference from Firebase to local storage
      await _syncBackupPreferenceFromFirebase();
    }
    
    return result;
  }

  // Sync backup preference from Firebase to local storage after login
  Future<void> _syncBackupPreferenceFromFirebase() async {
    try {
      final storageService = SecureStorageService();
      final firebaseEnabled = await storageService.getBackupEnabledFromFirebase();
      
      if (firebaseEnabled != null) {
        // Update local storage with Firebase value (don't update Firebase again)
        await storageService.setBackupCardsEnabled(firebaseEnabled, updateFirebase: false);
      }
    } catch (e) {
      print('Error syncing backup preference from Firebase: $e');
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    await _authService.signOut();
    // Refresh providers after signout
    _ref.invalidate(firebaseUserProvider);
    _ref.invalidate(appUserProvider);
  }
  
  // Send password reset email
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    return await _authService.sendPasswordResetEmail(email);
  }
  
  // Update user profile
  Future<AuthResult> updateUserProfile({
    required String uid,
    String? fullName,
    String? profileImageUrl,
  }) async {
    final result = await _authService.updateUserProfile(
      uid: uid,
      fullName: fullName,
      profileImageUrl: profileImageUrl,
    );
    
    if (result.isSuccess) {
      // Refresh user data after successful update
      _ref.invalidate(appUserProvider);
    }
    
    return result;
  }
  
  // Delete account
  Future<AuthResult> deleteAccount() async {
    final result = await _authService.deleteAccount();
    
    if (result.isSuccess) {
      // Refresh providers after account deletion
      _ref.invalidate(firebaseUserProvider);
      _ref.invalidate(appUserProvider);
    }
    
    return result;
  }
}

// Auth state class
class AuthState {
  final AuthStatus status;
  final AppUser? user;
  final String? errorMessage;
  
  AuthState._({
    required this.status,
    this.user,
    this.errorMessage,
  });
  
  factory AuthState.loading() {
    return AuthState._(status: AuthStatus.loading);
  }
  
  factory AuthState.authenticated(AppUser user) {
    return AuthState._(status: AuthStatus.authenticated, user: user);
  }
  
  factory AuthState.unauthenticated() {
    return AuthState._(status: AuthStatus.unauthenticated);
  }
  
  factory AuthState.error(String message) {
    return AuthState._(status: AuthStatus.error, errorMessage: message);
  }
  
  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get isError => status == AuthStatus.error;
}

enum AuthStatus {
  loading,
  authenticated,
  unauthenticated,
  error,
}