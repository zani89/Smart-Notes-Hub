import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../providers/notes_provider.dart';
import '../../widgets/note_card.dart';

class WorkspaceScreen extends ConsumerStatefulWidget {
  const WorkspaceScreen({super.key});

  @override
  ConsumerState<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends ConsumerState<WorkspaceScreen> {
  final _searchController = TextEditingController();

  void _uploadNote() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null && result.files.single.path != null) {
      if (!mounted) return;
      _showUploadDialog(result.files.single.path!, result.files.single.name);
    }
  }

  void _showUploadDialog(String filePath, String fileName) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String selectedSemester = 'Semester 1';
    bool isShared = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1C222D),
          title: const Text('Upload Note', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Title', labelStyle: TextStyle(color: Colors.white70)),
                ),
                TextField(
                  controller: descController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Description', labelStyle: TextStyle(color: Colors.white70)),
                ),
                DropdownButton<String>(
                  value: selectedSemester,
                  dropdownColor: const Color(0xFF30363D),
                  style: const TextStyle(color: Colors.white),
                  items: ['Semester 1', 'Semester 2', 'Semester 3'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) => setState(() => selectedSemester = val!),
                ),
                SwitchListTile(
                  title: const Text('Share with peers', style: TextStyle(color: Colors.white)),
                  value: isShared,
                  onChanged: (val) => setState(() => isShared = val),
                  activeColor: const Color(0xFF00BFA5),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                ref.read(notesProvider.notifier).uploadNote(
                  title: titleController.text,
                  description: descController.text,
                  category: 'General',
                  tags: [],
                  filePath: filePath,
                  fileName: fileName,
                  isShared: isShared,
                  semester: selectedSemester,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BFA5)),
              child: const Text('Upload', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notesState = ref.watch(notesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadNote,
        backgroundColor: const Color(0xFF00BFA5),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My Workspace', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: _searchController,
              onChanged: (val) => ref.read(notesProvider.notifier).setSearchQuery(val),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search notes...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF1C222D),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: notesState.isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF00BFA5)))
                  : notesState.filteredNotes.isEmpty
                      ? const Center(child: Text('No notes found.', style: TextStyle(color: Colors.white54)))
                      : ListView.builder(
                          itemCount: notesState.filteredNotes.length,
                          itemBuilder: (context, index) {
                            return NoteCard(note: notesState.filteredNotes[index]);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
