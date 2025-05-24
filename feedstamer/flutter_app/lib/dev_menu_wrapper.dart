// lib/dev_menu_wrapper.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:feedstamer/screens/dev_menu_screen.dart';
import 'package:feedstamer/services/preference_service.dart';

/// Wrapper widget that adds a floating dev menu button to any screen in debug mode
class DevMenuWrapper extends StatefulWidget {
  final Widget child;
  
  const DevMenuWrapper({
    super.key,
    required this.child,
  });
  
  @override
  State<DevMenuWrapper> createState() => _DevMenuWrapperState();
}

class _DevMenuWrapperState extends State<DevMenuWrapper> {
  bool _showDevMenu = false;
  final PreferencesService _preferencesService = PreferencesService();
  
  @override
  void initState() {
    super.initState();
    _checkDevMenuEnabled();
  }
  
  Future<void> _checkDevMenuEnabled() async {
    if (!kDebugMode) return;
    
    final enabled = await _preferencesService.isDevMenuEnabled();
    if (mounted) {
      setState(() {
        _showDevMenu = enabled;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // In release mode, just return the child
    if (!kDebugMode) {
      return widget.child;
    }
    
    // In debug mode, wrap with dev menu button if enabled
    if (!_showDevMenu) {
      return widget.child;
    }
    
    return Stack(
      children: [
        widget.child,
        Positioned(
          right: 16,
          bottom: 80, // Above the bottom nav bar
          child: _buildDevMenuButton(context),
        ),
      ],
    );
  }
  
  Widget _buildDevMenuButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _openDevMenu(context),
      backgroundColor: Colors.red[700],
      mini: true,
      child: const Icon(
        Icons.developer_mode,
        color: Colors.white,
      ),
    );
  }
  
  void _openDevMenu(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const DevMenuScreen(),
      ),
    );
  }
}