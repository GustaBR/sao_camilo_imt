import 'package:flutter/material.dart';
import 'screens/login/login_profissional_page.dart';
import 'screens/aluno/aluno_codigo_page.dart';
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
      routes: {
        '/': (context) => const TelaInicial(),
        '/aluno': (context) => const AlunoCodigoPage(),
        '/medico': (context) => const LoginProfissionalPage(tipo: 'medico'),
        '/nutricionista': (context) => const LoginProfissionalPage(tipo: 'nutricionista'),
      },
    );
  }
}

class TelaInicial extends StatelessWidget {
  const TelaInicial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xFFB30000), const Color(0xFFB30000).withOpacity(0.7)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.fitness_center, size: 80, color: Colors.white),
              const SizedBox(height: 24),
              const Text(
                'NUTRIESPORTIVA',
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
              const Text(
                'SÃO CAMILO',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
              const SizedBox(height: 60),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/aluno'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFFB30000)),
                        child: const Text('SOU ALUNO', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/medico'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFFB30000)),
                        child: const Text('SOU MÉDICO', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/nutricionista'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFFB30000)),
                        child: const Text('SOU NUTRICIONISTA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}