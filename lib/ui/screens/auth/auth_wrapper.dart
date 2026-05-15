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
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF00BFA5)),
              SizedBox(height: 24),
              Text('Securing Connection...', style: TextStyle(color: Color(0xFF8B949E))),
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
