import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../models/sessao_treino.dart';

class DetalhesAlunoPage extends StatefulWidget {
  final String alunoNome;
  final String alunoCodigo;
  final String profissionalTipo;
  final Color cor;

  const DetalhesAlunoPage({
    super.key,
    required this.alunoNome,
    required this.alunoCodigo,
    required this.profissionalTipo,
    required this.cor,
  });

  @override
  State<DetalhesAlunoPage> createState() => _DetalhesAlunoPageState();
}

class _DetalhesAlunoPageState extends State<DetalhesAlunoPage> {
  late Future<List<SessaoTreino>> _treinosFuture;
  final DatabaseService _db = DatabaseService();

  @override
  void initState() {
    super.initState();
    _carregarTreinos();
  }

  void _carregarTreinos() {
    setState(() {
      _treinosFuture = Future.value(_db.getTreinosDoAluno(widget.alunoCodigo));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.alunoNome),
        backgroundColor: widget.cor,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _carregarTreinos();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: FutureBuilder<List<SessaoTreino>>(
          future: _treinosFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final treinos = snapshot.data ?? [];
            if (treinos.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.fitness_center, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('Nenhum treino registrado', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text('O aluno ${widget.alunoNome} ainda não finalizou nenhum treino',
                        style: TextStyle(color: Colors.grey[400])),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: treinos.length,
              itemBuilder: (context, index) => _buildTreinoCard(treinos[index]),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTreinoCard(SessaoTreino treino) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: widget.cor.withOpacity(0.2),
          child: Icon(Icons.fitness_center, color: widget.cor),
        ),
        title: Text(
          '${treino.dataFormatada} - ${treino.modalidade}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Duração: ${treino.duracaoMinutos} min | Borg: ${treino.escalaBorg}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Data', treino.dataFormatada),
                const Divider(),
                _buildInfoRow('Modalidade', treino.modalidade),
                const Divider(),
                _buildInfoRow('Duração', '${treino.duracaoMinutos} minutos'),
                const Divider(),
                _buildInfoRow('Temperatura', '${treino.temperatura}°C'),
                _buildInfoRow('Umidade', '${treino.umidade}%'),
                const Divider(),
                _buildInfoRow('Ingestão de fluidos', '${treino.fluidosMl} mL'),
                const Divider(),
                _buildInfoRow('Massa corporal pré', '${treino.massaCorporalPreKg} kg'),
                _buildInfoRow('Massa corporal pós', '${treino.massaCorporalPosKg} kg'),
                _buildInfoRow('Perda de massa', '${treino.percentualPerdaMassa.toStringAsFixed(1)}%'),
                const Divider(),
                _buildInfoRow('Escala de Borg', '${treino.escalaBorg}/20'),
                const Divider(),
                if (widget.profissionalTipo == 'medico') ...[
                  _buildInfoRow('Sintomas gastrointestinais', treino.teveSintomasGastro ? 'Sim' : 'Não'),
                  if (treino.sintomasDescricao.isNotEmpty)
                    _buildInfoRow('Descrição sintomas', treino.sintomasDescricao),
                  _buildInfoRow('Fadiga', treino.teveFadiga ? 'Sim' : 'Não'),
                  if (treino.fadigaDescricao.isNotEmpty)
                    _buildInfoRow('Descrição fadiga', treino.fadigaDescricao),
                ],
                if (widget.profissionalTipo == 'nutricionista') ...[
                  _buildInfoRow('Nível de hidratação', _getNivelHidratacao(treino.fluidosMl)),
                  const SizedBox(height: 8),
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: treino.fluidosMl / 1000,
                                backgroundColor: Colors.grey[300],
                                color: Colors.green,
                                minHeight: 8,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('${((treino.fluidosMl / 1000) * 100).toInt()}%',
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Meta: 1000 mL por treino', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black54)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _getNivelHidratacao(int fluidosMl) {
    if (fluidosMl >= 1000) return "Excelente";
    if (fluidosMl >= 700) return "Boa";
    if (fluidosMl >= 500) return "Regular";
    return "Atenção - Baixa ingestão";
  }
}