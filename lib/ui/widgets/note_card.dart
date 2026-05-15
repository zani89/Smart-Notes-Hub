import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/note_model.dart';
import '../../../providers/notes_provider.dart';
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

  void _openNote(BuildContext context, WidgetRef ref) async {
    ref.read(notesProvider.notifier).addToRecents(note.id);
    ref.read(notesProvider.notifier).incrementViewCount(note.id);

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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00BFA5).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.picture_as_pdf, color: Color(0xFF00BFA5), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                note.title,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                note.category ?? 'Uncategorized',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF8B949E)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? const Color(0xFF00BFA5) : const Color(0xFF8B949E),
                          size: 20,
                        ),
                        onPressed: () => ref.read(notesProvider.notifier).toggleFavorite(note.id),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetric('Author', note.authorName),
                      _buildMetric('Semester', note.semester ?? 'N/A'),
                      _buildMetric('Views', note.viewCount.toString()),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetric('Status', note.status.toUpperCase(), color: _getStatusColor(note.status)),
                      _buildMetric('Tags', note.tags.isEmpty ? 'None' : '#${note.tags[0]}'),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved': return const Color(0xFF00BFA5);
      case 'pending': return Colors.orangeAccent;
      case 'rejected': return Colors.redAccent;
      default: return Colors.white;
    }
  }
}
