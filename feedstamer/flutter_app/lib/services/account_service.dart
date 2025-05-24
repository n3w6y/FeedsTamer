import 'package:feedstamer/models/twitter_user.dart';

class AccountService {
  // Singleton pattern
  static final AccountService _instance = AccountService._internal();
  factory AccountService() => _instance;
  AccountService._internal();
  
  // Mock data for demo
  final List<TwitterUser> _followedAccounts = [
    TwitterUser(
      id: '1',
      username: 'elonmusk',
      displayName: 'Elon Musk',
      profileImageUrl: 'https://pbs.twimg.com/profile_images/1683325380441128960/yRsRRjGO_400x400.jpg',
    ),
    TwitterUser(
      id: '2',
      username: 'BillGates',
      displayName: 'Bill Gates',
      profileImageUrl: 'https://pbs.twimg.com/profile_images/1414439092373254147/JdS8yLGI_400x400.jpg',
    ),
    TwitterUser(
      id: '3',
      username: 'tim_cook',
      displayName: 'Tim Cook',
      profileImageUrl: 'https://pbs.twimg.com/profile_images/1535420431766671360/Pwq-1eJc_400x400.jpg',
    ),
  ];
  
  // Return followed accounts
  List<TwitterUser> get followedAccounts => _followedAccounts;
  
  // Get followed accounts (API call simulation)
  Future<List<TwitterUser>> getFollowedAccounts() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    return _followedAccounts;
  }
  
  // Follow account
  Future<void> followAccount(String accountId) async {
    // Implementation would add to _followedAccounts
  }
  
  // Unfollow account
  Future<void> unfollowAccount(String accountId) async {
    // Implementation would remove from _followedAccounts
  }
}