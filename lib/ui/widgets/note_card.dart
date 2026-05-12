import 'package:flutter/material.dart';
import '../../../models/note_model.dart';
import 'package:url_launcher/url_launcher.dart';

class NoteCard extends StatelessWidget {
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

  void _openNote() async {
    final url = Uri.parse(note.contentUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      debugPrint("Could not launch ${note.contentUrl}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const Icon(Icons.picture_as_pdf, size: 40, color: Colors.redAccent),
        title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(note.description ?? 'No description'),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text(
                    note.status.toUpperCase(),
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: note.status == 'approved'
                      ? Colors.green.withOpacity(0.2)
                      : Colors.orange.withOpacity(0.2),
                ),
                const SizedBox(width: 8),
                if (note.category != null)
                  Chip(
                    label: Text(
                      note.category!,
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: isTeacher && note.status == 'pending'
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: onApprove,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: onReject,
                  ),
                ],
              )
            : IconButton(
                icon: const Icon(Icons.open_in_new),
                onPressed: _openNote,
              ),
      ),
    );
  }
}
