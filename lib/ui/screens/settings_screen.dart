import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
          const SizedBox(height: 10),
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(user?.name ?? 'User Name'),
            subtitle: Text(user?.email ?? 'Email'),
            trailing: IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
          ),
          ListTile(
            leading: const Icon(Icons.badge),
            title: const Text('Role'),
            trailing: Text(user?.role.toUpperCase() ?? 'STUDENT', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const Divider(),
          const Text('Preferences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            value: themeProvider.isDarkMode,
            onChanged: (val) => themeProvider.toggleTheme(val),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text('Push Notifications'),
            value: _pushNotifications,
            onChanged: (val) => setState(() => _pushNotifications = val),
          ),
          const Divider(),
          const Text('Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              authProvider.signOut();
              Navigator.pop(context);
            },
          ),
          const ListTile(
            leading: Icon(Icons.delete_forever, color: Colors.grey),
            title: Text('Delete Account', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
