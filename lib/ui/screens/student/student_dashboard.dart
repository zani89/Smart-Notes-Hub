import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/notes_provider.dart';
import '../../../providers/assignments_provider.dart';
import '../../widgets/note_card.dart';
import '../../widgets/glass_container.dart';
import '../settings_screen.dart';
import 'workspace_screen.dart';
import 'collaboratory_screen.dart';
import 'flashcards_screen.dart';
import 'assignments_screen.dart';

class StudentDashboard extends ConsumerStatefulWidget {
  const StudentDashboard({super.key});

  @override
  ConsumerState<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends ConsumerState<StudentDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final notesState = ref.watch(notesProvider);
    final assignState = ref.watch(assignmentsProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00BFA5).withValues(alpha: 0.1),
              ),
            ),
          ),
          
          SafeArea(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                _buildHome(authState, notesState, assignState.pendingAssignments.length),
                const WorkspaceScreen(),
                const CollaboratoryScreen(),
                const FlashcardsScreen(),
                const AssignmentsScreen(),
                _buildProfile(authState),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHome(AuthState auth, NotesState notes, int pendingTasksCount) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Good Morning,', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  Text(auth.user?.name ?? 'Scholar', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                ],
              ),
              CircleAvatar(
                radius: 25,
                backgroundColor: const Color(0xFF00BFA5).withValues(alpha: 0.2),
                child: Icon(Icons.person_outline, color: const Color(0xFF00BFA5)),
              ),
            ],
          ),
          const SizedBox(height: 30),
          _buildFocusStats(notes, pendingTasksCount),
          const SizedBox(height: 30),
          const Text('Recent Notes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),
          ...notes.notes.take(3).map((n) => NoteCard(note: n)),
        ],
      ),
    );
  }

  Widget _buildFocusStats(NotesState notesState, int pendingTasksCount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C222D),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF00BFA5).withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(color: const Color(0xFF00BFA5).withValues(alpha: 0.1), blurRadius: 20, spreadRadius: 2),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('Focus', '2.5h', Icons.timer_outlined),
          _statItem('Notes', notesState.notes.length.toString(), Icons.description_outlined),
          _statItem('Tasks', pendingTasksCount.toString(), Icons.check_circle_outline),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF00BFA5), size: 24),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white54)),
      ],
    );
  }

  Widget _buildProfile(AuthState auth) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text('Profile & Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 30),
          ListTile(
            leading: const Icon(Icons.settings_outlined, color: Colors.white70),
            title: const Text('Settings'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Logout'),
            onTap: () => ref.read(authProvider.notifier).signOut(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20, top: 10),
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ColorFilter.mode(Colors.white.withValues(alpha: 0.05), BlendMode.srcOver),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.grid_view_rounded, 'Home'),
                _navItem(1, Icons.folder_copy_outlined, 'Files'),
                _navItem(2, Icons.group_work_outlined, 'Co-lab'),
                _navItem(3, Icons.style_outlined, 'Cards'),
                _navItem(4, Icons.assignment_outlined, 'Tasks'),
                _navItem(5, Icons.person_outline, 'User'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF00BFA5) : Colors.white38,
            size: isSelected ? 28 : 24,
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 4,
              height: 4,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF00BFA5)),
            ),
        ],
      ),
    );
  }
}
