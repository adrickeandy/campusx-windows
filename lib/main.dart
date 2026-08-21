import 'package:flutter/material.dart';
import 'app.dart';
import 'services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase Client
  try {
    await SupabaseService.initialize();
  } catch (e) {
    print('[Main] Supabase initialization warning: $e');
  }

  runApp(const CampusXApp());
}
