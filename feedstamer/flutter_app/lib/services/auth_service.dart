import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Feedstamer/models/user_model.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final authUserProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final userProfileProvider = FutureProvider.family<UserModel?, String>((ref, uid) async {
  return await ref.read(authServiceProvider).getUserProfile(uid);
});

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Login with email & password
  Future<UserCredential> loginWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } catch (e) {
      if (kDebugMode) {
        print('Login error: $e');
      }
      rethrow;
    }
  }
  
  // Register with email & password
  Future<UserCredential> registerWithEmailAndPassword(
    String email, 
    String password,
    String name,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create user profile in Firestore
      await _createUserProfile(credential.user!.uid, {
        'uid': credential.user!.uid,
        'email': email,
        'name': name,
        'profilePicture': '',
        'subscription': {
          'type': 'free',
          'status': 'active',
        },
        'preferences': {
          'theme': 'system',
          'notifications': {
            'enabled': true,
            'types': {
              'newContent': true,
              'accountActivity': true,
              'usageReminders': true,
            },
          },
          'FeedsSettings': {
            'defaultView': 'unified',
            'contentOrder': 'chronological',
            'showReadPosts': false,
          },
          'sessionLimits': {
            'enabled': false,
            'dailyLimit': 60,
            'reminderInterval': 20,
          },
        },
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      return credential;
    } catch (e) {
      if (kDebugMode) {
        print('Registration error: $e');
      }
      rethrow;
    }
  }
  
  // Create user profile in Firestore
  Future<void> _createUserProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).set(data);
  }
  
  // Get user profile from Firestore
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user profile: $e');
      }
      return null;
    }
  }
  
  // Update user profile
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }
  
  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
  
  // Password reset
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
  
  // Change password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');
    
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    
    // Re-authenticate
    await user.reauthenticateWithCredential(credential);
    
    // Change password
    await user.updatePassword(newPassword);
  }
  
  // Delete account
  Future<void> deleteAccount(String password) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');
    
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    
    // Re-authenticate
    await user.reauthenticateWithCredential(credential);
    
    // Delete Firestore data
    await _firestore.collection('users').doc(user.uid).delete();
    
    // Delete account
    await user.delete();
  }
}