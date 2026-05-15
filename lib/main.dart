import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/constants/supabase_constants.dart';
import 'core/theme/theme_engine.dart';
import 'ui/screens/auth/auth_wrapper.dart';
import 'models/note_model.dart';
import 'models/assignment_model.dart';
import 'models/collaboration_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(NoteModelAdapter());
  Hive.registerAdapter(AssignmentModelAdapter());
  Hive.registerAdapter(SubmissionModelAdapter());
  Hive.registerAdapter(ContributionRequestModelAdapter());
  
  await Hive.openBox<NoteModel>('notesBox');
  await Hive.openBox<AssignmentModel>('assignmentsBox');

  // Initialize Supabase
  try {
    if (SupabaseConstants.supabaseUrl != 'YOUR_SUPABASE_URL') {
      await Supabase.initialize(
        url: SupabaseConstants.supabaseUrl,
        anonKey: SupabaseConstants.supabaseAnonKey,
      );
    }
  } catch (e) {
    debugPrint("Supabase init error: $e");
  }

  runApp(
    const ProviderScope(
      child: SmartNotesApp(),
    ),
  );
}

class SmartNotesApp extends ConsumerWidget {
  const SmartNotesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // For now, defaulting to dark neon. Theme toggling will be added in Phase 2.
    return MaterialApp(
      title: 'ScholarSync',
      debugShowCheckedModeBanner: false,
      theme: NeonTheme.softLightTheme,
      darkTheme: NeonTheme.darkNeonTheme,
      themeMode: ThemeMode.dark,
      home: const AuthWrapper(),
    );
  }
}
