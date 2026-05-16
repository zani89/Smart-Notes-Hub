import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../providers/notes_provider.dart';
import '../../widgets/note_card.dart';

class MyNotesScreen extends ConsumerWidget {
  const MyNotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesState = ref.watch(notesProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id;

    // Filter notes uploaded by the current user
    final myNotes = notesState.notes.where((n) => n.uploaderId == userId).toList();

    // Group notes by course (Subject)
    final groupedNotes = <String, List>{};
    for (var note in myNotes) {
      groupedNotes.putIfAbsent(note.course, () => []).add(note);
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('My Notes', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('${myNotes.length} notes uploaded across ${groupedNotes.length} subjects', 
            style: const TextStyle(color: Colors.white54, fontSize: 14)),
          const SizedBox(height: 20),
          Expanded(
            child: myNotes.isEmpty
                ? const Center(child: Text('You haven\'t uploaded any notes yet.', style: TextStyle(color: Colors.white38)))
                : ListView.builder(
                    itemCount: groupedNotes.length,
                    itemBuilder: (context, index) {
                      final subject = groupedNotes.keys.elementAt(index);
                      final subjectNotes = groupedNotes[subject]!;
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              children: [
                                const Icon(Icons.folder_open, color: Color(0xFF00BFA5), size: 20),
                                const SizedBox(width: 10),
                                Text(subject, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00BFA5).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text('${subjectNotes.length}', style: const TextStyle(color: Color(0xFF00BFA5), fontSize: 12)),
                                ),
                              ],
                            ),
                          ),
                          ...subjectNotes.map((note) => NoteCard(note: note)),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
