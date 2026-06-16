import 'package:flutter/material.dart';
import '../../../services/csv_service.dart';
import '../../../services/database_service.dart';
import '../../../services/pdf_service.dart';
import '../../../models/sessao_treino.dart';
import '../../../widgets/treino_date_filter.dart';
import 'treino_pre_sessao.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DatabaseService _db = DatabaseService();
  List<SessaoTreino> _historico = [];
  DateTimeRange? _periodoFiltro;
  bool _isLoading = true;
  String? _atletaNome;

  @override
  void initState() {
    super.initState();
    _carregarHistorico();
  }

  Future<void> _carregarHistorico() async {
    final ativo = _db.getAtivoLogado();
    if (ativo != null) {
      _atletaNome = ativo['nome'];
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

  Future<void> _exportarPdf() async {
    if (_historico.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum treino para exportar'), backgroundColor: Colors.orange),
      );
      return;
    }
    await PdfService.gerarHistoricoPdf(_historico, _atletaNome ?? 'Atleta');
  }

  Future<void> _exportarCsv(List<SessaoTreino> treinos) async {
    if (treinos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum treino para exportar'), backgroundColor: Colors.orange),
      );
      return;
    }

    try {
      await CsvService.gerarHistoricoCsv(treinos, _atletaNome ?? 'Atleta');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CSV gerado com sucesso'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao gerar CSV: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _exportarTreinoIndividual(SessaoTreino treino) async {
    await PdfService.gerarTreinoIndividualPdf(treino, _atletaNome ?? 'Atleta');
  }

  Future<void> _confirmarDeletarTreino(SessaoTreino treino) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar Treino'),
        content: Text('Tem certeza que deseja deletar o treino de ${treino.dataFormatada}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      final deletado = await _db.deletarTreino(treino.id);
      if (!mounted) return;
      if (deletado) {
        await _carregarHistorico();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Treino deletado!'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_db.ultimoErro ?? 'Erro ao deletar treino'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ativo = _db.getAtivoLogado();
    final historicoFiltrado = filtrarTreinosPorPeriodo(_historico, _periodoFiltro);

    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      appBar: AppBar(
        title: const Text('Dashboard do Atleta'),
        backgroundColor: const Color(0xFFB30000),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            onPressed: _exportarPdf,
            tooltip: 'Exportar todos os treinos',
          ),
          IconButton(
            icon: const Icon(Icons.table_chart, color: Colors.white),
            onPressed: () => _exportarCsv(historicoFiltrado),
            tooltip: 'Exportar CSV',
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
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
          IconButton(icon: const Icon(Icons.logout, color: Colors.white), onPressed: _sair, tooltip: 'Sair'),
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
                            icon: const Icon(Icons.play_arrow, color: Color(0xFFB30000)),
                            label: const Text('INICIAR NOVO TREINO', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFB30000))),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
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
                          const Text('Historico de Treinos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          if (_historico.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32),
                                child: Text('Nenhum treino registrado ainda. Inicie um novo treino!', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                              ),
                            )
                          else ...[
                            TreinoDateFilter(
                              periodo: _periodoFiltro,
                              onChanged: (periodo) => setState(() => _periodoFiltro = periodo),
                              cor: const Color(0xFFB30000),
                              total: _historico.length,
                              filtrados: historicoFiltrado.length,
                            ),
                            const SizedBox(height: 12),
                            if (historicoFiltrado.isEmpty)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32),
                                  child: Text('Nenhum treino encontrado nesse periodo.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: historicoFiltrado.length,
                                itemBuilder: (context, index) {
                                  final t = historicoFiltrado[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    child: Column(
                                      children: [
                                        ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: const Color(0xFFB30000).withOpacity(0.1),
                                            child: const Icon(Icons.fitness_center, color: Color(0xFFB30000)),
                                          ),
                                          title: Text('${t.dataFormatada} - ${t.modalidade}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                          subtitle: Text('Duracao: ${t.duracaoMinutos} min | Borg: ${t.escalaBorg}'),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                                                onPressed: () => _exportarTreinoIndividual(t),
                                                tooltip: 'Baixar PDF deste treino',
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                                onPressed: () => _confirmarDeletarTreino(t),
                                                tooltip: 'Deletar treino',
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              _infoRow('Data', t.dataFormatada),
                                              _infoRow('Modalidade', t.modalidade),
                                              _infoRow('Duracao', '${t.duracaoMinutos} min'),
                                              _infoRow('Duracao real', '${t.duracaoRealSegundos ~/ 60} min'),
                                              const Divider(),
                                              _infoRow('Temperatura', '${t.temperatura}°C'),
                                              _infoRow('Umidade', '${t.umidade}%'),
                                              _infoRow('Sensacao termica', '${t.sensacaoTermica}°C'),
                                              _infoRow('Vento', t.vento),
                                              _infoRow('Exposicao solar', t.exposicaoSolar),
                                              const Divider(),
                                              _infoRow('Fluidos ingeridos', '${t.fluidosMl} mL'),
                                              _infoRow('Alimentos com agua', t.alimentosAgua),
                                              _infoRow('Volume urinario', '${t.volumeUrinarioMl} mL'),
                                              const Divider(),
                                              _infoRow('Massa pre', '${t.massaCorporalPreKg} kg'),
                                              _infoRow('Massa pos', '${t.massaCorporalPosKg} kg'),
                                              _infoRow('Perda de massa', '${t.percentualPerdaMassa.toStringAsFixed(1)}%'),
                                              _infoRow('Cor da urina', t.corUrina),
                                              _infoRow('Vestimenta', t.vestimenta),
                                              _infoRow('Equipamento', t.equipamento),
                                              const Divider(),
                                              _infoRow('Escala de Borg', '${t.escalaBorg}/20'),
                                              _infoRow('Estava com sede', t.estaComSede ? 'Sim' : 'Nao'),
                                              _infoRow('Sintomas pre-treino', t.sintomasPreDescricao.isNotEmpty ? t.sintomasPreDescricao : 'Nenhum'),
                                              _infoRow('Historico de hidratacao', t.historicoHidratacao),
                                              const Divider(),
                                              _infoRow('Roupas encharcadas', t.roupasEncharcadas ? 'Sim' : 'Nao'),
                                              _infoRow('Troca de vestimenta', t.trocaVestimenta ? 'Sim' : 'Nao'),
                                              if (t.observacaoRoupas.isNotEmpty) _infoRow('Observacao roupas', t.observacaoRoupas),
                                              const Divider(),
                                              _infoRow('Sintomas gastro', t.teveSintomasGastro ? 'Sim' : 'Nao'),
                                              if (t.sintomasDescricao.isNotEmpty) _infoRow('Descricao sintomas', t.sintomasDescricao),
                                              _infoRow('Fadiga', t.teveFadiga ? 'Sim' : 'Nao'),
                                              if (t.fadigaDescricao.isNotEmpty) _infoRow('Descricao fadiga', t.fadigaDescricao),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                          ],
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
          SizedBox(width: 150, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
