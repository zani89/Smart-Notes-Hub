import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import 'login_screen.dart';
import '../student/student_dashboard.dart';
import '../teacher/teacher_dashboard.dart';
import '../admin/admin_dashboard.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // 1. If we are doing any async work (Initializing or Fetching profile)
    if (authProvider.isLoading || !authProvider.isInitialized) {
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

    // 2. If the user is authenticated in Supabase
    if (authProvider.isAuthenticated) {
      // 3. BUT we don't have the profile data yet (Waiting for database)
      if (!authProvider.hasProfile) {
        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Color(0xFF00BFA5)),
                SizedBox(height: 24),
                Text('Fetching Profile...', style: TextStyle(color: Color(0xFF8B949E))),
              ],
            ),
          ),
        );
      }

      // 4. We have both Session and Profile - Show the correct dashboard
      final role = authProvider.currentUser?.role;
      
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

    // 5. Not authenticated at all
    return const LoginScreen();
  }
}
