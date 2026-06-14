import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/sessao_treino.dart';

class MedicoDetalhesPage extends StatefulWidget {
  final String atletaCodigo;
  final String atletaNome;
  const MedicoDetalhesPage({super.key, required this.atletaCodigo, required this.atletaNome});

  @override
  State<MedicoDetalhesPage> createState() => _MedicoDetalhesPageState();
}

class _MedicoDetalhesPageState extends State<MedicoDetalhesPage> {
  final DatabaseService _db = DatabaseService();
  late List<SessaoTreino> _treinos;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  void _carregarDados() {
    _treinos = _db.getTreinosDoAtleta(widget.atletaCodigo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.atletaNome), backgroundColor: const Color(0xFFB30000)),
      body: _treinos.isEmpty
          ? const Center(child: Text('Nenhum treino registrado ainda'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _treinos.length,
              itemBuilder: (context, index) {
                final t = _treinos[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ExpansionTile(
                    leading: const Icon(Icons.fitness_center),
                    title: Text('${t.dataFormatada} - ${t.modalidade}'),
                    subtitle: Text('Borg: ${t.escalaBorg} | Perda: ${t.percentualPerdaMassa.toStringAsFixed(1)}%'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _infoRow('Duração', '${t.duracaoMinutos} min'),
                            _infoRow('Temperatura', '${t.temperatura}°C'),
                            _infoRow('Umidade', '${t.umidade}%'),
                            _infoRow('Fluidos', '${t.fluidosMl} mL'),
                            _infoRow('Massa pré', '${t.massaCorporalPreKg} kg'),
                            _infoRow('Massa pós', '${t.massaCorporalPosKg} kg'),
                            _infoRow('Perda', '${t.percentualPerdaMassa.toStringAsFixed(1)}%'),
                            _infoRow('Sintomas gastro', t.teveSintomasGastro ? 'Sim' : 'Não'),
                            if (t.sintomasDescricao.isNotEmpty) _infoRow('Descrição', t.sintomasDescricao),
                            _infoRow('Fadiga', t.teveFadiga ? 'Sim' : 'Não'),
                            if (t.fadigaDescricao.isNotEmpty) _infoRow('Descrição fadiga', t.fadigaDescricao),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}