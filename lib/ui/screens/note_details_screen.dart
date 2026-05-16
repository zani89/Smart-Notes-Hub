import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/note_model.dart';
import '../../../providers/collaboration_provider.dart';
import '../../../providers/notes_provider.dart';

class NoteDetailsScreen extends ConsumerWidget {
  final NoteModel note;

  const NoteDetailsScreen({super.key, required this.note});

  void _exportAsText(BuildContext context) {
    final text = 'Title: ${note.title}\nAuthor: ${note.uploaderName}\nCourse: ${note.course}\nSemester: ${note.semester}\n\n${note.content}';
    debugPrint("Exporting Note: $text");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Note exported as Text')),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    final contentController = TextEditingController(text: note.content);
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C222D),
        title: const Text('Edit Note Content', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: contentController,
          maxLines: 10,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter updated content...',
            hintStyle: TextStyle(color: Colors.white38),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await ref.read(notesProvider.notifier).updateNoteContent(note.id, contentController.text);
              if (context.mounted) {
                Navigator.pop(ctx);
                // We navigate back to refresh the parent list/view
                Navigator.pop(context); 
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Note updated successfully!'), backgroundColor: Color(0xFF00BFA5)),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFBC13FE), foregroundColor: Colors.white),
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _requestCollaboration(BuildContext context, WidgetRef ref) async {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C222D),
        title: const Text('Request Collaboration', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: reasonController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Why do you want to collaborate?',
            labelStyle: TextStyle(color: Colors.white70),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await ref.read(collaborationProvider.notifier).requestContribution(note.id, reasonController.text);
              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Request sent successfully!'), backgroundColor: Color(0xFF00BFA5)),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BFA5), foregroundColor: Colors.black),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved': return const Color(0xFF00BFA5);
      case 'pending': return Colors.orangeAccent;
      case 'rejected': return Colors.redAccent;
      default: return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final isOwner = note.uploaderId == currentUserId;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E12),
      appBar: AppBar(
        title: const Text('Note Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined, color: Color(0xFF00BFA5)),
            onPressed: () => _exportAsText(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            Text(note.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16, color: Color(0xFF00BFA5)),
                const SizedBox(width: 6),
                Text(note.uploaderName, style: const TextStyle(color: Color(0xFF8B949E), fontSize: 14)),
                const SizedBox(width: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(note.status).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    note.status.toUpperCase(),
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _getStatusColor(note.status)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Metadata chips
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: const Icon(Icons.school, size: 16, color: Color(0xFF00BFA5)),
                  label: Text('Semester ${note.semester}'),
                  backgroundColor: const Color(0xFF1C222D),
                  side: const BorderSide(color: Color(0xFF30363D)),
                ),
                Chip(
                  avatar: const Icon(Icons.book, size: 16, color: Color(0xFF00BFA5)),
                  label: Text(note.course),
                  backgroundColor: const Color(0xFF1C222D),
                  side: const BorderSide(color: Color(0xFF30363D)),
                ),
              ],
            ),

            const Divider(height: 48, color: Color(0xFF30363D)),

            // Content
            const Text('Content', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1C222D),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF30363D)),
              ),
              child: Text(
                note.content,
                style: const TextStyle(fontSize: 16, height: 1.6, color: Color(0xFFE6EDF3)),
              ),
            ),
            
            if (note.contentUrl != null) ...[
              const SizedBox(height: 32),
              const Text('Attachment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00BFA5))),
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  // In a real app, use url_launcher
                  debugPrint("Opening file: ${note.contentUrl}");
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00BFA5).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF00BFA5).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.insert_drive_file, color: Color(0xFF00BFA5)),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'View Attached Resource',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Icon(Icons.open_in_new, color: Colors.white54, size: 16),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 40),
            
            const SizedBox(height: 40),
            
            if (isOwner || ref.watch(collaborationProvider).acceptedNoteIds.contains(note.id))
              ElevatedButton.icon(
                onPressed: () => _showEditDialog(context, ref),
                icon: const Icon(Icons.edit),
                label: const Text('Edit Note'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBC13FE),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: () => _requestCollaboration(context, ref),
                icon: const Icon(Icons.group_add),
                label: const Text('Request Collaboration'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BFA5),
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
