import 'package:flutter/material.dart';
import 'screens/tela_inicial.dart';
import 'screens/tela_login.dart';
import 'ui/paginas/treino/dashboard_page.dart';
import 'services/database_service.dart';

void main() {
  DatabaseService().carregarDadosExemplo();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nutriesportiva',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFB30000),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFB30000)),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const TelaInicial(),
        '/login': (context) => const TelaLogin(),
        '/dashboard': (context) => const DashboardPage(),
      },
    );
  }
}