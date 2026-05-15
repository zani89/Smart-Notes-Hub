import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/notes_provider.dart';

class UploadNoteScreen extends ConsumerStatefulWidget {
  const UploadNoteScreen({super.key});

  @override
  ConsumerState<UploadNoteScreen> createState() => _UploadNoteScreenState();
}

class _UploadNoteScreenState extends ConsumerState<UploadNoteScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _categoryController = TextEditingController();
  final _semesterController = TextEditingController();
  final _tagController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<String> _tags = [];
  bool _isShared = false;

  void _addTag() {
    if (_tagController.text.isNotEmpty) {
      setState(() {
        _tags.add(_tagController.text.trim());
        _tagController.clear();
      });
    }
  }

  void _upload() async {
    if (_formKey.currentState!.validate()) {
      try {
        // On web, file picking and local paths are not supported the same way.
        // We'll upload a dummy placeholder URL for now.
        await ref.read(notesProvider.notifier).uploadNote(
          title: _titleController.text,
          description: _descController.text,
          category: _categoryController.text,
          tags: _tags,
          isShared: _isShared,
          semester: _semesterController.text.trim().isEmpty
              ? null
              : _semesterController.text.trim(),
          filePath: '',
          fileName: 'note_${DateTime.now().millisecondsSinceEpoch}.pdf',
        );
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note uploaded successfully!')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(notesProvider).isLoading;

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
                decoration: const InputDecoration(
                  labelText: 'Title',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category (Math, Science, etc.)',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _semesterController,
                decoration: const InputDecoration(
                  labelText: 'Semester (e.g., 1, 2, Spring 2024)',
                  prefixIcon: Icon(Icons.school_outlined),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _tagController,
                      decoration: const InputDecoration(labelText: 'Add Tag'),
                      onFieldSubmitted: (_) => _addTag(),
                    ),
                  ),
                  IconButton(
                    onPressed: _addTag,
                    icon: const Icon(Icons.add_circle, size: 32, color: Color(0xFF00BFA5)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _tags
                    .map((tag) => Chip(
                          label: Text(tag),
                          onDeleted: () => setState(() => _tags.remove(tag)),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Share with entire school?'),
                subtitle: const Text('Makes the note visible in the Shared section once approved.'),
                value: _isShared,
                onChanged: (val) => setState(() => _isShared = val),
              ),
              const SizedBox(height: 40),
              isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF00BFA5)))
                  : ElevatedButton(
                      onPressed: _upload,
                      child: const Text('Upload Note',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
