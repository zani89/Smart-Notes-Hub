import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/notes_provider.dart';
import '../../widgets/note_card.dart';
import '../settings_screen.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
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
      ),
      body: Consumer<NotesProvider>(
        builder: (context, notesProvider, child) {
          final notes = notesProvider.approvedNotes;
          if (notesProvider.isLoading && notes.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (notes.isEmpty) {
            return const Center(child: Text('No approved notes available.'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              // Can trigger manual refresh if needed
            },
            child: ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return NoteCard(note: notes[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
