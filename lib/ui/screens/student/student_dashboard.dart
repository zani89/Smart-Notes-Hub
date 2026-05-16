import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/notes_provider.dart';
import '../../../providers/assignments_provider.dart';
import '../../widgets/note_card.dart';
import '../profile_screen.dart';
import '../teacher/upload_note_screen.dart';
import 'workspace_screen.dart';
import 'collaboratory_screen.dart';
import 'assignments_screen.dart';
import 'my_notes_screen.dart';

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
      backgroundColor: const Color(0xFF0B0E11),
      body: Stack(
        children: [
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
                _buildHome(authState, notesState, assignState),
                const MyNotesScreen(),
                const WorkspaceScreen(),
                const CollaboratoryScreen(),
                const AssignmentsScreen(),
                const ProfileScreen(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              heroTag: "dashboardFab",
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UploadNoteScreen())),
              backgroundColor: const Color(0xFF00BFA5),
              child: const Icon(Icons.add, color: Colors.black),
            )
          : null,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  String _getMotivationalQuote() {
    final quotes = [
      "Believe you can and you're halfway there.",
      "The secret of getting ahead is getting started.",
      "Your education is a dress rehearsal for a life that is yours to lead.",
      "Success is the sum of small efforts repeated day in and day out.",
      "The expert in anything was once a beginner.",
    ];
    return quotes[DateTime.now().second % quotes.length];
  }

  Widget _buildHome(AuthState auth, NotesState notes, AssignmentsState assign) {
    final user = auth.user;
    final myNotes = notes.notes.where((n) => n.uploaderId == user?.id).toList();
    final approvedNotes = myNotes.where((n) => n.status == 'approved').length;
    final totalAssignments = assign.assignments.length;
    final completedAssignments = assign.submissions.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome back,', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 16)),
                    Text(user?.name ?? 'Student', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    if (user?.uniId != null) ...[
                      const SizedBox(height: 2),
                      Text('ID: ${user!.uniId}', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
                    ],
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00BFA5).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF00BFA5).withValues(alpha: 0.3)),
                      ),
                      child: Text('Semester ${user?.semester ?? "N/A"}', style: const TextStyle(color: Color(0xFF00BFA5), fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFF1C222D),
                backgroundImage: user?.profileImageUrl != null ? NetworkImage(user!.profileImageUrl!) : null,
                child: user?.profileImageUrl == null ? const Icon(Icons.person_outline, color: Color(0xFF00BFA5), size: 30) : null,
              ),
            ],
          ),
          const SizedBox(height: 30),
          
          const Text('Your Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          _buildProgressTracker(approvedNotes, myNotes.length, 'Notes Approved'),
          const SizedBox(height: 12),
          _buildProgressTracker(completedAssignments, totalAssignments, 'Assignments Done'),
          
          const SizedBox(height: 30),
          _buildQuickStats(notes, assign, user?.id),
          
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Notes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              TextButton(
                onPressed: () => setState(() => _selectedIndex = 1),
                child: const Text('View All', style: TextStyle(color: Color(0xFF00BFA5))),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (notes.notes.isEmpty)
            const Center(child: Text('No notes yet.', style: TextStyle(color: Colors.white54)))
          else
            ...notes.notes.take(3).map((n) => NoteCard(note: n)),
            
          const SizedBox(height: 30),
          const Text('Favorites', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          _buildFavoritesShortcut(notes),
          const SizedBox(height: 100), // Padding for BottomNav
        ],
      ),
    );
  }

  Widget _buildProgressTracker(int completed, int total, String label) {
    final progress = total == 0 ? 0.0 : completed / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            Text('${(progress * 100).toInt()}%', style: const TextStyle(color: Color(0xFF00BFA5), fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFF1C222D),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00BFA5)),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(NotesState notes, AssignmentsState assign, String? userId) {
    final myNotes = notes.notes.where((n) => n.uploaderId == userId).toList();
    final totalUploaded = myNotes.length;
    final approved = myNotes.where((n) => n.status == 'approved').length;
    final pending = myNotes.where((n) => n.status == 'pending').length;
    final submitted = assign.submissions.length;
    final graded = assign.submissions.where((s) => s.grade != null).length;
    final favCount = notes.favorites.length;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _statCard('My Notes', '$approved/$totalUploaded', 'Approved', Icons.description_outlined),
        _statCard('Pending', pending.toString(), 'In Review', Icons.hourglass_empty),
        _statCard('Tasks', '$graded/$submitted', 'Graded/Submitted', Icons.assignment_turned_in_outlined),
        _statCard('Saved', favCount.toString(), 'Favorites', Icons.bookmark_border),
      ],
    );
  }

  Widget _statCard(String label, String value, String subLabel, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C222D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF00BFA5), size: 20),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(subLabel, style: const TextStyle(fontSize: 10, color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _buildFavoritesShortcut(NotesState notes) {
    final favNotes = notes.notes.where((n) => notes.favorites.contains(n.id)).toList();
    if (favNotes.isEmpty) {
      return const Text('No favorites yet.', style: TextStyle(color: Colors.white54));
    }
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: favNotes.length,
        itemBuilder: (context, index) {
          final note = favNotes[index];
          return Container(
            width: 150,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1C222D),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFBC13FE).withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.bookmark, color: Color(0xFFBC13FE), size: 20),
                const Spacer(),
                Text(note.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(note.course, style: const TextStyle(color: Colors.white54, fontSize: 10)),
              ],
            ),
          );
        },
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
                _navItem(1, Icons.folder_open_rounded, 'My Notes'),
                _navItem(2, Icons.library_books_outlined, 'Library'),
                _navItem(3, Icons.group_work_outlined, 'Co-lab'),
                _navItem(4, Icons.assignment_outlined, 'Tasks'),
                _navItem(5, Icons.person_outline, 'Profile'),
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
