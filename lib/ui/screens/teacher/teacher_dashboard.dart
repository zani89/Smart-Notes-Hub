import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/notes_provider.dart';
import '../../widgets/note_card.dart';
import '../settings_screen.dart';

class TeacherDashboard extends ConsumerStatefulWidget {
  const TeacherDashboard({super.key});

  @override
  ConsumerState<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends ConsumerState<TeacherDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final notesState = ref.watch(notesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E11),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildClassroomHub(),
            _buildNoteRepository(notesState),
            _buildAssessmentBuilder(),
            _buildGradingFeedback(),
            _buildCalendar(),
            _buildInsights(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildClassroomHub() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Classroom Hub', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Manage your students and courses', style: TextStyle(color: Colors.white54, fontSize: 16)),
          const SizedBox(height: 30),
          _quickActionCard('Active Courses', '4', Icons.school_outlined, const Color(0xFFBC13FE)),
          const SizedBox(height: 16),
          _quickActionCard('Enrolled Students', '128', Icons.people_outline, const Color(0xFF00BFA5)),
        ],
      ),
    );
  }

  Widget _quickActionCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C222D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white54, fontSize: 14)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoteRepository(NotesState notes) {
    final pendingNotes = notes.notes.where((n) => n.status == 'pending').toList();
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Note Repository', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: pendingNotes.isEmpty 
              ? const Center(child: Text('No notes pending review', style: TextStyle(color: Colors.white38)))
              : ListView.builder(
                  itemCount: pendingNotes.length,
                  itemBuilder: (context, index) => NoteCard(
                    note: pendingNotes[index],
                    isTeacher: true,
                    onApprove: () => ref.read(notesProvider.notifier).updateNoteStatus(pendingNotes[index].id, 'approved'),
                    onReject: () => ref.read(notesProvider.notifier).updateNoteStatus(pendingNotes[index].id, 'rejected'),
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentBuilder() {
    return const Center(child: Text('Assessment Builder: Create Quizzes', style: TextStyle(color: Colors.white38)));
  }

  Widget _buildGradingFeedback() {
    return const Center(child: Text('Grading & Performance Metrics', style: TextStyle(color: Colors.white38)));
  }

  Widget _buildCalendar() {
    return const Center(child: Text('Calendar & Deadlines', style: TextStyle(color: Colors.white38)));
  }

  Widget _buildInsights() {
    return const Center(child: Text('Insights: Student Progress Analytics', style: TextStyle(color: Colors.white38)));
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF1C222D),
      selectedItemColor: const Color(0xFF00BFA5),
      unselectedItemColor: Colors.white38,
      showSelectedLabels: true,
      showUnselectedLabels: false,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.hub_outlined), label: 'Hub'),
        BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Repo'),
        BottomNavigationBarItem(icon: Icon(Icons.quiz_outlined), label: 'Quiz'),
        BottomNavigationBarItem(icon: Icon(Icons.grade_outlined), label: 'Grading'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: 'Cal'),
        BottomNavigationBarItem(icon: Icon(Icons.insights_outlined), label: 'Insights'),
      ],
    );
  }
}
