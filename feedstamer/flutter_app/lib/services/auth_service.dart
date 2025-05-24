import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:logger/logger.dart';
// import 'package:shared_preferences/shared_preferences.dart'; // Uncomment if using SharedPreferences
import 'package:feedstamer/models/user_profile.dart';

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Logger logger = Logger();

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current user profile
  UserProfile? _currentUserProfile;
  UserProfile? get currentUserProfile => _currentUserProfile;

  // Get current Firebase user
  User? get currentUser => _auth.currentUser;

  // Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  // Initialize auth service
  Future<void> initialize() async {
    try {
      // Listen to auth state changes
      _auth.authStateChanges().listen((User? user) {
        if (user != null) {
          logger.i('User is signed in: ${user.uid}');
          _loadUserProfile(user.uid);
        } else {
          logger.i('User is signed out');
          _currentUserProfile = null;
        }
      });

      // Check for existing user
      if (_auth.currentUser != null) {
        logger.i('Existing user found: ${_auth.currentUser!.uid}');
        await _loadUserProfile(_auth.currentUser!.uid);
      }
    } catch (e) {
      logger.e('Error initializing auth service: $e');
    }
  }

  // Load user profile from Firestore
  Future<void> _loadUserProfile(String uid) async {
    try {
      final docRef = _firestore.collection('users').doc(uid);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        _currentUserProfile = UserProfile.fromFirestore(docSnapshot);
        
        // Update streak if needed
        final updatedProfile = _currentUserProfile!.updateStreak();
        if (updatedProfile.lastActiveDate != _currentUserProfile!.lastActiveDate || 
            updatedProfile.streakCount != _currentUserProfile!.streakCount) {
          _currentUserProfile = updatedProfile;
          await docRef.update({
            'streakCount': updatedProfile.streakCount,
            'lastActiveDate': updatedProfile.lastActiveDate,
            'updatedAt': DateTime.now(),
          });
        }
      } else {
        // Create new profile if it doesn't exist
        if (_auth.currentUser != null) {
          final userData = {
            'email': _auth.currentUser!.email ?? '',
            'displayName': _auth.currentUser!.displayName,
            'photoURL': _auth.currentUser!.photoURL,
            'emailVerified': _auth.currentUser!.emailVerified,
          };
          await _createUserProfile(uid, userData);
        }
      }
    } catch (e) {
      logger.e('Error loading user profile: $e');
    }
  }

  // Create new user profile in Firestore
  Future<void> _createUserProfile(String uid, Map<String, dynamic> userData) async {
    try {
      final newProfile = UserProfile.fromFirebaseUser(userData, uid);
      
      await _firestore.collection('users').doc(uid).set(newProfile.toMap());
      
      _currentUserProfile = newProfile;
      
      logger.i('Created new user profile for: $uid');
    } catch (e) {
      logger.e('Error creating user profile: $e');
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailPassword(String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send email verification
      await result.user?.sendEmailVerification();
      
      logger.i('Registered new user: ${result.user?.uid}');
      
      return result;
    } catch (e) {
      logger.e('Error registering user: $e');
      rethrow;
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailPassword(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      logger.i('User signed in: ${result.user?.uid}');
      
      // Load user profile
      if (result.user != null) {
        await _loadUserProfile(result.user!.uid);
      }
      
      return result;
    } catch (e) {
      logger.e('Error signing in: $e');
      rethrow;
    }
  }
/// Creates a new user with email and password
Future<UserCredential?> signUp({
  required String email,
  required String password,
  String? name,
}) async {
  try {
    // Create user with email and password
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    // Update user profile with name if provided
    if (name != null && name.isNotEmpty && userCredential.user != null) {
      await userCredential.user!.updateDisplayName(name);
      
      // Reload user to make sure the display name is updated
      await userCredential.user!.reload();
    }
    
    logger.i('User signed up: ${userCredential.user?.uid}');
    
    // Send email verification
    await userCredential.user?.sendEmailVerification();
    
    // Load user profile
    if (userCredential.user != null) {
      await _loadUserProfile(userCredential.user!.uid);
    }
    
    return userCredential;
  } on FirebaseAuthException catch (e) {
    logger.e('Error signing up: ${e.code} - ${e.message}');
    
    // Handle common sign-up errors
    switch (e.code) {
      case 'email-already-in-use':
        throw 'This email is already in use. Please use a different email or try logging in.';
      case 'weak-password':
        throw 'The password is too weak. Please use a stronger password.';
      case 'invalid-email':
        throw 'The email address is invalid. Please enter a valid email.';
      default:
        throw 'An error occurred during registration. Please try again.';
    }
  } catch (e) {
    logger.e('Unexpected error signing up: $e');
    return null;
  }
}
  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        logger.w('Google sign in was cancelled by user');
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with the credential
      final result = await _auth.signInWithCredential(credential);
      
      logger.i('User signed in with Google: ${result.user?.uid}');
      
      // Load user profile
      if (result.user != null) {
        await _loadUserProfile(result.user!.uid);
      }
      
      return result;
    } catch (e) {
      logger.e('Error signing in with Google: $e');
      return null;
    }
  }

  // Sign in with Facebook
  Future<UserCredential?> signInWithFacebook() async {
    try {
      // Trigger the sign-in flow
      final LoginResult loginResult = await FacebookAuth.instance.login();
      
      if (loginResult.status != LoginStatus.success) {
        logger.w('Facebook sign in was cancelled or failed');
        return null;
      }

      // Create a credential from the access token
      final OAuthCredential credential = FacebookAuthProvider.credential(
        loginResult.accessToken!.token,
      );

      // Sign in with the credential
      final result = await _auth.signInWithCredential(credential);
      
      logger.i('User signed in with Facebook: ${result.user?.uid}');
      
      // Load user profile
      if (result.user != null) {
        await _loadUserProfile(result.user!.uid);
      }
      
      return result;
    } catch (e) {
      logger.e('Error signing in with Facebook: $e');
      return null;
    }
  }

  // Sign in with Apple
  Future<UserCredential?> signInWithApple() async {
    try {
      // Perform the sign-in request
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create an OAuthCredential
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in with the credential
      final result = await _auth.signInWithCredential(oauthCredential);
      
      logger.i('User signed in with Apple: ${result.user?.uid}');
      
      // Store name from Apple (only provided on first sign-in)
      if (appleCredential.givenName != null &&
          appleCredential.familyName != null &&
          result.user != null) {
        final displayName = 
            '${appleCredential.givenName} ${appleCredential.familyName}';
            
        await result.user!.updateDisplayName(displayName);
        
        // Update profile in Firestore
        await _firestore.collection('users').doc(result.user!.uid).update({
          'displayName': displayName,
          'updatedAt': DateTime.now(),
        });
      }
      
      // Load user profile
      if (result.user != null) {
        await _loadUserProfile(result.user!.uid);
      }
      
      return result;
    } catch (e) {
      logger.e('Error signing in with Apple: $e');
      return null;
    }
  }

  // Sign in with Twitter
  Future<UserCredential?> signInWithTwitter() async {
    try {
      // Create a TwitterAuthProvider
      final TwitterAuthProvider twitterProvider = TwitterAuthProvider();

      // Sign in with the credential
      final result = await _auth.signInWithProvider(twitterProvider);

      logger.i('User signed in with Twitter: ${result.user?.uid}');

      // Load user profile
      if (result.user != null) {
        await _loadUserProfile(result.user!.uid);
      }

      return result;
    } catch (e) {
      logger.e('Error signing in with Twitter: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      
      _currentUserProfile = null;
      
      logger.i('User signed out');
    } catch (e) {
      logger.e('Error signing out: $e');
      rethrow;
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      logger.i('Password reset email sent to: $email');
    } catch (e) {
      logger.e('Error sending password reset email: $e');
      rethrow;
    }
  }

  // Resend email verification
  Future<void> resendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      
      if (user == null) {
        throw Exception('No user is currently logged in');
      }
      
      await user.sendEmailVerification();
      
      logger.i('Email verification sent to: ${user.email}');
    } catch (e) {
      logger.e('Error sending email verification: $e');
      rethrow;
    }
  }

  // Check if email is verified
  Future<bool> isEmailVerified() async {
    try {
      final user = _auth.currentUser;
      
      if (user == null) {
        return false;
      }
      
      // Reload user data
      await user.reload();
      
      return user.emailVerified;
    } catch (e) {
      logger.e('Error checking email verification: $e');
      return false;
    }
  }

  // Update user profile
  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    try {
      final user = _auth.currentUser;
      
      if (user == null) {
        throw Exception('No user is currently logged in');
      }
      
      // Update Firebase Auth profile
      await user.updateDisplayName(displayName);
      await user.updatePhotoURL(photoUrl);
      
      // Update Firestore profile
      await _firestore.collection('users').doc(user.uid).update({
        if (displayName != null) 'displayName': displayName,
        if (photoUrl != null) 'photoURL': photoUrl,
        'updatedAt': DateTime.now(),
      });
      
      // Update local profile
      if (_currentUserProfile != null) {
        _currentUserProfile = _currentUserProfile!.copyWith(
          displayName: displayName ?? _currentUserProfile!.displayName,
          photoUrl: photoUrl ?? _currentUserProfile!.photoUrl,
        );
      }
      
      logger.i('Profile updated for user: ${user.uid}');
    } catch (e) {
      logger.e('Error updating profile: $e');
      rethrow;
    }
  }

  // Update user preferences
  Future<void> updatePreferences(Map<String, dynamic> preferences) async {
    try {
      final user = _auth.currentUser;
      
      if (user == null) {
        throw Exception('No user is currently logged in');
      }
      
      if (_currentUserProfile == null) {
        throw Exception('User profile not loaded');
      }
      
      // Merge with existing preferences
      final mergedPreferences = {
        ..._currentUserProfile!.preferences,
        ...preferences,
      };
      
      // Update Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'preferences': mergedPreferences,
        'updatedAt': DateTime.now(),
      });
      
      // Update local profile
      _currentUserProfile = _currentUserProfile!.copyWith(
        preferences: mergedPreferences,
      );
      
      logger.i('Preferences updated for user: ${user.uid}');
    } catch (e) {
      logger.e('Error updating preferences: $e');
      rethrow;
    }
  }

  // Deactivate account
  Future<void> deactivateAccount() async {
    try {
      final user = _auth.currentUser;
      
      if (user == null) {
        throw Exception('No user is currently logged in');
      }
      
      // Update account status in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'status': AccountStatus.deactivated.toString().split('.').last,
        'updatedAt': DateTime.now(),
      });
      
      // Update local profile
      if (_currentUserProfile != null) {
        _currentUserProfile = _currentUserProfile!.copyWith(
          status: AccountStatus.deactivated,
        );
      }
      
      // Sign out the user
      await signOut();
      
      logger.i('Account deactivated for user: ${user.uid}');
    } catch (e) {
      logger.e('Error deactivating account: $e');
      rethrow;
    }
  }
}