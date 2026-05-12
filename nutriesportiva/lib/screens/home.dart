import 'package:flutter/material.dart';
import 'inicial.dart';
import 'treino/treino_pre_sessao.dart';


class MyHomePage extends StatefulWidget {
  final bool mostrarMensagemTreinoSalvo;

  const MyHomePage({
    super.key,
    this.mostrarMensagemTreinoSalvo = false,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String nomeAtleta = 'Atleta';

  @override
  void initState() {
    super.initState();

    if (widget.mostrarMensagemTreinoSalvo) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Treino salvo com sucesso.')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const TelaLanding()),
            );
          },
        ),
        title: const Text("HydroTrack"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          'Bem vindo, $nomeAtleta!',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFB30000),
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TreinoPreSessao()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
