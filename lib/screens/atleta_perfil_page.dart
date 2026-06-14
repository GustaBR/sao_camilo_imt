import 'package:flutter/material.dart';
import '../services/database_service.dart';

class AtletaPerfilPage extends StatefulWidget {
  final String codigo;
  final String nome;
  const AtletaPerfilPage({super.key, required this.codigo, required this.nome});

  @override
  State<AtletaPerfilPage> createState() => _AtletaPerfilPageState();
}

class _AtletaPerfilPageState extends State<AtletaPerfilPage> {
  final DatabaseService _db = DatabaseService();
  late List<SessaoTreino> _treinos;

  @override
  void initState() {
    super.initState();
    _carregarTreinos();
  }

  void _carregarTreinos() {
    _treinos = _db.getTreinosDoAtleta(widget.codigo);
  }

  void _sair() {
    _db.logout();
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        backgroundColor: const Color(0xFFB30000),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: _sair)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Card(
              elevation: 4,
              color: const Color(0xFFB30000),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(Icons.qr_code, size: 60, color: Colors.white),
                    const SizedBox(height: 16),
                    const Text('Seu código exclusivo:', style: TextStyle(color: Colors.white, fontSize: 16)),
                    const SizedBox(height: 8),
                    SelectableText(
                      widget.codigo,
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: 4, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    const Text('Compartilhe este código com seu Médico e Nutricionista', 
                      style: TextStyle(color: Colors.white70), textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(leading: const Icon(Icons.person), title: const Text('Nome'), subtitle: Text(widget.nome)),
                    const Divider(),
                    ListTile(leading: const Icon(Icons.email), title: const Text('Email'), 
                      subtitle: Text(_db.getAtleta(widget.codigo)?['email'] ?? '')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Histórico de Treinos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _treinos.isEmpty
                ? const Card(child: Padding(padding: EdgeInsets.all(24), child: Text('Nenhum treino registrado ainda')))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _treinos.length,
                    itemBuilder: (context, index) {
                      final t = _treinos[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.fitness_center),
                          title: Text('${t.dataFormatada} - ${t.modalidade}'),
                          subtitle: Text('Duração: ${t.duracaoMinutos} min | Borg: ${t.escalaBorg}'),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}