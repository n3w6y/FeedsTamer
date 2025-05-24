import 'package:flutter/material.dart';
import 'package:feedstamer/services/auth_service.dart';
import 'package:feedstamer/models/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  bool _isLoading = true;
  UserProfile? _profile;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // The profile should already be loaded in the AuthService
      _profile = _authService.currentUserProfile;
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load profile: $e';
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign out: $e')),
        );
      }
    }
  }

  Future<void> _deactivateAccount() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Account'),
        content: const Text(
          'Are you sure you want to deactivate your account? You can reactivate it later by signing in again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await _authService.deactivateAccount();
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account deactivated successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to deactivate account: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : _profile == null
                  ? _buildNoProfileState()
                  : _buildProfileContent(theme),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'An unknown error occurred',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadProfile,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoProfileState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'No Profile Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Your profile information could not be loaded.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _signOut,
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Profile header
        _buildProfileHeader(theme),
        const SizedBox(height: 24),
        
        // Subscription info
        _buildSubscriptionInfo(theme),
        const SizedBox(height: 24),
        
        // Account stats
        _buildAccountStats(theme),
        const SizedBox(height: 24),
        
        // Profile actions
        _buildProfileActions(theme),
        const SizedBox(height: 24),
        
        // Account actions
        _buildAccountActions(theme),
      ],
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile image
            CircleAvatar(
              radius: 50,
              backgroundColor: theme.colorScheme.primary.withAlpha(50),
              backgroundImage: _profile?.photoUrl != null
                  ? NetworkImage(_profile!.photoUrl!)
                  : null,
              child: _profile?.photoUrl == null
                  ? Icon(
                      Icons.person,
                      size: 50,
                      color: theme.colorScheme.primary,
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            
            // Display name
            Text(
              _profile?.displayName ?? 'User',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            
            // Email
            Text(
              _profile?.email ?? '',
              style: theme.textTheme.bodyLarge,
            ),
            
            // Email verification badge
            if (_profile != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Chip(
                  backgroundColor: _profile!.isEmailVerified
                      ? Colors.green.withAlpha(50)
                      : Colors.orange.withAlpha(50),
                  label: Text(
                    _profile!.isEmailVerified
                        ? 'Email Verified'
                        : 'Email Not Verified',
                    style: TextStyle(
                      color: _profile!.isEmailVerified
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                  avatar: Icon(
                    _profile!.isEmailVerified
                        ? Icons.verified
                        : Icons.warning,
                    color: _profile!.isEmailVerified
                        ? Colors.green
                        : Colors.orange,
                    size: 18,
                  ),
                ),
              ),
              
            // Verify email button if not verified
            if (_profile != null && !_profile!.isEmailVerified)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextButton(
                  onPressed: () {
                    // Navigate to email verification screen
                  },
                  child: const Text('Verify Email'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionInfo(ThemeData theme) {
    // Default to free tier if profile is null
    final tier = _profile?.subscriptionTier ?? SubscriptionTier.free;
    final isActive = _profile?.hasActiveSubscription ?? false;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  tier == SubscriptionTier.free
                      ? Icons.star_border
                      : tier == SubscriptionTier.premium
                          ? Icons.star_half
                          : Icons.star,
                  color: tier == SubscriptionTier.free
                      ? theme.colorScheme.primary
                      : Colors.amber,
                ),
                const SizedBox(width: 8),
                Text(
                  'Subscription',
                  style: theme.textTheme.titleLarge,
                ),
                const Spacer(),
                Chip(
                  backgroundColor: isActive
                      ? Colors.green.withAlpha(50)
                      : Colors.red.withAlpha(50),
                  label: Text(
                    isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: isActive ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              tier == SubscriptionTier.free
                  ? 'Free Plan'
                  : tier == SubscriptionTier.premium
                      ? 'Premium Plan'
                      : 'Business Plan',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 4),
            Text(
              tier == SubscriptionTier.free
                  ? 'Follow up to 3 accounts'
                  : tier == SubscriptionTier.premium
                      ? 'Follow up to 10 accounts'
                      : 'Follow up to 25 accounts',
              style: theme.textTheme.bodyMedium,
            ),
            
            // Expiry date for paid plans
            if (tier != SubscriptionTier.free && _profile?.subscriptionExpiryDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Expires: ${_profile!.subscriptionExpiryDate!.toLocal().toString().split(' ')[0]}',
                  style: theme.textTheme.bodySmall,
                ),
              ),
              
            const SizedBox(height: 16),
            
            // Upgrade button for free tier
            if (tier == SubscriptionTier.free)
              ElevatedButton(
                onPressed: () {
                  // Navigate to subscription screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Upgrade to Premium'),
              )
            // Renew button for paid tiers
            else if (!isActive)
              ElevatedButton(
                onPressed: () {
                  // Navigate to subscription screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Renew Subscription'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountStats(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Account Stats',
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Stats grid
            Row(
              children: [
                _buildStatItem(
                  icon: Icons.people,
                  label: 'Followed',
                  value: _profile?.followedAccountIds.length.toString() ?? '0',
                  theme: theme,
                ),
                _buildStatItem(
                  icon: Icons.local_fire_department,
                  label: 'Streak',
                  value: _profile?.streakCount.toString() ?? '0',
                  theme: theme,
                ),
                _buildStatItem(
                  icon: Icons.calendar_today,
                  label: 'Since',
                  value: _profile?.createdAt != null
                      ? '${_profile!.createdAt.year}'
                      : 'N/A',
                  theme: theme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary.withAlpha(200),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileActions(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.settings,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Profile Actions',
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Edit profile button
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Profile'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to edit profile screen
              },
            ),
            
            const Divider(),
            
            // Change password button
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Change Password'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to change password screen
              },
            ),
            
            const Divider(),
            
            // Notification settings button
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notification Settings'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to notification settings screen
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountActions(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_circle,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Account Actions',
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Sign out button
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: _signOut,
            ),
            
            const Divider(),
            
            // Deactivate account button
            ListTile(
              leading: Icon(
                Icons.block,
                color: theme.colorScheme.error,
              ),
              title: Text(
                'Deactivate Account',
                style: TextStyle(
                  color: theme.colorScheme.error,
                ),
              ),
              onTap: _deactivateAccount,
            ),
          ],
        ),
      ),
    );
  }
}