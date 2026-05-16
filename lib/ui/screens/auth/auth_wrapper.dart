import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';
import 'login_screen.dart';
import '../student/student_dashboard.dart';
import '../teacher/teacher_dashboard.dart';
import '../admin/admin_dashboard.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState.isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFF00BFA5)),
              const SizedBox(height: 24),
              const Text('Securing Connection...', style: TextStyle(color: Color(0xFF8B949E))),
              if (authState.error != null) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    authState.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                  ),
                ),
                TextButton(
                  onPressed: () => ref.read(authProvider.notifier).signOut(),
                  child: const Text('Back to Login', style: TextStyle(color: Color(0xFF00BFA5))),
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (authState.user != null) {
      final role = authState.user!.role;
      
      switch (role) {
        case 'admin':
          return const AdminDashboard();
        case 'teacher':
          return const TeacherDashboard();
        case 'student':
        default:
          return const StudentDashboard();
      }
    }

    return const LoginScreen();
  }
}
