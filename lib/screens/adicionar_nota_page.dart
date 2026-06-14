import 'package:flutter/material.dart';
import 'services/database_service.dart';

class AdicionarNotaPage extends StatefulWidget {
  final String atletaNome;
  final String atletaCodigo;
  final String profissionalTipo;
  final String profissionalId;
  final String profissionalNome;

  const AdicionarNotaPage({
    super.key,
    required this.atletaNome,
    required this.atletaCodigo,
    required this.profissionalTipo,
    required this.profissionalId,
    required this.profissionalNome,
  });

  @override
  State<AdicionarNotaPage> createState() => _AdicionarNotaPageState();
}

class _AdicionarNotaPageState extends State<AdicionarNotaPage> {
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _conteudoController = TextEditingController();
  final DatabaseService _db = DatabaseService();

  void _salvarNota() {
    if (_tituloController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Digite um título'), backgroundColor: Colors.red));
      return;
    }
    if (_conteudoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Digite o conteúdo da nota'), backgroundColor: Colors.red));
      return;
    }

    final nota = Nota(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      atletaCodigo: widget.atletaCodigo,
      profissionalId: widget.profissionalId,
      profissionalNome: widget.profissionalNome,
      profissionalTipo: widget.profissionalTipo,
      titulo: _tituloController.text.trim(),
      conteudo: _conteudoController.text.trim(),
      data: DateTime.now(),
    );

    _db.salvarNota(nota);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nota salva!'), backgroundColor: Colors.green));
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    Color cor = widget.profissionalTipo == 'medico' ? const Color(0xFFB30000) : Colors.green;
    return Scaffold(
      appBar: AppBar(title: Text('Adicionar Nota - ${widget.atletaNome}'), backgroundColor: cor),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Adicione uma observação para o atleta', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextField(controller: _tituloController, decoration: const InputDecoration(labelText: 'Título', border: OutlineInputBorder(), prefixIcon: Icon(Icons.title))),
            const SizedBox(height: 16),
            TextField(controller: _conteudoController, decoration: const InputDecoration(labelText: 'Conteúdo da nota', border: OutlineInputBorder(), prefixIcon: Icon(Icons.note)), maxLines: 8),
            const SizedBox(height: 32),
            ElevatedButton(onPressed: _salvarNota, style: ElevatedButton.styleFrom(backgroundColor: cor, padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text('SALVAR NOTA', style: TextStyle(fontSize: 16))),
          ],
        ),
      ),
    );
  }
}