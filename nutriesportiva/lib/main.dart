import 'package:flutter/material.dart';
import 'screens/inicial.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/cadastro.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://kmvqcogjcwkspejfwvko.supabase.co',
    anonKey: 'sb_publishable_7MYZxoaWKmJwof-YFzvdJA_R6BeBHTF',
  );
  runApp(const NutriesportApp());
}

class NutriesportApp extends StatelessWidget {
  const NutriesportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nutriesportiva',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        primaryColor: const Color(0xFFB30000),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB30000),
          primary: const Color(0xFFB30000),
        ),
        scaffoldBackgroundColor: const Color(0xFFE0E0E0), 
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFB30000),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 4,
        ),
        
        
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB30000),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      
      home: const CadastroPage(),
    );
  }
}
