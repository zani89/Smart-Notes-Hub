import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/auth_provider.dart';
import 'settings_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _semesterController;
  late TextEditingController _emailController;
  late TextEditingController _uniIdController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _semesterController = TextEditingController(text: user?.semester ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _uniIdController = TextEditingController(text: user?.uniId ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _semesterController.dispose();
    _emailController.dispose();
    _uniIdController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final result = await FilePicker.pickFiles(type: FileType.image, allowMultiple: false);
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
          await ref.read(authProvider.notifier).updateProfileImage(fileName, file.bytes!);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    }
  }

  Future<void> _saveProfile() async {
    try {
      await ref.read(authProvider.notifier).updateProfile(
            name: _nameController.text.trim(),
            semester: _semesterController.text.trim(),
            email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
            uniId: _uniIdController.text.trim().isEmpty ? null : _uniIdController.text.trim(),
          );
      setState(() => _isEditing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Color(0xFF00BFA5)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (previous, next) {
      if (next.user != null && previous?.user != next.user && !_isEditing) {
        _nameController.text = next.user!.name;
        _semesterController.text = next.user!.semester;
        _emailController.text = next.user!.email ?? '';
        _uniIdController.text = next.user!.uniId ?? '';
      }
    });

    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0B0E11),
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('User not found', style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E11),
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1C222D),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white70),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
          IconButton(
            icon: Icon(_isEditing ? Icons.save_outlined : Icons.edit_outlined, color: const Color(0xFF00BFA5)),
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: const Color(0xFF1C222D),
                  backgroundImage: user.profileImageUrl != null ? NetworkImage(user.profileImageUrl!) : null,
                  child: user.profileImageUrl == null ? const Icon(Icons.person, size: 60, color: Colors.white) : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickAndUploadImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Color(0xFF00BFA5), shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, size: 20, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          if (_isEditing) ...[
            _buildEditField('Full Name', _nameController, Icons.person_outline),
            const SizedBox(height: 16),
            _buildEditField('Email', _emailController, Icons.email_outlined),
            const SizedBox(height: 16),
            _buildEditField('University ID', _uniIdController, Icons.badge_outlined),
            const SizedBox(height: 16),
            _buildEditField('Semester', _semesterController, Icons.school_outlined),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: authState.isLoading ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BFA5),
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: authState.isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () => setState(() => _isEditing = false),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
          ] else ...[
            _buildProfileItem(Icons.person_outline, 'Full Name', user.name),
            const SizedBox(height: 16),
            _buildProfileItem(Icons.email_outlined, 'Email', user.email ?? 'Not set'),
            const SizedBox(height: 16),
            _buildProfileItem(Icons.badge_outlined, 'University ID', user.uniId ?? 'Not set'),
            const SizedBox(height: 16),
            _buildProfileItem(Icons.school_outlined, 'Semester', user.semester),
            const SizedBox(height: 16),
            _buildProfileItem(Icons.admin_panel_settings_outlined, 'Role', user.role.toUpperCase(), color: const Color(0xFFBC13FE)),
          ],
          
          const SizedBox(height: 40),
          const Divider(color: Colors.white12),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            onTap: () => ref.read(authProvider.notifier).signOut(),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ],
      ),
    );
  }

  Widget _buildEditField(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF00BFA5), size: 20),
            filled: true,
            fillColor: const Color(0xFF1C222D),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF00BFA5), width: 1)),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileItem(IconData icon, String label, String value, {Color? color}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C222D),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: color ?? Colors.white70, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.white54)),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(fontSize: 16, color: color ?? Colors.white, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
