import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/sessao_treino.dart';

class TreinadorDetalhesPage extends StatefulWidget {
  final String atletaCodigo;
  final String atletaNome;
  const TreinadorDetalhesPage({super.key, required this.atletaCodigo, required this.atletaNome});

  @override
  State<TreinadorDetalhesPage> createState() => _TreinadorDetalhesPageState();
}

class _TreinadorDetalhesPageState extends State<TreinadorDetalhesPage> {
  final DatabaseService _db = DatabaseService();
  List<SessaoTreino> _treinos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _isLoading = true);
    try {
      final treinos = await _db.getTreinosDoAtleta(widget.atletaCodigo);
      if (!mounted) return;
      setState(() {
        _treinos = treinos;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar treinos: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.atletaNome), 
        backgroundColor: const Color(0xFFB30000),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _treinos.isEmpty
              ? const Center(child: Text('Nenhum treino registado ainda'))
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
                                _infoRow('Humidade', '${t.umidade}%'),
                                _infoRow('Fluidos Consumidos', '${t.fluidosMl} mL'),
                                _infoRow('Massa Pré-Treino', '${t.massaCorporalPreKg} kg'),
                                _infoRow('Massa Pós-Treino', '${t.massaCorporalPosKg} kg'),
                                _infoRow('Percentual de Perda', '${t.percentualPerdaMassa.toStringAsFixed(1)}%'),
                                _infoRow('Sintomas Gastro', t.teveSintomasGastro ? 'Sim' : 'Não'),
                                if (t.sintomasDescricao.isNotEmpty) _infoRow('Descrição Sintomas', t.sintomasDescricao),
                                _infoRow('Teve Fadiga', t.teveFadiga ? 'Sim' : 'Não'),
                                if (t.fadigaDescricao.isNotEmpty) _infoRow('Descrição Fadiga', t.fadigaDescricao),
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
          SizedBox(
            width: 140, 
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}