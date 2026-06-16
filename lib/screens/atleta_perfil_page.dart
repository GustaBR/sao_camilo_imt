import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/sessao_treino.dart';

class AtletaPerfilPage extends StatefulWidget {
  final String codigo;
  final String nome;
  const AtletaPerfilPage({super.key, required this.codigo, required this.nome});

  @override
  State<AtletaPerfilPage> createState() => _AtletaPerfilPageState();
}

class _AtletaPerfilPageState extends State<AtletaPerfilPage> {
  final DatabaseService _db = DatabaseService();
  Map<String, dynamic> _dadosAtleta = {};
  List<SessaoTreino> _treinos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final atleta = await _db.getAtleta(widget.codigo);
    final treinos = await _db.getTreinosDoAtleta(widget.codigo);
    if (!mounted) return;

    setState(() {
      _dadosAtleta = atleta ?? {};
      _treinos = treinos;
      _isLoading = false;
    });
  }

  String _calcularIdade(String? dataNascimento) {
    if (dataNascimento == null || dataNascimento.isEmpty) return 'Nao informado';
    try {
      final nascimento = DateTime.parse(dataNascimento);
      final hoje = DateTime.now();
      int idade = hoje.year - nascimento.year;
      if (hoje.month < nascimento.month || (hoje.month == nascimento.month && hoje.day < nascimento.day)) {
        idade--;
      }
      return '$idade anos';
    } catch (e) {
      return 'Nao informado';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        backgroundColor: const Color(0xFFB30000),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: const Color(0xFFB30000),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(Icons.qr_code, size: 60, color: Colors.white),
                    const SizedBox(height: 16),
                    const Text(
                      'Seu codigo exclusivo',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SelectableText(
                        widget.codigo,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                          color: Color(0xFFB30000),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Compartilhe este codigo com seu Medico e Nutricionista',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.person, color: Color(0xFFB30000)),
                        SizedBox(width: 8),
                        Text('Informacoes Pessoais', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(height: 24),
                    ListTile(
                      leading: const Icon(Icons.badge, color: Colors.grey),
                      title: const Text('Nome completo'),
                      subtitle: Text(widget.nome),
                      dense: true,
                    ),
                    ListTile(
                      leading: const Icon(Icons.email, color: Colors.grey),
                      title: const Text('E-mail'),
                      subtitle: Text(_dadosAtleta['email'] ?? 'Carregando...'),
                      dense: true,
                    ),
                    ListTile(
                      leading: const Icon(Icons.cake, color: Colors.grey),
                      title: const Text('Data de nascimento'),
                      subtitle: Text(_dadosAtleta['dataNascimento'] ?? 'Nao informado'),
                      dense: true,
                    ),
                    ListTile(
                      leading: const Icon(Icons.calendar_today, color: Colors.grey),
                      title: const Text('Idade'),
                      subtitle: Text(_calcularIdade(_dadosAtleta['dataNascimento'])),
                      dense: true,
                    ),
                    ListTile(
                      leading: const Icon(Icons.straighten, color: Colors.grey),
                      title: const Text('Altura'),
                      subtitle: Text(_dadosAtleta['altura'] != null ? '${_dadosAtleta['altura']} cm' : 'Nao informado'),
                      dense: true,
                    ),
                    ListTile(
                      leading: const Icon(Icons.monitor_weight, color: Colors.grey),
                      title: const Text('Peso'),
                      subtitle: Text(_dadosAtleta['peso'] != null ? '${_dadosAtleta['peso']} kg' : 'Nao informado'),
                      dense: true,
                    ),
                    ListTile(
                      leading: const Icon(Icons.wc, color: Colors.grey),
                      title: const Text('Sexo'),
                      subtitle: Text(_dadosAtleta['sexo'] ?? 'Nao informado'),
                      dense: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.analytics, color: Color(0xFFB30000)),
                        SizedBox(width: 8),
                        Text('Estatisticas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        _buildEstatisticaCard(
                          titulo: 'Total de Treinos',
                          valor: _treinos.length.toString(),
                          icone: Icons.fitness_center,
                          cor: const Color(0xFFB30000),
                        ),
                        const SizedBox(width: 12),
                        _buildEstatisticaCard(
                          titulo: 'Total de Horas',
                          valor: '${_treinos.fold(0, (sum, t) => sum + t.duracaoMinutos) ~/ 60} h',
                          icone: Icons.timer,
                          cor: const Color(0xFFB30000),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildEstatisticaCard(
                          titulo: 'Media Borg',
                          valor: _treinos.isEmpty ? '0' : (_treinos.fold(0, (sum, t) => sum + t.escalaBorg) / _treinos.length).toStringAsFixed(1),
                          icone: Icons.speed,
                          cor: const Color(0xFFB30000),
                        ),
                        const SizedBox(width: 12),
                        _buildEstatisticaCard(
                          titulo: 'Media Perda %',
                          valor: _treinos.isEmpty ? '0%' : (_treinos.fold(0.0, (sum, t) => sum + t.percentualPerdaMassa) / _treinos.length).toStringAsFixed(1) + '%',
                          icone: Icons.water_drop,
                          cor: const Color(0xFFB30000),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstatisticaCard({
    required String titulo,
    required String valor,
    required IconData icone,
    required Color cor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cor.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icone, color: cor, size: 28),
            const SizedBox(height: 8),
            Text(
              valor,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: cor),
            ),
            Text(
              titulo,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}