import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';
import '../settings_screen.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E11),
      appBar: AppBar(
        title: const Text('Admin Portal', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () => ref.read(authProvider.notifier).signOut(),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildUserManagement(),
          _buildSystemAnalytics(),
          _buildModeration(),
          _buildInstitutionSettings(),
          _buildSecurityAudit(),
          _buildGlobalConfig(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1C222D),
        selectedItemColor: const Color(0xFFBC13FE),
        unselectedItemColor: Colors.white38,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people_alt_outlined), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.gavel_outlined), label: 'Mod'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_outlined), label: 'Inst'),
          BottomNavigationBarItem(icon: Icon(Icons.security_outlined), label: 'Sec'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_suggest_outlined), label: 'Config'),
        ],
      ),
    );
  }

  Widget _buildUserManagement() {
    return const Center(child: Text('User Management: Onboarding & Roles', style: TextStyle(color: Colors.white54)));
  }

  Widget _buildSystemAnalytics() {
    return const Center(child: Text('System Analytics: Real-time Performance', style: TextStyle(color: Colors.white54)));
  }

  Widget _buildModeration() {
    return const Center(child: Text('Content Moderation: Integrity Check', style: TextStyle(color: Colors.white54)));
  }

  Widget _buildInstitutionSettings() {
    return const Center(child: Text('Institution Settings: Academic Config', style: TextStyle(color: Colors.white54)));
  }

  Widget _buildSecurityAudit() {
    return const Center(child: Text('Security Audit: Access Logs', style: TextStyle(color: Colors.white54)));
  }

  Widget _buildGlobalConfig() {
    return const Center(child: Text('Global Config: Presets & Themes', style: TextStyle(color: Colors.white54)));
  }
}
