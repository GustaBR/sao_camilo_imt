import 'package:flutter/material.dart';
import 'screens/treino/treino_pre_sessao.dart';
import 'screens/treino/cadastro_page.dart';

void main() {
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
      
      home: const CadastroPage (),
    );
  }
}
