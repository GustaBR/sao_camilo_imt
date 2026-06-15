import 'package:flutter/material.dart';
import 'screens/tela_inicial.dart';
import 'screens/tela_login.dart';
import 'screens/cadastro_page.dart';
import 'screens/atleta_perfil_page.dart';
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
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFB30000),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const TelaInicial());
          case '/login':
            return MaterialPageRoute(builder: (_) => const TelaLogin());
          case '/cadastro':
            return MaterialPageRoute(builder: (_) => const CadastroPage());
          case '/atleta/perfil':
            final args = settings.arguments;
            final codigo = args is Map ? args['codigo']?.toString() ?? '' : '';
            final nome = args is Map ? args['nome']?.toString() ?? '' : '';
            return MaterialPageRoute(
              builder: (_) => AtletaPerfilPage(
                codigo: codigo,
                nome: nome,
              ),
            );
          case '/atleta/treino':
            return MaterialPageRoute(builder: (_) => const DashboardPage());
          default:
            return MaterialPageRoute(builder: (_) => const TelaInicial());
        }
      },
    );
  }
}
