import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/notes_provider.dart';
import '../../widgets/note_card.dart';
import '../settings_screen.dart';
import 'upload_note_screen.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final notesProvider = Provider.of<NotesProvider>(context);
    final analytics = notesProvider.getAnalytics();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Teacher Central', style: TextStyle(fontSize: 14, color: Color(0xFF8B949E))),
            Text('Management Dashboard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF00BFA5),
          labelColor: const Color(0xFF00BFA5),
          unselectedLabelColor: const Color(0xFF8B949E),
          tabs: const [
            Tab(text: 'Review'),
            Tab(text: 'Library'),
            Tab(text: 'Stats'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF8B949E)),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF8B949E)),
            onPressed: () => authProvider.signOut(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(notesProvider.pendingNotes, notesProvider, isApproval: true),
          _buildList(notesProvider.approvedNotes, notesProvider),
          _buildAnalytics(analytics),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UploadNoteScreen())),
        label: const Text('New Entry', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add, color: Colors.black),
        backgroundColor: const Color(0xFF00BFA5),
      ),
    );
  }

  Widget _buildList(List notes, NotesProvider provider, {bool isApproval = false}) {
    if (notes.isEmpty) {
      return Center(
        child: Text(
          isApproval ? 'No pending requests' : 'Your library is empty',
          style: const TextStyle(color: Color(0xFF8B949E)),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return NoteCard(
          note: note,
          isTeacher: true,
          onApprove: isApproval ? () => provider.updateNoteStatus(note.id, 'approved') : null,
          onReject: isApproval ? () => provider.updateNoteStatus(note.id, 'rejected') : null,
        );
      },
    );
  }

  Widget _buildAnalytics(Map<String, dynamic> stats) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _analyticCard('Active Submissions', stats['total'].toString(), Icons.analytics_outlined, const Color(0xFF00BFA5)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _analyticCard('Success', stats['approved'].toString(), Icons.check_circle_outline, Colors.greenAccent)),
              const SizedBox(width: 16),
              Expanded(child: _analyticCard('Waiting', stats['pending'].toString(), Icons.hourglass_bottom, Colors.orangeAccent)),
            ],
          ),
          const SizedBox(height: 16),
          _analyticCard('Approval Index', stats['rate'], Icons.speed_outlined, Colors.purpleAccent),
        ],
      ),
    );
  }

  Widget _analyticCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1C222D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Color(0xFF8B949E), fontSize: 12)),
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }
}
