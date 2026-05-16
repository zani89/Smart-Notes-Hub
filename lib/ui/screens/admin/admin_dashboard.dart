import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/admin_provider.dart';
import '../../../providers/university_provider.dart';
import '../profile_screen.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E11),
      appBar: AppBar(
        title: const Text('Admin Portal', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildUserManagement(adminState),
          _buildSystemAnalytics(adminState),
          _buildModeration(adminState),
          _buildSecurityAudit(),
          _buildGlobalConfig(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1C222D),
        selectedItemColor: const Color(0xFFBC13FE),
        unselectedItemColor: Colors.white38,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people_alt_outlined), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.gavel_outlined), label: 'Mod'),
          BottomNavigationBarItem(icon: Icon(Icons.security_outlined), label: 'Audit'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_suggest_outlined), label: 'Config'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C222D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: Colors.white54, fontSize: 13)),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          ]),
        ],
      ),
    );
  }

  // --- 1. USER MANAGEMENT ---
  Widget _buildUserManagement(AdminState admin) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('User Management', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: _statCard('Students', admin.studentCount.toString(), Icons.school, const Color(0xFF00BFA5))),
            const SizedBox(width: 12),
            Expanded(child: _statCard('Teachers', admin.teacherCount.toString(), Icons.person, const Color(0xFFBC13FE))),
          ]),
          const SizedBox(height: 20),
          Expanded(
            child: admin.isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFBC13FE)))
                : admin.allUsers.isEmpty
                    ? const Center(child: Text('No users found', style: TextStyle(color: Colors.white38)))
                    : ListView.builder(
                        itemCount: admin.allUsers.length,
                        itemBuilder: (context, index) {
                          final user = admin.allUsers[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1C222D),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFF30363D)),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: _roleColor(user.role).withValues(alpha: 0.2),
                                  child: Icon(Icons.person, color: _roleColor(user.role), size: 20),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(user.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    Text('${user.email} • ${user.role}', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                                  ]),
                                ),
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert, color: Colors.white38),
                                  color: const Color(0xFF30363D),
                                  onSelected: (val) {
                                    if (val == 'delete') {
                                      ref.read(adminProvider.notifier).deleteUser(user.id);
                                    } else {
                                      ref.read(adminProvider.notifier).updateUserRole(user.id, val);
                                    }
                                  },
                                  itemBuilder: (_) => [
                                    const PopupMenuItem(value: 'student', child: Text('Set Student', style: TextStyle(color: Colors.white))),
                                    const PopupMenuItem(value: 'teacher', child: Text('Set Teacher', style: TextStyle(color: Colors.white))),
                                    const PopupMenuItem(value: 'admin', child: Text('Set Admin', style: TextStyle(color: Colors.white))),
                                    const PopupMenuItem(value: 'delete', child: Text('Delete User', style: TextStyle(color: Colors.redAccent))),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'admin': return const Color(0xFFBC13FE);
      case 'teacher': return Colors.blueAccent;
      default: return const Color(0xFF00BFA5);
    }
  }

  // --- 2. SYSTEM ANALYTICS ---
  Widget _buildSystemAnalytics(AdminState admin) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('System Analytics', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          _statCard('Total Users', admin.allUsers.length.toString(), Icons.people, const Color(0xFF00BFA5)),
          const SizedBox(height: 16),
          _statCard('Total Notes', admin.totalNotes.toString(), Icons.description, const Color(0xFFBC13FE)),
          const SizedBox(height: 16),
          _statCard('Total Assignments', admin.totalAssignments.toString(), Icons.assignment, Colors.blueAccent),
          const SizedBox(height: 16),
          _statCard('Admins', admin.adminCount.toString(), Icons.admin_panel_settings, Colors.orangeAccent),
        ],
      ),
    );
  }

  // --- 3. CONTENT MODERATION ---
  Widget _buildModeration(AdminState admin) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Content Moderation', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.refresh, color: Color(0xFFBC13FE)),
                onPressed: () => ref.read(adminProvider.notifier).fetchAllNotes(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: admin.allNotes.isEmpty
                ? Center(
                    child: ElevatedButton(
                      onPressed: () => ref.read(adminProvider.notifier).fetchAllNotes(),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFBC13FE)),
                      child: const Text('Load All Notes', style: TextStyle(color: Colors.white)),
                    ),
                  )
                : ListView.builder(
                    itemCount: admin.allNotes.length,
                    itemBuilder: (context, index) {
                      final note = admin.allNotes[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C222D),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF30363D)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _statusColor(note.status).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(note.status.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _statusColor(note.status))),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(note.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                Text('${note.course} • Sem ${note.semester}', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                              ]),
                            ),
                            if (note.status == 'pending') ...[
                              IconButton(
                                icon: const Icon(Icons.check_circle, color: Color(0xFF00BFA5), size: 20),
                                onPressed: () => ref.read(adminProvider.notifier).updateNoteStatus(note.id, 'approved'),
                              ),
                              IconButton(
                                icon: const Icon(Icons.cancel, color: Colors.redAccent, size: 20),
                                onPressed: () => ref.read(adminProvider.notifier).updateNoteStatus(note.id, 'rejected'),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved': return const Color(0xFF00BFA5);
      case 'pending': return Colors.orangeAccent;
      case 'rejected': return Colors.redAccent;
      default: return Colors.white;
    }
  }

  // --- 4. EVENTS & ANNOUNCEMENTS ---
  Widget _buildEventsAnnouncements() {
    final uniState = ref.watch(universityProvider);
    final authState = ref.watch(authProvider);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Announcements', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Color(0xFFBC13FE), size: 32),
                onPressed: () => _showAnnouncementDialog(authState.user?.id ?? ''),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: uniState.notifications.isEmpty
                ? const Center(child: Text('No announcements yet', style: TextStyle(color: Colors.white38)))
                : ListView.builder(
                    itemCount: uniState.notifications.length,
                    itemBuilder: (context, index) {
                      final n = uniState.notifications[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: const Color(0xFF1C222D), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF30363D))),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(n.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(n.message, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                        ]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showAnnouncementDialog(String userId) {
    final titleCtrl = TextEditingController();
    final messageCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C222D),
        title: const Text('New Announcement', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Title', labelStyle: TextStyle(color: Colors.white70))),
            TextField(controller: messageCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Message', labelStyle: TextStyle(color: Colors.white70)), maxLines: 3),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (titleCtrl.text.trim().isEmpty) return;
              await ref.read(universityProvider.notifier).createNotification(titleCtrl.text, messageCtrl.text, null, userId);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFBC13FE)),
            child: const Text('Post', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityAudit() {
    final admin = ref.watch(adminProvider);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Security Audit', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.refresh, color: Color(0xFFBC13FE)),
                onPressed: () => ref.read(adminProvider.notifier).fetchAuditLogs(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Live feed of system administrative actions', style: TextStyle(color: Colors.white54, fontSize: 14)),
          const SizedBox(height: 20),
          Expanded(
            child: admin.auditLogs.isEmpty
                ? const Center(child: Text('No audit logs recorded yet.', style: TextStyle(color: Colors.white38)))
                : ListView.builder(
                    itemCount: admin.auditLogs.length,
                    itemBuilder: (context, index) {
                      final log = admin.auditLogs[index];
                      final time = DateTime.parse(log['created_at']).toLocal();
                      final adminName = log['admin'] != null ? log['admin']['name'] : 'System';
                      final actionType = log['action'];
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C222D),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF30363D)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _auditColor(actionType).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(actionType, style: TextStyle(color: _auditColor(actionType), fontWeight: FontWeight.bold, fontSize: 11)),
                                ),
                                Text('${time.day}/${time.month} ${time.hour}:${time.minute.toString().padLeft(2, "0")}', 
                                  style: const TextStyle(color: Colors.white38, fontSize: 11)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(log['details'] ?? 'No details', style: const TextStyle(color: Colors.white, fontSize: 15)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.admin_panel_settings, color: Colors.white38, size: 14),
                                const SizedBox(width: 4),
                                Text('By: $adminName', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _auditColor(String action) {
    if (action.contains('DELETE')) return Colors.redAccent;
    if (action.contains('UPDATE_ROLE')) return Colors.orangeAccent;
    if (action.contains('MODERATE')) return const Color(0xFF00BFA5);
    if (action.contains('CONFIG')) return Colors.blueAccent;
    return const Color(0xFFBC13FE);
  }

  Widget _buildGlobalConfig() {
    final admin = ref.watch(adminProvider);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Global Config', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('System-wide settings and campus management', style: TextStyle(color: Colors.white54, fontSize: 14)),
          const SizedBox(height: 30),
          _buildConfigItem(
            title: 'Subject Directory',
            subtitle: 'Manage available courses and categories',
            trailing: const Icon(Icons.chevron_right, color: Colors.white38),
            onTap: () => _showSubjectDirectory(),
          ),
          const SizedBox(height: 12),
          _buildConfigItem(
            title: 'Maintenance Mode',
            subtitle: 'Restrict access to the portal during updates',
            trailing: Switch(
              value: admin.isMaintenanceMode,
              onChanged: (v) => ref.read(adminProvider.notifier).toggleMaintenanceMode(v),
              activeColor: const Color(0xFFBC13FE),
            ),
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _buildConfigItem(
            title: 'Backup & Restore',
            subtitle: 'Export or import system data snapshots',
            trailing: const Icon(Icons.cloud_upload_outlined, color: Colors.white38),
            onTap: () async {
              final result = await ref.read(adminProvider.notifier).exportData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Backup successful! Data logged to Audit.')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showSubjectDirectory() {
    final nameCtrl = TextEditingController();
    int selectedSem = 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C222D),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final admin = ref.watch(adminProvider);
          return Container(
            padding: const EdgeInsets.all(25),
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Subject Directory', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: nameCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: 'New Subject Name', labelStyle: TextStyle(color: Colors.white54)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    DropdownButton<int>(
                      value: selectedSem,
                      dropdownColor: const Color(0xFF30363D),
                      items: List.generate(8, (i) => DropdownMenuItem(value: i + 1, child: Text('Sem ${i + 1}'))),
                      onChanged: (v) => setModalState(() => selectedSem = v!),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Color(0xFFBC13FE)),
                      onPressed: () {
                        if (nameCtrl.text.isNotEmpty) {
                          ref.read(adminProvider.notifier).addSubject(nameCtrl.text, selectedSem);
                          nameCtrl.clear();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: admin.subjects.length,
                    itemBuilder: (context, index) {
                      final s = admin.subjects[index];
                      return ListTile(
                        title: Text(s['name'], style: const TextStyle(color: Colors.white)),
                        subtitle: Text('Semester ${s['semester']}', style: const TextStyle(color: Colors.white38)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                          onPressed: () => ref.read(adminProvider.notifier).deleteSubject(s['id'], s['name']),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildConfigItem({required String title, required String subtitle, required Widget trailing, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1C222D),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF30363D)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

