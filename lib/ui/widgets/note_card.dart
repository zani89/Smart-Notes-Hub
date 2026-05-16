import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/note_model.dart';
import '../../../providers/notes_provider.dart';
import '../../../providers/collaboration_provider.dart';
import '../screens/note_details_screen.dart';

class NoteCard extends ConsumerWidget {
  final NoteModel note;
  final bool isTeacher;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const NoteCard({
    super.key,
    required this.note,
    this.isTeacher = false,
    this.onApprove,
    this.onReject,
  });

  void _openNote(BuildContext context, WidgetRef ref) {
    ref.read(notesProvider.notifier).addToRecents(note.id);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteDetailsScreen(note: note)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesState = ref.watch(notesProvider);
    final isFav = notesState.isFavorite(note.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C222D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF30363D)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openNote(context, ref),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _getStatusColor(note.status).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.description_outlined, color: _getStatusColor(note.status), size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    note.title,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    note.course,
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF8B949E)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(note.status).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getStatusLabel(note.status),
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getStatusColor(note.status)),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? const Color(0xFF00BFA5) : const Color(0xFF8B949E),
                              size: 20,
                            ),
                            onPressed: () => ref.read(notesProvider.notifier).toggleFavorite(note.id),
                          ),
                          if (ref.watch(collaborationProvider).acceptedNoteIds.contains(note.id))
                            const Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Icon(Icons.edit_note, color: Color(0xFFBC13FE), size: 24),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    note.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Color(0xFFADBBC4), height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetric('Author', note.uploaderName),
                      _buildMetric('Semester', note.semester),
                      _buildMetric('Course', note.course),
                    ],
                  ),
                  if (isTeacher && note.status == 'pending')
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: onApprove,
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BFA5)),
                              child: const Text('Approve', style: TextStyle(color: Colors.black)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: onReject,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.redAccent),
                                foregroundColor: Colors.redAccent,
                              ),
                              child: const Text('Reject'),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF8B949E))),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.white,
          ),
        ),
      ],
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'approved': return 'RATING';
      case 'pending': return 'IN REVIEW';
      case 'rejected': return 'REJECTED';
      case 'requested_collab': return 'COLLAB';
      default: return status.toUpperCase();
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved': return const Color(0xFF00BFA5);
      case 'pending': return Colors.orangeAccent;
      case 'rejected': return Colors.redAccent;
      case 'requested_collab': return const Color(0xFFBC13FE);
      default: return Colors.white;
    }
  }
}
