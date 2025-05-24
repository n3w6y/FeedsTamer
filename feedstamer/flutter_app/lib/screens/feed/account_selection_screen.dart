import 'package:flutter/material.dart';
import 'package:feedstamer/models/twitter_user.dart';
import 'package:feedstamer/services/account_service.dart';

class AccountSelectionScreen extends StatefulWidget {
  const AccountSelectionScreen({super.key});

  @override
  State<AccountSelectionScreen> createState() => _AccountSelectionScreenState();
}

class _AccountSelectionScreenState extends State<AccountSelectionScreen> {
  final _accountService = AccountService();
  List<TwitterUser> _accounts = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }
  
  Future<void> _loadAccounts() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final accounts = await _accountService.getFollowedAccounts();
      setState(() {
        _accounts = accounts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load accounts: $e')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Accounts'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _accounts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_search,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary.withAlpha(128),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Accounts Found',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Search for accounts to follow',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.search),
                        label: const Text('Search'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _accounts.length,
                  itemBuilder: (context, index) {
                    final account = _accounts[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: account.profileImageUrl != null
                            ? NetworkImage(account.profileImageUrl!)
                            : null,
                        child: account.profileImageUrl == null
                            ? Text(account.displayName[0])
                            : null,
                      ),
                      title: Text(account.displayName),
                      subtitle: Text('@${account.username}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.check_circle),
                        onPressed: () {},
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}