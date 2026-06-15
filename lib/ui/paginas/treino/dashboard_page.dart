import 'package:flutter/material.dart';
import '../../../services/database_service.dart';
import '../../../models/sessao_treino.dart';
import 'treino_pre_sessao.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DatabaseService _db = DatabaseService();
  List<SessaoTreino> _historico = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarHistorico();
  }

  Future<void> _carregarHistorico() async {
    final ativo = _db.getAtivoLogado();
    if (ativo != null) {
      final historico = await _db.getTreinosDoAtleta(ativo['id']);
      if (!mounted) return;
      setState(() {
        _historico = historico;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _iniciarTreino() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const TreinoPreSessao()));
    if (result == true) {
      _carregarHistorico();
    }
  }

  Future<void> _sair() async {
    await _db.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final ativo = _db.getAtivoLogado();

    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      appBar: AppBar(
        title: const Text('Dashboard do Atleta'),
        backgroundColor: const Color(0xFFB30000),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              if (ativo != null) {
                Navigator.pushNamed(
                  context,
                  '/atleta/perfil',
                  arguments: {'codigo': ativo['id'].toString(), 'nome': ativo['nome'].toString()},
                );
              }
            },
            tooltip: 'Meu Perfil',
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _sair, tooltip: 'Sair'),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Icon(Icons.fitness_center, size: 60, color: Color(0xFFB30000)),
                          const SizedBox(height: 16),
                          Text('Bem-vindo, ${ativo != null ? ativo['nome'] : 'Atleta'}!', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const Text('Registre seus treinos e acompanhe seu desempenho', style: TextStyle(fontSize: 16, color: Colors.black54), textAlign: TextAlign.center),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _iniciarTreino,
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('INICIAR NOVO TREINO', style: TextStyle(fontSize: 16)),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB30000), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Histórico de Treinos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          if (_historico.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32),
                                child: Text('Nenhum treino registrado ainda.\nInicie um novo treino!', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _historico.length,
                              itemBuilder: (context, index) {
                                final t = _historico[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: ExpansionTile(
                                    leading: CircleAvatar(backgroundColor: const Color(0xFFB30000).withOpacity(0.1), child: const Icon(Icons.fitness_center, color: Color(0xFFB30000))),
                                    title: Text('${t.dataFormatada} - ${t.modalidade}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text('Duração: ${t.duracaoMinutos} min | Borg: ${t.escalaBorg}'),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _infoRow('Data', t.dataFormatada),
                                            _infoRow('Modalidade', t.modalidade),
                                            _infoRow('Duração', '${t.duracaoMinutos} min'),
                                            const Divider(),
                                            _infoRow('Temperatura', '${t.temperatura}°C'),
                                            _infoRow('Umidade', '${t.umidade}%'),
                                            const Divider(),
                                            _infoRow('Fluidos ingeridos', '${t.fluidosMl} mL'),
                                            _infoRow('Massa pré', '${t.massaCorporalPreKg} kg'),
                                            _infoRow('Massa pós', '${t.massaCorporalPosKg} kg'),
                                            _infoRow('Perda de massa', '${t.percentualPerdaMassa.toStringAsFixed(1)}%'),
                                            const Divider(),
                                            _infoRow('Escala de Borg', '${t.escalaBorg}/20'),
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
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
