import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../providers/notes_provider.dart';
import '../../../core/constants/course_constants.dart';
import '../../widgets/note_card.dart';

class WorkspaceScreen extends ConsumerStatefulWidget {
  const WorkspaceScreen({super.key});

  @override
  ConsumerState<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends ConsumerState<WorkspaceScreen> {
  final _searchController = TextEditingController();

  void _showAddNoteDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String selectedSemester = '1';
    String? selectedCourse;
    PlatformFile? pickedFile;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final courses = semesterCourses[selectedSemester] ?? [];
          if (selectedCourse == null || !courses.contains(selectedCourse)) {
            selectedCourse = courses.isNotEmpty ? courses.first : null;
          }

          return AlertDialog(
            backgroundColor: const Color(0xFF1C222D),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Add New Note', style: TextStyle(color: Colors.white)),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        labelStyle: TextStyle(color: Colors.white70),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: contentController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        labelStyle: TextStyle(color: Colors.white70),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Description is required' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedSemester,
                      dropdownColor: const Color(0xFF30363D),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Semester'),
                      items: semesterCourses.keys
                          .map((s) => DropdownMenuItem(value: s, child: Text('Semester $s')))
                          .toList(),
                      onChanged: (val) {
                        setDialogState(() {
                          selectedSemester = val!;
                          selectedCourse = semesterCourses[selectedSemester]!.first;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCourse,
                      dropdownColor: const Color(0xFF30363D),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Course'),
                      items: courses
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) => setDialogState(() => selectedCourse = val),
                      validator: (v) => v == null ? 'Course is required' : null,
                    ),
                    const SizedBox(height: 20),
                  InkWell(
                    onTap: () async {
                      final result = await FilePicker.pickFiles(type: FileType.any, allowMultiple: false);
                      if (result != null) {
                        setDialogState(() => pickedFile = result.files.first);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF00BFA5).withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(10),
                        color: const Color(0xFF00BFA5).withValues(alpha: 0.05),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.attach_file, color: const Color(0xFF00BFA5), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              pickedFile?.name ?? 'Attach File (PDF, DOCX, Image)',
                              style: TextStyle(color: pickedFile != null ? Colors.white : Colors.white54, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uploading note...')));

                try {
                  await ref.read(notesProvider.notifier).uploadNote(
                    title: titleController.text.trim(),
                    content: contentController.text.trim(),
                    course: selectedCourse!,
                    semester: selectedSemester,
                    fileBytes: pickedFile?.bytes,
                    fileName: pickedFile?.name,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Note uploaded successfully!'), backgroundColor: Color(0xFF00BFA5)),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to add note: ${e.toString()}'), backgroundColor: Colors.redAccent),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BFA5)),
              child: const Text('Submit', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final notesState = ref.watch(notesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        heroTag: "notesHubFab",
        onPressed: _showAddNoteDialog,
        backgroundColor: const Color(0xFF00BFA5),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notes Hub', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => ref.read(notesProvider.notifier).setSearchQuery(val),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search title...',
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                      prefixIcon: const Icon(Icons.search, color: Colors.white38),
                      filled: true,
                      fillColor: const Color(0xFF1C222D),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildFilterButton(),
              ],
            ),
            const SizedBox(height: 12),
            _buildFilterChips(notesState),
            const SizedBox(height: 12),
            Expanded(
              child: notesState.isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF00BFA5)))
                  : RefreshIndicator(
                      onRefresh: () => ref.read(notesProvider.notifier).fetchNotes(),
                      color: const Color(0xFF00BFA5),
                      backgroundColor: const Color(0xFF1C222D),
                      child: notesState.filteredNotes.isEmpty
                          ? const Center(child: Text('No notes found.', style: TextStyle(color: Colors.white54)))
                          : ListView.builder(
                              itemCount: notesState.filteredNotes.length,
                              itemBuilder: (context, index) {
                                return NoteCard(note: notesState.filteredNotes[index]);
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C222D),
        borderRadius: BorderRadius.circular(15),
      ),
      child: IconButton(
        icon: const Icon(Icons.filter_list, color: Color(0xFF00BFA5)),
        onPressed: _showFilterDialog,
      ),
    );
  }

  Widget _buildFilterChips(NotesState state) {
    if (state.selectedSemester == null && state.selectedCategory == null) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      children: [
        if (state.selectedSemester != null)
          Chip(
            label: Text('Semester ${state.selectedSemester}', style: const TextStyle(color: Colors.black, fontSize: 12)),
            backgroundColor: const Color(0xFF00BFA5),
            onDeleted: () => ref.read(notesProvider.notifier).setSemester(null),
            deleteIconColor: Colors.black,
          ),
        if (state.selectedCategory != null)
          Chip(
            label: Text(state.selectedCategory!, style: const TextStyle(color: Colors.black, fontSize: 12)),
            backgroundColor: const Color(0xFFBC13FE),
            onDeleted: () => ref.read(notesProvider.notifier).setCategory(null),
            deleteIconColor: Colors.black,
          ),
      ],
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C222D),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filter Notes', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: ref.watch(notesProvider).selectedSemester,
              dropdownColor: const Color(0xFF30363D),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Semester',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
              ),
              items: ['1', '2', '3', '4', '5', '6', '7', '8'].map((s) {
                return DropdownMenuItem(value: s, child: Text('Semester $s'));
              }).toList(),
              onChanged: (val) => ref.read(notesProvider.notifier).setSemester(val),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: ref.watch(notesProvider).selectedCategory,
              dropdownColor: const Color(0xFF30363D),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Course',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
              ),
              items: semesterCourses[ref.watch(notesProvider).selectedSemester ?? '1']!.map((c) {
                return DropdownMenuItem(value: c, child: Text(c));
              }).toList(),
              onChanged: (val) => ref.read(notesProvider.notifier).setCategory(val),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                ref.read(notesProvider.notifier).setSemester(null);
                ref.read(notesProvider.notifier).setCategory(null);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                foregroundColor: Colors.redAccent,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Clear All Filters'),
            ),
          ],
        ),
      ),
    );
  }
}
