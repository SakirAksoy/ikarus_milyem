import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'firebase_seeder.dart';
import 'main_layout.dart';

// ============================================================================
// APPLICATION ENTRY POINT
// ============================================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize database in background (non-blocking)
  // Errors are logged but UI still loads
  _initializeDatabase();

  runApp(const ProviderScope(child: MyApp()));
}

// ============================================================================
// BACKGROUND DATABASE INITIALIZATION
// ============================================================================

void _initializeDatabase() {
  // Run in background - don't await
  FirebaseSeeder()
      .initializeDatabase(firmaId: 'default_firma')
      .catchError((e) {
    // Log error but don't crash the app
    debugPrint('⚠️ Database initialization error (non-critical): $e');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'İkarus Milyem',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainLayout(),
      debugShowCheckedModeBanner: false,
    );
  }
}
