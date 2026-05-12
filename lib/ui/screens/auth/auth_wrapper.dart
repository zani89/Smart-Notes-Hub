import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';
import '../student/student_dashboard.dart';
import '../teacher/teacher_dashboard.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (authProvider.isAuthenticated) {
      if (authProvider.currentUser?.isTeacher == true) {
        return const TeacherDashboard();
      } else {
        return const StudentDashboard();
      }
    }

    return const LoginScreen();
  }
}
