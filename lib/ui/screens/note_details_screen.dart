import 'package:flutter/material.dart';
import '../../../models/note_model.dart';
import 'package:url_launcher/url_launcher.dart';

class NoteDetailsScreen extends StatelessWidget {
  final NoteModel note;

  const NoteDetailsScreen({super.key, required this.note});

  void _exportAsText(BuildContext context) {
    final text = 'Title: ${note.title}\nAuthor: ${note.authorName}\nDescription: ${note.description}\nCategory: ${note.category}\nURL: ${note.contentUrl}';
    debugPrint("Exporting Note: $text");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Note exported as Text')),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            // Preview Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 60),
              decoration: BoxDecoration(
                color: const Color(0xFF1C222D),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF30363D)),
              ),
              child: const Column(
                children: [
                  Icon(Icons.picture_as_pdf, size: 100, color: Color(0xFF00BFA5)),
                  SizedBox(height: 16),
                  Text('PDF DOCUMENT', style: TextStyle(color: Color(0xFF8B949E), fontWeight: FontWeight.bold, letterSpacing: 2)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Header Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(note.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 16, color: Color(0xFF00BFA5)),
                          const SizedBox(width: 6),
                          Text(note.authorName, style: const TextStyle(color: Color(0xFF8B949E), fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00BFA5).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.visibility, size: 14, color: Color(0xFF00BFA5)),
                      const SizedBox(width: 6),
                      Text(note.viewCount.toString(), style: const TextStyle(color: Color(0xFF00BFA5), fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            
            const Divider(height: 48, color: Color(0xFF30363D)),
            
            const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            const SizedBox(height: 12),
            Text(
              note.description ?? 'No description provided for this note.',
              style: const TextStyle(fontSize: 16, height: 1.6, color: Color(0xFFE6EDF3)),
            ),
            
            const SizedBox(height: 32),
            const Text('Tags', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: note.tags.map((t) => Chip(
                label: Text('#$t'),
                backgroundColor: const Color(0xFF1C222D),
                side: const BorderSide(color: Color(0xFF30363D)),
              )).toList(),
            ),
            
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () async {
                final url = Uri.parse(note.contentUrl);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                backgroundColor: const Color(0xFF00BFA5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.open_in_new, color: Colors.black),
                  SizedBox(width: 12),
                  Text('Open Source Document', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
