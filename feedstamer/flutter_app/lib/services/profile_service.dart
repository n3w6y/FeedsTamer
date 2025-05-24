import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:feedstamer/models/user_profile.dart';
import 'package:feedstamer/services/auth_service.dart';

class ProfileService {
  // Singleton pattern
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();
  final AuthService _authService = AuthService();
  final logger = Logger();

  // Controller for broadcasting profile updates
  final _profileController = StreamController<UserProfile?>.broadcast();
  Stream<UserProfile?> get profileStream => _profileController.stream;

  // Get current profile
  UserProfile? get currentProfile => _authService.currentUserProfile;

  // Initialize profile service
  Future<void> initialize() async {
    try {
      // Listen to auth state changes
      _auth.authStateChanges().listen((User? user) {
        if (user != null) {
          _listenToProfileChanges(user.uid);
        } else {
          _profileController.add(null);
        }
      });

      // Check for existing user
      if (_auth.currentUser != null) {
        _listenToProfileChanges(_auth.currentUser!.uid);
      }
    } catch (e) {
      logger.e('Error initializing profile service: $e');
    }
  }

  // Listen to profile changes in Firestore
  void _listenToProfileChanges(String uid) {
    _firestore.collection('users').doc(uid).snapshots().listen(
      (docSnapshot) {
        if (docSnapshot.exists) {
          final profile = UserProfile.fromFirestore(docSnapshot);
          _profileController.add(profile);
        } else {
          _profileController.add(null);
        }
      },
      onError: (e) {
        logger.e('Error listening to profile changes: $e');
      },
    );
  }

  // Update profile data
  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      final user = _auth.currentUser;
      
      if (user == null) {
        throw Exception('No user is currently logged in');
      }
      
      final updateData = <String, dynamic>{
        'updatedAt': DateTime.now(),
      };
      
      if (displayName != null) {
        updateData['displayName'] = displayName;
        await user.updateDisplayName(displayName);
      }
      
      if (photoUrl != null) {
        updateData['photoUrl'] = photoUrl;
        await user.updatePhotoURL(photoUrl);
      }
      
      if (preferences != null) {
        updateData['preferences'] = FieldValue.arrayUnion([preferences]);
      }
      
      await _firestore.collection('users').doc(user.uid).update(updateData);
      
      logger.i('Profile updated for user: ${user.uid}');
    } catch (e) {
      logger.e('Error updating profile: $e');
      rethrow;
    }
  }

  // Upload profile image
  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      final user = _auth.currentUser;
      
      if (user == null) {
        throw Exception('No user is currently logged in');
      }

      // Create file metadata
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'uploaded_by': user.uid},
      );

      // Upload to Firebase Storage
      final storageRef = _storage.ref().child('profile_images/${user.uid}/${path.basename(imageFile.path)}');
      final uploadTask = storageRef.putFile(imageFile, metadata);
      
      // Get download URL
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      // Update profile with new photo URL
      await updateProfile(photoUrl: downloadUrl);
      
      logger.i('Profile image uploaded: $downloadUrl');
      
      return downloadUrl;
    } catch (e) {
      logger.e('Error uploading profile image: $e');
      return null;
    }
  }

  // Pick image from gallery or camera
  Future<File?> pickImage({bool fromCamera = false}) async {
    try {
      final source = fromCamera ? ImageSource.camera : ImageSource.gallery;
      
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      
      if (pickedFile == null) {
        return null;
      }
      
      return File(pickedFile.path);
    } catch (e) {
      logger.e('Error picking image: $e');
      return null;
    }
  }

  // Get theme preference
  Future<String> getThemePreference() async {
    try {
      final profile = currentProfile;
      
      if (profile != null && profile.preferences.containsKey('theme')) {
        return profile.preferences['theme'] as String;
      }
      
      // If no preference in profile, check shared preferences
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('theme_preference') ?? 'system';
    } catch (e) {
      logger.e('Error getting theme preference: $e');
      return 'system';
    }
  }

  // Set theme preference
  Future<void> setThemePreference(String theme) async {
    try {
      // Save to shared preferences (for quicker access)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme_preference', theme);
      
      // Also save to profile if user is logged in
      if (_auth.currentUser != null) {
        await updateProfile(preferences: {'theme': theme});
      }
      
      logger.i('Theme preference set: $theme');
    } catch (e) {
      logger.e('Error setting theme preference: $e');
    }
  }

  // Get notification preferences
  Future<Map<String, bool>> getNotificationPreferences() async {
    try {
      final profile = currentProfile;
      
      if (profile != null && profile.preferences.containsKey('notifications')) {
        return Map<String, bool>.from(profile.preferences['notifications']);
      }
      
      // Default notification preferences
      return {
        'push_enabled': true,
        'email_updates': true,
        'streak_reminders': true,
        'new_features': true,
      };
    } catch (e) {
      logger.e('Error getting notification preferences: $e');
      return {
        'push_enabled': true,
        'email_updates': true,
        'streak_reminders': true,
        'new_features': true,
      };
    }
  }

  // Update notification preferences
  Future<void> updateNotificationPreferences(Map<String, bool> preferences) async {
    try {
      // Update profile if user is logged in
      if (_auth.currentUser != null) {
        await updateProfile(preferences: {'notifications': preferences});
      }
      
      logger.i('Notification preferences updated');
    } catch (e) {
      logger.e('Error updating notification preferences: $e');
      rethrow;
    }
  }

  // Get language preference
  Future<String> getLanguagePreference() async {
    try {
      final profile = currentProfile;
      
      if (profile != null && profile.preferences.containsKey('language')) {
        return profile.preferences['language'] as String;
      }
      
      // If no preference in profile, check shared preferences
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('language_preference') ?? 'en';
    } catch (e) {
      logger.e('Error getting language preference: $e');
      return 'en';
    }
  }

  // Set language preference
  Future<void> setLanguagePreference(String language) async {
    try {
      // Save to shared preferences (for quicker access)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_preference', language);
      
      // Also save to profile if user is logged in
      if (_auth.currentUser != null) {
        await updateProfile(preferences: {'language': language});
      }
      
      logger.i('Language preference set: $language');
    } catch (e) {
      logger.e('Error setting language preference: $e');
    }
  }

  // Check if onboarding is completed
  Future<bool> isOnboardingCompleted() async {
    try {
      final profile = currentProfile;
      
      if (profile != null && profile.preferences.containsKey('onboarding_completed')) {
        return profile.preferences['onboarding_completed'] as bool;
      }
      
      // If no preference in profile, check shared preferences
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('onboarding_completed') ?? false;
    } catch (e) {
      logger.e('Error checking if onboarding is completed: $e');
      return false;
    }
  }

  // Set onboarding completed
  Future<void> setOnboardingCompleted(bool completed) async {
    try {
      // Save to shared preferences (for quicker access)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', completed);
      
      // Also save to profile if user is logged in
      if (_auth.currentUser != null) {
        await updateProfile(preferences: {'onboarding_completed': completed});
      }
      
      logger.i('Onboarding completed set: $completed');
    } catch (e) {
      logger.e('Error setting onboarding completed: $e');
    }
  }

  // Dispose resources
  void dispose() {
    _profileController.close();
  }
}