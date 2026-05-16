import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/collaboration_provider.dart';
import '../../../providers/notes_provider.dart';
import '../../../models/collaboration_model.dart';
import '../note_details_screen.dart';
import 'package:intl/intl.dart';

class CollabRequestsScreen extends ConsumerWidget {
  const CollabRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collabState = ref.watch(collaborationProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E11),
      appBar: AppBar(
        title: const Text('Collaboration Requests', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1C222D),
        elevation: 0,
      ),
      body: collabState.isLoading && collabState.requests.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00BFA5)))
          : collabState.requests.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () => ref.read(collaborationProvider.notifier).fetchRequests(),
                  color: const Color(0xFF00BFA5),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: collabState.requests.length,
                    itemBuilder: (context, index) {
                      final req = collabState.requests[index];
                      return _buildRequestCard(context, ref, req);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.handshake_outlined, size: 80, color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 20),
          const Text('No collaboration requests yet', style: TextStyle(color: Colors.white54, fontSize: 18)),
          const SizedBox(height: 10),
          const Text('Request to edit notes to see them here.', style: TextStyle(color: Colors.white38, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, WidgetRef ref, ContributionRequestModel req) {
    Color statusColor;
    IconData statusIcon;

    switch (req.status) {
      case 'accepted':
        statusColor = const Color(0xFF00BFA5);
        statusIcon = Icons.check_circle_outline;
        break;
      case 'rejected':
      case 'denied':
        statusColor = Colors.redAccent;
        statusIcon = Icons.cancel_outlined;
        break;
      default:
        statusColor = Colors.orangeAccent;
        statusIcon = Icons.hourglass_empty;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C222D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(req.noteTitle ?? 'Note Request', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(req.noteCourse ?? 'General', style: TextStyle(color: statusColor.withValues(alpha: 0.7), fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 14),
                    const SizedBox(width: 6),
                    Text(req.status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          if (req.reason != null && req.reason!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Reason:', style: TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 4),
            Text(req.reason!, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          ],
          const SizedBox(height: 16),
          const Divider(color: Colors.white10),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMM dd, yyyy • HH:mm').format(req.createdAt),
                style: const TextStyle(color: Colors.white24, fontSize: 12),
              ),
              if (req.status == 'accepted')
                ElevatedButton.icon(
                  onPressed: () {
                    // Find the note and navigate
                    final note = ref.read(notesProvider).notes.firstWhere((n) => n.id == req.noteId);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => NoteDetailsScreen(note: note)),
                    );
                  },
                  icon: const Icon(Icons.edit, size: 14),
                  label: const Text('Edit Note', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBC13FE),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    minimumSize: const Size(0, 32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                )
              else if (req.status == 'accepted')
                const Text('Authorized to edit', style: TextStyle(color: Color(0xFF00BFA5), fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          if (req.handledByName != null) ...[
            const SizedBox(height: 8),
            Text(
              'Handled by: ${req.handledByName}',
              style: TextStyle(color: statusColor.withValues(alpha: 0.5), fontSize: 11, fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }
}
