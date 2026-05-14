import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/constants/supabase_constants.dart';
import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/notes_provider.dart';
import 'providers/university_provider.dart';
import 'ui/screens/auth/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox('notesBox'); // Box for offline caching
  await Hive.openBox('prefsBox'); // Box for favorites and recents
  
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
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NotesProvider()),
        ChangeNotifierProvider(create: (_) => UniversityProvider()),
      ],
      child: const SmartNotesApp(),
    ),
  );
}

class SmartNotesApp extends StatelessWidget {
  const SmartNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Smart Notes Hub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const AuthWrapper(),
    );
  }
}
