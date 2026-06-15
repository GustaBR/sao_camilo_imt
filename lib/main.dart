import 'package:flutter/material.dart';
import 'screens/tela_inicial.dart';
import 'screens/tela_login.dart';
import 'screens/cadastro_page.dart';
import 'screens/atleta_perfil_page.dart';
import 'screens/medico_lista_page.dart';
import 'screens/nutricionista_lista_page.dart';
import 'ui/paginas/treino/dashboard_page.dart';
import 'services/database_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://kmvqcogjcwkspejfwvko.supabase.co',
    anonKey: 'sb_publishable_7MYZxoaWKmJwof-YFzvdJA_R6BeBHTF', 
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final sessao = DatabaseService().getAtivoLogado();

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
      home: _telaInicialDaSessao(sessao),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
          case '/home':
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

  Widget _telaInicialDaSessao(Map<String, dynamic>? sessao) {
    if (sessao == null) return const TelaInicial();

    final tipo = sessao['tipo']?.toString();
    final id = sessao['id']?.toString() ?? '';
    final nome = sessao['nome']?.toString() ?? '';

    if (tipo == 'atleta') {
      return const DashboardPage();
    }
    if (tipo == 'medico') {
      return MedicoListaPage(profissionalId: id, profissionalNome: nome);
    }
    if (tipo == 'nutricionista') {
      return NutricionistaListaPage(profissionalId: id, profissionalNome: nome);
    }
    return const TelaInicial();
  }
}
