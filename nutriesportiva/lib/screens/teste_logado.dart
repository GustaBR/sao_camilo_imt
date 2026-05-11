import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart';
import 'inicial.dart'; 
class TesteLogado extends StatefulWidget {
  const TesteLogado({super.key});

  @override
  State<TesteLogado> createState() => _TesteLogadoState();
}

class _TesteLogadoState extends State<TesteLogado> {
  final usuarioAtual = Supabase.instance.client.auth.currentUser;

  Future<void> _sairDaConta() async {
    await Supabase.instance.client.auth.signOut();
    
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const TelaLanding()),
        (Route<dynamic> route) => false, // Esse 'false' é o que manda apagar tudo!
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Painel do Nutricionista"),
        backgroundColor: const Color(0xFFB30000),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair da conta',
            onPressed: _sairDaConta,
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            const Text(
              "Você está na Área Logada!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Logado como: ${usuarioAtual?.email ?? 'E-mail não encontrado'}",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),   
          ],
        ),
      ),
    );
  }
}