import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/pdf_service.dart';
import '../models/sessao_treino.dart';

class NutricionistaDetalhesPage extends StatefulWidget {
  final String atletaCodigo;
  final String atletaNome;
  const NutricionistaDetalhesPage({super.key, required this.atletaCodigo, required this.atletaNome});

  @override
  State<NutricionistaDetalhesPage> createState() => _NutricionistaDetalhesPageState();
}

class _NutricionistaDetalhesPageState extends State<NutricionistaDetalhesPage> {
  final DatabaseService _db = DatabaseService();
  List<SessaoTreino> _treinos = [];

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final treinos = await _db.getTreinosDoAtleta(widget.atletaCodigo);
    if (!mounted) return;
    setState(() {
      _treinos = treinos;
    });
  }

  Future<void> _exportarTreinoIndividual(SessaoTreino treino) async {
    await PdfService.gerarTreinoIndividualPdf(treino, widget.atletaNome);
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
                    leading: const Icon(Icons.local_drink, color: Colors.blue),
                    title: Text('${t.dataFormatada} - ${t.modalidade}'),
                    subtitle: Text('Ingestao: ${t.fluidosMl} mL'),
                    trailing: IconButton(
                      icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                      onPressed: () => _exportarTreinoIndividual(t),
                      tooltip: 'Baixar PDF',
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _infoRow('Duracao', '${t.duracaoMinutos} min'),
                            _infoRow('Fluidos ingeridos', '${t.fluidosMl} mL'),
                            _infoRow('Massa pre', '${t.massaCorporalPreKg} kg'),
                            _infoRow('Massa pos', '${t.massaCorporalPosKg} kg'),
                            _infoRow('Perda de massa', '${t.percentualPerdaMassa.toStringAsFixed(1)}%'),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: t.fluidosMl / 1000,
                              backgroundColor: Colors.grey[300],
                              color: Colors.green,
                              minHeight: 10,
                            ),
                            Text('Meta: 1000 mL', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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