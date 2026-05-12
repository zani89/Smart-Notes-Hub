import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/notes_provider.dart';
import '../../widgets/note_card.dart';
import '../settings_screen.dart';
import 'upload_note_screen.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Teacher Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                authProvider.signOut();
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending Approval'),
              Tab(text: 'All Notes'),
            ],
          ),
        ),
        body: Consumer<NotesProvider>(
          builder: (context, notesProvider, child) {
            final pendingNotes = notesProvider.pendingNotes;
            final approvedNotes = notesProvider.approvedNotes;

            return TabBarView(
              children: [
                // Pending Notes Tab
                pendingNotes.isEmpty
                    ? const Center(child: Text('No pending notes'))
                    : ListView.builder(
                        itemCount: pendingNotes.length,
                        itemBuilder: (context, index) {
                          final note = pendingNotes[index];
                          return NoteCard(
                            note: note,
                            isTeacher: true,
                            onApprove: () => notesProvider.updateNoteStatus(note.id, 'approved'),
                            onReject: () => notesProvider.updateNoteStatus(note.id, 'rejected'),
                          );
                        },
                      ),
                // All Notes Tab
                approvedNotes.isEmpty
                    ? const Center(child: Text('No approved notes'))
                    : ListView.builder(
                        itemCount: approvedNotes.length,
                        itemBuilder: (context, index) {
                          return NoteCard(
                            note: approvedNotes[index],
                            isTeacher: true,
                          );
                        },
                      ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const UploadNoteScreen()));
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
