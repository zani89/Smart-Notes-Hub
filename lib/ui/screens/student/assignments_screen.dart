import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../providers/assignments_provider.dart';
import '../../widgets/glass_container.dart';

class AssignmentsScreen extends ConsumerWidget {
  const AssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignState = ref.watch(assignmentsProvider);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Assignments', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          if (assignState.isLoading)
            const Center(child: CircularProgressIndicator(color: Color(0xFF00BFA5)))
          else
            Expanded(
              child: ListView(
                children: [
                  const Text('Pending', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  if (assignState.pendingAssignments.isEmpty)
                    const Text('No pending assignments.', style: TextStyle(color: Colors.white54)),
                  ...assignState.pendingAssignments.map((a) => _buildAssignmentTile(
                        context,
                        ref,
                        a.id,
                        a.title,
                        'Due: ${a.dueDate.toLocal().toString().split(' ')[0]}',
                        'Pending',
                        Colors.orange,
                        canSubmit: true,
                      )),
                  const SizedBox(height: 30),
                  const Text('Submitted / Graded', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  if (assignState.submittedAssignments.isEmpty)
                    const Text('No submitted assignments.', style: TextStyle(color: Colors.white54)),
                  ...assignState.submittedAssignments.map((a) {
                    final submission = assignState.submissions.firstWhere((s) => s.assignmentId == a.id);
                    return _buildAssignmentTile(
                      context,
                      ref,
                      a.id,
                      a.title,
                      'Submitted on: ${submission.createdAt.toLocal().toString().split(' ')[0]}',
                      submission.grade != null ? 'Graded: ${submission.grade}' : 'Submitted',
                      submission.grade != null ? Colors.blue : Colors.green,
                      canSubmit: false,
                    );
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAssignmentTile(BuildContext context, WidgetRef ref, String id, String title, String subtitle, String status, Color color, {bool canSubmit = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.assignment_outlined, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
            ),
            if (canSubmit)
              IconButton(
                icon: const Icon(Icons.upload_file, color: Color(0xFF00BFA5)),
                onPressed: () => _submitAssignment(context, ref, id),
              )
            else
              Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _submitAssignment(BuildContext context, WidgetRef ref, String assignmentId) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null && result.files.single.path != null) {
      // Mocking the upload process for the file
      final mockFileUrl = 'https://mockstorage.com/submissions/${result.files.single.name}';
      
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uploading submission...')));
      
      await ref.read(assignmentsProvider.notifier).submitAssignment(assignmentId, mockFileUrl);
      
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Submitted successfully!')));
    }
  }
}
