import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import 'profile_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _pushNotifications = true;

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E11),
      appBar: AppBar(title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00BFA5))),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.white70),
            title: const Text('View Profile', style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          const Divider(color: Color(0xFF30363D)),
          const Text('Preferences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00BFA5))),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode, color: Colors.white70),
            title: const Text('Dark Mode', style: TextStyle(color: Colors.white)),
            value: themeMode == ThemeMode.dark,
            onChanged: (val) => ref.read(themeProvider.notifier).toggleTheme(val),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.notifications, color: Colors.white70),
            title: const Text('Push Notifications', style: TextStyle(color: Colors.white)),
            value: _pushNotifications,
            onChanged: (val) => setState(() => _pushNotifications = val),
          ),
          const Divider(color: Color(0xFF30363D)),
          const Text('Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent)),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
            onTap: () {
              ref.read(authProvider.notifier).signOut();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
