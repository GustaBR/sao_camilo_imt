import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/sessao_treino.dart';
import '../widgets/treino_date_filter.dart';

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
  DateTimeRange? _periodoFiltro;

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

  @override
  Widget build(BuildContext context) {
    final treinosFiltrados = filtrarTreinosPorPeriodo(_treinos, _periodoFiltro);

    return Scaffold(
      appBar: AppBar(title: Text(widget.atletaNome), backgroundColor: const Color(0xFFB30000)),
      body: _treinos.isEmpty
          ? const Center(child: Text('Nenhum treino registrado ainda'))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: TreinoDateFilter(
                    periodo: _periodoFiltro,
                    onChanged: (periodo) => setState(() => _periodoFiltro = periodo),
                    cor: Colors.green,
                    total: _treinos.length,
                    filtrados: treinosFiltrados.length,
                  ),
                ),
                Expanded(
                  child: treinosFiltrados.isEmpty
                      ? const Center(child: Text('Nenhum treino encontrado nesse periodo.'))
                      : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: treinosFiltrados.length,
              itemBuilder: (context, index) {
                final t = treinosFiltrados[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ExpansionTile(
                    leading: const Icon(Icons.local_drink, color: Colors.blue),
                    title: Text('${t.dataFormatada} - ${t.modalidade}'),
                    subtitle: Text('Ingestao: ${t.fluidosMl} mL'),
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
                            _infoRow('Nivel de hidratacao', t.nivelHidratacao),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
                ),
              ],
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