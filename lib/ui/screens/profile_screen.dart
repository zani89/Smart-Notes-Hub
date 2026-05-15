import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0B0E11),
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('User not found', style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E11),
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1C222D),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF00BFA5),
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
          ),
          const SizedBox(height: 24),
          _buildProfileItem(Icons.person_outline, 'Full Name', user.name),
          const SizedBox(height: 16),
          _buildProfileItem(Icons.email_outlined, 'Email', user.email),
          const SizedBox(height: 16),
          _buildProfileItem(Icons.badge_outlined, 'University ID', user.uniId),
          const SizedBox(height: 16),
          _buildProfileItem(Icons.school_outlined, 'Semester', user.semester),
          const SizedBox(height: 16),
          _buildProfileItem(Icons.admin_panel_settings_outlined, 'Role', user.role.toUpperCase(), color: const Color(0xFFBC13FE)),
        ],
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String label, String value, {Color? color}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C222D),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: color ?? Colors.white70, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.white54)),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(fontSize: 16, color: color ?? Colors.white, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
