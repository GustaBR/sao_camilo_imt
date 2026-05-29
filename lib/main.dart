// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/treino/dashboard_page.dart';
import 'screens/pages/selecao_profissional_page.dart';
import 'screens/services/atleta_data_manager.dart';

void main() {
  // Adiciona dados de exemplo para teste
  AtletaDataManager().adicionarDadosExemplo();
  
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
      initialRoute: '/',
      routes: {
        '/': (context) => const SelecaoProfissionalPage(),
        '/dashboard': (context) => const DashboardPage(),
      },
    );
  }
}