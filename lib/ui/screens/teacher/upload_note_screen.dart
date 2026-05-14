import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart' as fp;
import '../../../providers/notes_provider.dart';

class UploadNoteScreen extends StatefulWidget {
  const UploadNoteScreen({super.key});

  @override
  State<UploadNoteScreen> createState() => _UploadNoteScreenState();
}

class _UploadNoteScreenState extends State<UploadNoteScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _categoryController = TextEditingController();
  final _tagController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<String> _tags = [];
  bool _isShared = false;
  String? _selectedFilePath;
  String? _selectedFileName;

  void _addTag() {
    if (_tagController.text.isNotEmpty) {
      setState(() {
        _tags.add(_tagController.text.trim());
        _tagController.clear();
      });
    }
  }

  void _pickFile() async {
    try {
      // Using dynamic to bypass analyzer discrepancy in this environment
      final result = await (fp.FilePicker as dynamic).platform.pickFiles(
        type: fp.FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'png', 'jpg'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFilePath = result.files.single.path;
          _selectedFileName = result.files.single.name;
        });
      }
    } catch (e) {
      debugPrint("File picker error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    }
  }

  void _upload() async {
    if (_formKey.currentState!.validate() && _selectedFileName != null) {
      final notesProvider = Provider.of<NotesProvider>(context, listen: false);
      
      try {
        await notesProvider.uploadNote(
          title: _titleController.text,
          description: _descController.text,
          category: _categoryController.text,
          tags: _tags,
          isShared: _isShared,
          filePath: _selectedFilePath ?? '',
          fileName: _selectedFileName!,
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
    } else if (_selectedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please attach a file first')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<NotesProvider>(context).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Upload Note')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category (Math, Science, etc.)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _tagController,
                      decoration: const InputDecoration(labelText: 'Add Tag', border: OutlineInputBorder()),
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
                children: _tags.map((tag) => Chip(
                  label: Text(tag),
                  onDeleted: () => setState(() => _tags.remove(tag)),
                )).toList(),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Share with entire school?'),
                subtitle: const Text('Makes the note visible in the Shared section once approved.'),
                value: _isShared,
                onChanged: (val) => setState(() => _isShared = val),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.attach_file, color: Colors.black),
                label: Text(_selectedFileName ?? 'Attach PDF or DOCX', style: const TextStyle(color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _selectedFileName != null ? Colors.green.shade50 : const Color(0xFF1C222D),
                  side: const BorderSide(color: Color(0xFF30363D)),
                ),
              ),
              const SizedBox(height: 40),
              isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF00BFA5)))
                : ElevatedButton(
                    onPressed: _upload,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: const Color(0xFF00BFA5),
                    ),
                    child: const Text('Upload Note', style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
