import 'package:flutter/material.dart';
import 'package:serviceprovider/screen/landingpage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://awbbcyahdusjhmlryvef.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF3YmJjeWFoZHVzamhtbHJ5dmVmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzkxODgyNDEsImV4cCI6MjA1NDc2NDI0MX0.6Uf3OQIgz466L-14CuUTiGQYxVdgu2ZliCnNcoNDh5I',
  );

  runApp(MainApp());
}

// Get a reference to your Supabase client
final supabase = Supabase.instance.client;

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Mylanding(),
    );
  }
}





