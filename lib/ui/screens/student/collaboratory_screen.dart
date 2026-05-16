import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/collaboration_provider.dart';
import '../../widgets/note_card.dart';
import 'collab_requests_screen.dart';

class CollaboratoryScreen extends ConsumerWidget {
  const CollaboratoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collabState = ref.watch(collaborationProvider);

    return Padding(
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
                  const Text('Collaboratory', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Shared notes from peers', style: TextStyle(color: Colors.white54, fontSize: 16)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.history_edu_outlined, color: Color(0xFF00BFA5), size: 28),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CollabRequestsScreen()),
                ),
                tooltip: 'My Requests',
              ),
            ],
          ),
          const SizedBox(height: 30),
          Expanded(
            child: collabState.isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF00BFA5)))
                : collabState.sharedNotes.isEmpty
                    ? const Center(child: Text('No shared notes yet.', style: TextStyle(color: Colors.white54)))
                    : ListView.builder(
                        itemCount: collabState.sharedNotes.length,
                        itemBuilder: (context, index) {
                          final note = collabState.sharedNotes[index];
                          return NoteCard(
                            note: note,
                            // Adding an example request edit button action
                            onApprove: () {
                              _showRequestDialog(context, ref, note.id);
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showRequestDialog(BuildContext context, WidgetRef ref, String noteId) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C222D),
        title: const Text('Request Edit Access', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: reasonController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(labelText: 'Reason', labelStyle: TextStyle(color: Colors.white70)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ref.read(collaborationProvider.notifier).requestContribution(noteId, reasonController.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request sent!')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BFA5)),
            child: const Text('Send Request', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
