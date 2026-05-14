import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/university_provider.dart';
import '../../widgets/empty_state.dart';
import '../settings_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;
  List<dynamic> _allUsers = [];
  bool _isLoadingUsers = false;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoadingUsers = true);
    try {
      final data = await Supabase.instance.client.from('users').select();
      setState(() => _allUsers = data as List);
    } catch (e) {
      debugPrint("Error fetching users: $e");
    }
    setState(() => _isLoadingUsers = false);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final universityProvider = Provider.of<UniversityProvider>(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Admin Console', style: TextStyle(fontSize: 14, color: Color(0xFF8B949E))),
            Text('System Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authProvider.signOut(),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildUserManagement(),
          _buildEventsManagement(universityProvider),
          _buildNotificationsManagement(universityProvider),
          _buildAnalytics(universityProvider),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFF30363D))),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people, color: Color(0xFF00BFA5)), label: 'Users'),
            BottomNavigationBarItem(icon: Icon(Icons.event_note_outlined), activeIcon: Icon(Icons.event_note, color: Color(0xFF00BFA5)), label: 'Events'),
            BottomNavigationBarItem(icon: Icon(Icons.campaign_outlined), activeIcon: Icon(Icons.campaign, color: Color(0xFF00BFA5)), label: 'Alerts'),
            BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), activeIcon: Icon(Icons.analytics, color: Color(0xFF00BFA5)), label: 'Stats'),
          ],
        ),
      ),
    );
  }

  Widget _buildUserManagement() {
    if (_isLoadingUsers) return const Center(child: CircularProgressIndicator());
    if (_allUsers.isEmpty) {
      return const EmptyState(
        icon: Icons.group_off,
        title: 'No Users Found',
        message: 'There are no students or teachers registered in the system yet.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _allUsers.length,
      itemBuilder: (context, index) {
        final user = _allUsers[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1C222D),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF30363D)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: user['role'] == 'teacher' ? Colors.purple.withValues(alpha: 0.2) : Colors.blue.withValues(alpha: 0.2),
                child: Icon(
                  user['role'] == 'teacher' ? Icons.school : Icons.person,
                  color: user['role'] == 'teacher' ? Colors.purpleAccent : Colors.blueAccent,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(user['email'], style: const TextStyle(color: Color(0xFF8B949E), fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  user['role'].toString().toUpperCase(),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEventsManagement(UniversityProvider provider) {
    if (provider.events.isEmpty) {
      return const EmptyState(
        icon: Icons.calendar_today_outlined,
        title: 'No Events Planned',
        message: 'Upcoming university events will appear here once you post them.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.events.length,
      itemBuilder: (context, index) {
        final event = provider.events[index];
        return Card(
          child: ListTile(
            title: Text(event.title),
            subtitle: Text(event.location ?? 'No location'),
            trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: () {}),
          ),
        );
      },
    );
  }

  Widget _buildNotificationsManagement(UniversityProvider provider) {
    return const EmptyState(
      icon: Icons.notifications_off_outlined,
      title: 'History Empty',
      message: 'Official announcements sent to students and teachers will be listed here.',
    );
  }

  Widget _buildAnalytics(UniversityProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _summaryCard('Active Users', _allUsers.length.toString(), Icons.people, const Color(0xFF00BFA5)),
          const SizedBox(height: 16),
          _summaryCard('Upcoming Events', provider.events.length.toString(), Icons.event, Colors.blueAccent),
          const SizedBox(height: 16),
          _summaryCard('Official Alerts', provider.notifications.length.toString(), Icons.campaign, Colors.orangeAccent),
        ],
      ),
    );
  }

  Widget _summaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1C222D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Color(0xFF8B949E))),
              Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }
}
