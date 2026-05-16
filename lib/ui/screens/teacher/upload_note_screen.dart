import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../providers/notes_provider.dart';
import '../../../core/constants/course_constants.dart';

class UploadNoteScreen extends ConsumerStatefulWidget {
  const UploadNoteScreen({super.key});

  @override
  ConsumerState<UploadNoteScreen> createState() => _UploadNoteScreenState();
}

class _UploadNoteScreenState extends ConsumerState<UploadNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedSemester = '1';
  String? _selectedCourse;
  PlatformFile? _pickedFile;

  @override
  void initState() {
    super.initState();
    _selectedCourse = semesterCourses[_selectedSemester]!.first;
  }

  void _upload() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref.read(notesProvider.notifier).uploadNote(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        course: _selectedCourse!,
        semester: _selectedSemester,
        fileBytes: _pickedFile?.bytes,
        fileName: _pickedFile?.name,
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note uploaded successfully!'),
          backgroundColor: Color(0xFF00BFA5),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: ${e.toString().replaceAll("Exception: ", "")}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(notesProvider).isLoading;
    final courses = semesterCourses[_selectedSemester] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E11),
      appBar: AppBar(
        title: const Text('Upload Note', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Title',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Content',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                maxLines: 5,
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Content is required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedSemester,
                dropdownColor: const Color(0xFF30363D),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Semester',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                items: semesterCourses.keys
                    .map((s) => DropdownMenuItem(value: s, child: Text('Semester $s')))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedSemester = val!;
                    _selectedCourse = semesterCourses[_selectedSemester]!.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCourse,
                dropdownColor: const Color(0xFF30363D),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Course',
                  prefixIcon: Icon(Icons.school_outlined),
                ),
                items: courses
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedCourse = val),
                validator: (v) => v == null ? 'Course is required' : null,
              ),
              const SizedBox(height: 24),
              InkWell(
                onTap: () async {
                  final result = await FilePicker.pickFiles(
                    type: FileType.any, 
                    allowMultiple: false,
                    withData: true,
                  );
                  if (result != null) {
                    setState(() => _pickedFile = result.files.first);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF00BFA5).withValues(alpha: 0.5)),
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFF00BFA5).withValues(alpha: 0.05),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.attach_file, color: Color(0xFF00BFA5)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _pickedFile?.name ?? 'Attach File (PDF, Image, DOCX)',
                          style: TextStyle(color: _pickedFile != null ? Colors.white : Colors.white54),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF00BFA5)))
                  : ElevatedButton(
                      onPressed: _upload,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BFA5),
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Upload Note',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

