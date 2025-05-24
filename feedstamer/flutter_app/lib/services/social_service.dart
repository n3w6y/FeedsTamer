import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:feedstamer/models/user_profile.dart';
import 'package:feedstamer/services/auth_service.dart';

class SocialService {
  // Singleton pattern
  static final SocialService _instance = SocialService._internal();
  factory SocialService() => _instance;
  SocialService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  final logger = Logger();

  // Get contacts
  Future<List<Contact>> getContacts() async {
    try {
      // Check permission
      final status = await Permission.contacts.request();
      
      if (status != PermissionStatus.granted) {
        logger.w('Contacts permission not granted');
        return [];
      }
      
      // Get contacts
      final contacts = await ContactsService.getContacts();
      logger.i('Retrieved ${contacts.length} contacts');
      
      return contacts.toList();
    } catch (e) {
      logger.e('Error getting contacts: $e');
      return [];
    }
  }

  // Filter contacts that have the app installed
  Future<List<Contact>> getContactsWithApp(List<Contact> allContacts) async {
    try {
      final appContacts = <Contact>[];
      
      // Get phone numbers from contacts
      final phoneNumbers = <String>[];
      
      for (final contact in allContacts) {
        for (final phone in contact.phones ?? []) {
          if (phone.value != null) {
            // Normalize phone number (remove spaces, dashes, etc.)
            final normalizedPhone = phone.value!
                .replaceAll(RegExp(r'[^\d+]'), '')
                .replaceAll(RegExp(r'^\+'), '');
                
            if (normalizedPhone.isNotEmpty) {
              phoneNumbers.add(normalizedPhone);
            }
          }
        }
      }
      
      if (phoneNumbers.isEmpty) {
        return [];
      }
      
      // Query Firestore for users with matching phone numbers
      // Note: In a real app, you would use Firebase Cloud Functions
      // to securely perform this lookup with phone number hashing
      final querySnapshot = await _firestore
          .collection('users')
          .where('phoneNumber', whereIn: phoneNumbers)
          .get();
          
      final matchedPhones = querySnapshot.docs
          .map((doc) => doc.data()['phoneNumber'] as String)
          .toList();
          
      // Filter contacts with matched phone numbers
      for (final contact in allContacts) {
        for (final phone in contact.phones ?? []) {
          if (phone.value != null) {
            final normalizedPhone = phone.value!
                .replaceAll(RegExp(r'[^\d+]'), '')
                .replaceAll(RegExp(r'^\+'), '');
                
            if (matchedPhones.contains(normalizedPhone)) {
              appContacts.add(contact);
              break;
            }
          }
        }
      }
      
      logger.i('Found ${appContacts.length} contacts with the app installed');
      
      return appContacts;
    } catch (e) {
      logger.e('Error filtering contacts with app: $e');
      return [];
    }
  }

  // Share account suggestion with contact
  Future<bool> shareAccountSuggestion(String twitterUsername, Contact contact) async {
    try {
      // Create deep link URL for the app
      final deepLink = 'feedstamer://follow?username=$twitterUsername';
      
      // Create share message
      final message = 'Check out @$twitterUsername on X! Follow them on FeedsTamer: $deepLink';
      
      // Get contact's phone number
      String? phoneNumber;
      
      for (final phone in contact.phones ?? []) {
        if (phone.value != null) {
          phoneNumber = phone.value;
          break;
        }
      }
      
      if (phoneNumber == null) {
        logger.w('No phone number found for contact');
        return false;
      }
      
      // Share via Share.share (will open the platform share sheet)
      await Share.share(
        message,
        subject: 'Follow @$twitterUsername on FeedsTamer',
      );
      
      // Log the share
      if (_auth.currentUser != null) {
        await _firestore.collection('shares').add({
          'userId': _auth.currentUser!.uid,
          'twitterUsername': twitterUsername,
          'sharedAt': DateTime.now(),
        });
      }
      
      logger.i('Shared account suggestion for @$twitterUsername');
      
      return true;
    } catch (e) {
      logger.e('Error sharing account suggestion: $e');
      return false;
    }
  }

  // Share account suggestion via general share dialog
  Future<bool> shareAccount(String twitterUsername) async {
    try {
      // Create deep link URL for the app
      final deepLink = 'feedstamer://follow?username=$twitterUsername';
      
      // Create share message
      final message = 'Check out @$twitterUsername on X! Follow them on FeedsTamer: $deepLink';
      
      // Share via Share.share (will open the platform share sheet)
      await Share.share(
        message,
        subject: 'Follow @$twitterUsername on FeedsTamer',
      );
      
      // Log the share
      if (_auth.currentUser != null) {
        await _firestore.collection('shares').add({
          'userId': _auth.currentUser!.uid,
          'twitterUsername': twitterUsername,
          'sharedAt': DateTime.now(),
        });
      }
      
      logger.i('Shared account suggestion for @$twitterUsername');
      
      return true;
    } catch (e) {
      logger.e('Error sharing account: $e');
      return false;
    }
  }

  // Get streak information
  Future<Map<String, dynamic>> getStreakInfo() async {
    try {
      final profile = _authService.currentUserProfile;
      
      if (profile == null) {
        throw Exception('User profile not loaded');
      }
      
      // Check if streak should be updated today
      final updatedProfile = profile.updateStreak();
      
      // Update streak in Firestore if necessary
      if (updatedProfile.streakCount != profile.streakCount ||
          updatedProfile.lastActiveDate != profile.lastActiveDate) {
        await _firestore.collection('users').doc(profile.id).update({
          'streakCount': updatedProfile.streakCount,
          'lastActiveDate': updatedProfile.lastActiveDate,
          'updatedAt': DateTime.now(),
        });
      }
      
      // Calculate streak milestone
      int nextMilestone = 0;
      if (updatedProfile.streakCount < 7) {
        nextMilestone = 7;
      } else if (updatedProfile.streakCount < 30) {
        nextMilestone = 30;
      } else if (updatedProfile.streakCount < 100) {
        nextMilestone = 100;
      } else if (updatedProfile.streakCount < 365) {
        nextMilestone = 365;
      } else {
        // For streaks over 365, next milestone is the next multiple of 100
        nextMilestone = ((updatedProfile.streakCount / 100).floor() + 1) * 100;
      }
      
      // Calculate days to next milestone
      final daysToMilestone = nextMilestone - updatedProfile.streakCount;
      
      return {
        'currentStreak': updatedProfile.streakCount,
        'lastActiveDate': updatedProfile.lastActiveDate,
        'nextMilestone': nextMilestone,
        'daysToMilestone': daysToMilestone,
      };
    } catch (e) {
      logger.e('Error getting streak info: $e');
      return {
        'currentStreak': 0,
        'lastActiveDate': null,
        'nextMilestone': 7,
        'daysToMilestone': 7,
      };
    }
  }

  // Get leaderboard with friends
  Future<List<Map<String, dynamic>>> getFriendsLeaderboard() async {
    try {
      final currentUser = _auth.currentUser;
      
      if (currentUser == null) {
        throw Exception('No user is currently logged in');
      }
      
      // Get current user's profile
      final currentProfile = _authService.currentUserProfile;
      
      if (currentProfile == null) {
        throw Exception('User profile not loaded');
      }
      
      // Get contacts that have the app
      final contacts = await getContacts();
      final appContacts = await getContactsWithApp(contacts);
      
      // Get friend user IDs (in a real app, this would be a separate friends collection)
      // This is a simplified version that assumes contacts with the app are friends
      final friendProfiles = <Map<String, dynamic>>[];
      
      // Add current user to the leaderboard
      friendProfiles.add({
        'id': currentProfile.id,
        'displayName': currentProfile.displayName ?? 'You',
        'photoUrl': currentProfile.photoUrl,
        'streakCount': currentProfile.streakCount,
        'isCurrentUser': true,
      });
      
      // In a real app, you would query the friends collection
      // For this demo, we'll just return some mock friend data
      friendProfiles.addAll([
        {
          'id': 'friend1',
          'displayName': 'Alice Smith',
          'photoUrl': 'https://randomuser.me/api/portraits/women/32.jpg',
          'streakCount': currentProfile.streakCount + 5,
          'isCurrentUser': false,
        },
        {
          'id': 'friend2',
          'displayName': 'Bob Johnson',
          'photoUrl': 'https://randomuser.me/api/portraits/men/44.jpg',
          'streakCount': currentProfile.streakCount - 2,
          'isCurrentUser': false,
        },
        {
          'id': 'friend3',
          'displayName': 'Carol Williams',
          'photoUrl': 'https://randomuser.me/api/portraits/women/63.jpg',
          'streakCount': currentProfile.streakCount + 12,
          'isCurrentUser': false,
        },
      ]);
      
      // Sort by streak count (descending)
      friendProfiles.sort((a, b) => b['streakCount'].compareTo(a['streakCount']));
      
      // Add rank
      for (int i = 0; i < friendProfiles.length; i++) {
        friendProfiles[i]['rank'] = i + 1;
      }
      
      logger.i('Retrieved friends leaderboard with ${friendProfiles.length} entries');
      
      return friendProfiles;
    } catch (e) {
      logger.e('Error getting friends leaderboard: $e');
      return [];
    }
  }

  // Invite a contact to join the app
  Future<bool> inviteFriend(Contact contact) async {
    try {
      // Get contact's phone number or email
      String? phoneNumber;
      String? email;
      
      for (final phone in contact.phones ?? []) {
        if (phone.value != null) {
          phoneNumber = phone.value;
          break;
        }
      }
      
      for (final emailAddress in contact.emails ?? []) {
        if (emailAddress.value != null) {
          email = emailAddress.value;
          break;
        }
      }
      
      if (phoneNumber == null && email == null) {
        logger.w('No phone number or email found for contact');
        return false;
      }
      
      // Create invite message
      final message = 'Join me on FeedsTamer to manage your X feeds! '
          'Download the app: https://feedstamer.com/download';
      
      // Share via Share.share (will open the platform share sheet)
      await Share.share(
        message,
        subject: 'Join me on FeedsTamer',
      );
      
      // Log the invite
      if (_auth.currentUser != null) {
        await _firestore.collection('invites').add({
          'userId': _auth.currentUser!.uid,
          'invitedAt': DateTime.now(),
          'invitedPhone': phoneNumber,
          'invitedEmail': email,
        });
      }
      
      logger.i('Invited friend to join the app');
      
      return true;
    } catch (e) {
      logger.e('Error inviting friend: $e');
      return false;
    }
  }
}