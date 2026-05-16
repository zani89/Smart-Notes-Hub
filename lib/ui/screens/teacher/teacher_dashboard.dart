import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/notes_provider.dart';
import '../../../providers/teacher_provider.dart';
import '../../../providers/university_provider.dart';
import '../../widgets/note_card.dart';
import 'upload_note_screen.dart';
import '../profile_screen.dart';

class TeacherDashboard extends ConsumerStatefulWidget {
  const TeacherDashboard({super.key});

  @override
  ConsumerState<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends ConsumerState<TeacherDashboard> {
  int _selectedIndex = 0;
  final Set<String> _selectedNoteIds = {};
  bool _isSelectionMode = false;

  @override
  Widget build(BuildContext context) {
    final notesState = ref.watch(notesProvider);
    final teacherState = ref.watch(teacherProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E11),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UploadNoteScreen())),
              backgroundColor: const Color(0xFF00BFA5),
              child: const Icon(Icons.add, color: Colors.black),
            )
          : null,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildClassroomHub(teacherState),
            _buildNoteRepository(notesState),
            _buildAssessmentBuilder(teacherState),
            _buildGradingFeedback(teacherState),
            _buildCollabRequests(teacherState),
            _buildInsights(teacherState, notesState),
            const ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildClassroomHub(TeacherState teacher) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Classroom Hub', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Manage your students and courses', style: TextStyle(color: Colors.white54, fontSize: 16)),
          const SizedBox(height: 30),
          _quickActionCard('Active Courses', teacher.courseCount.toString(), Icons.school_outlined, const Color(0xFFBC13FE)),
          const SizedBox(height: 16),
          _quickActionCard('Enrolled Students', teacher.studentCount.toString(), Icons.people_outline, const Color(0xFF00BFA5)),
          const SizedBox(height: 16),
          _quickActionCard('Pending Reviews', teacher.pendingNotesCount.toString(), Icons.pending_actions_outlined, Colors.orangeAccent),
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
          const Text('Approval Queue', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
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

  Widget _buildAssessmentBuilder(TeacherState teacher) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Assignments', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Color(0xFF00BFA5), size: 32),
                onPressed: () => _showCreateAssignmentDialog(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: teacher.assignments.isEmpty
                ? const Center(child: Text('No assignments created yet', style: TextStyle(color: Colors.white38)))
                : ListView.builder(
                    itemCount: teacher.assignments.length,
                    itemBuilder: (context, index) {
                      final a = teacher.assignments[index];
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
                            const Icon(Icons.assignment_outlined, color: Color(0xFF00BFA5)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(a.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  Text('Due: ${a.dueDate.toLocal().toString().split(' ')[0]}', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showCreateAssignmentDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    DateTime dueDate = DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C222D),
        title: const Text('Create Assignment', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Title', labelStyle: TextStyle(color: Colors.white70))),
              TextField(controller: descCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Description', labelStyle: TextStyle(color: Colors.white70)), maxLines: 3),
              const SizedBox(height: 16),
              Text('Due: ${dueDate.toString().split(' ')[0]}', style: const TextStyle(color: Colors.white54)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (titleCtrl.text.trim().isEmpty) return;
              await ref.read(teacherProvider.notifier).createAssignment(
                title: titleCtrl.text.trim(),
                description: descCtrl.text.trim(),
                dueDate: dueDate,
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BFA5)),
            child: const Text('Create', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildGradingFeedback(TeacherState teacher) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Grading & Feedback', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: teacher.allSubmissions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('No submissions to grade', style: TextStyle(color: Colors.white38)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => ref.read(teacherProvider.notifier).fetchAllSubmissions(),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BFA5)),
                          child: const Text('Load Submissions', style: TextStyle(color: Colors.black)),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: teacher.allSubmissions.length,
                    itemBuilder: (context, index) {
                      final sub = teacher.allSubmissions[index];
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
                            Icon(
                              sub.grade != null ? Icons.check_circle : Icons.hourglass_empty,
                              color: sub.grade != null ? const Color(0xFF00BFA5) : Colors.orangeAccent,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Submission ${sub.id.substring(0, 8)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  Text(sub.grade != null ? 'Grade: ${sub.grade}' : 'Not graded', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                                ],
                              ),
                            ),
                            if (sub.grade == null)
                              IconButton(
                                icon: const Icon(Icons.grade, color: Color(0xFF00BFA5)),
                                onPressed: () => _showGradeDialog(sub.id),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showGradeDialog(String submissionId) {
    final gradeCtrl = TextEditingController();
    final feedbackCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C222D),
        title: const Text('Grade Submission', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: gradeCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Grade (e.g. A, B+, 90)', labelStyle: TextStyle(color: Colors.white70))),
            TextField(controller: feedbackCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Feedback', labelStyle: TextStyle(color: Colors.white70)), maxLines: 3),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await ref.read(teacherProvider.notifier).gradeSubmission(submissionId, gradeCtrl.text, feedbackCtrl.text);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BFA5)),
            child: const Text('Submit', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final events = ref.watch(universityProvider).events;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Calendar & Events', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: events.isEmpty
                ? const Center(child: Text('No upcoming events', style: TextStyle(color: Colors.white38)))
                : ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final e = events[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: const Color(0xFF1C222D), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF30363D))),
                        child: Row(
                          children: [
                            const Icon(Icons.event, color: Color(0xFFBC13FE)),
                            const SizedBox(width: 16),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(e.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text(e.eventDate.toLocal().toString().split(' ')[0], style: const TextStyle(color: Colors.white38, fontSize: 12)),
                            ])),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollabRequests(TeacherState teacher) {
    final pendingReqs = teacher.contributionRequests.where((r) => r.status == 'pending').toList();
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Collaboration Requests', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Manage student edit permissions', style: TextStyle(color: Colors.white54, fontSize: 16)),
          const SizedBox(height: 20),
          Expanded(
            child: pendingReqs.isEmpty
                ? const Center(child: Text('No pending collab requests', style: TextStyle(color: Colors.white38)))
                : ListView.builder(
                    itemCount: pendingReqs.length,
                    itemBuilder: (context, index) {
                      final req = pendingReqs[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C222D),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF30363D)),
                        ),
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
                                      Text(req.studentName ?? 'Unknown Student', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                      Text('Requested to edit: ${req.noteTitle ?? "Note"}', style: const TextStyle(color: Color(0xFF00BFA5), fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.check_circle_outline, color: Color(0xFF00BFA5)),
                                      onPressed: () => ref.read(teacherProvider.notifier).updateContributionRequestStatus(req.id, 'accepted'),
                                      tooltip: 'Approve',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent),
                                      onPressed: () => ref.read(teacherProvider.notifier).updateContributionRequestStatus(req.id, 'rejected'),
                                      tooltip: 'Ignore',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (req.reason != null && req.reason!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              const Text('Reason:', style: TextStyle(color: Colors.white54, fontSize: 11)),
                              Text(req.reason!, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsights(TeacherState teacher, NotesState notes) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Insights', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          _quickActionCard('Total Notes', notes.notes.length.toString(), Icons.description_outlined, const Color(0xFF00BFA5)),
          const SizedBox(height: 16),
          _quickActionCard('Pending Approvals', teacher.pendingNotesCount.toString(), Icons.pending_outlined, Colors.orangeAccent),
          const SizedBox(height: 16),
          _quickActionCard('My Assignments', teacher.assignments.length.toString(), Icons.assignment_outlined, const Color(0xFFBC13FE)),
          const SizedBox(height: 16),
          _quickActionCard('Submissions', teacher.allSubmissions.length.toString(), Icons.upload_file_outlined, Colors.blueAccent),
        ],
      ),
    );
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
        BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Approve'),
        BottomNavigationBarItem(icon: Icon(Icons.assignment_add), label: 'Assign'),
        BottomNavigationBarItem(icon: Icon(Icons.grade_outlined), label: 'Grade'),
        BottomNavigationBarItem(icon: Icon(Icons.handshake_outlined), label: 'Requests'),
        BottomNavigationBarItem(icon: Icon(Icons.insights_outlined), label: 'Insights'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    );
  }
}

