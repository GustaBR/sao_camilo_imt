import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/sessao_treino.dart';
import '../models/nota.dart';
import 'adicionar_nota_page.dart';

class DetalhesAlunoPage extends StatefulWidget {
  final String alunoNome;
  final String alunoCodigo;
  final String profissionalTipo;
  final Color cor;
  final List<SessaoTreino> treinos;

  const DetalhesAlunoPage({
    super.key,
    required this.alunoNome,
    required this.alunoCodigo,
    required this.profissionalTipo,
    required this.cor,
    required this.treinos,
  });

  @override
  State<DetalhesAlunoPage> createState() => _DetalhesAlunoPageState();
}

class _DetalhesAlunoPageState extends State<DetalhesAlunoPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<SessaoTreino> _treinos;
  final DatabaseService _db = DatabaseService();

  @override
  void initState() {
    super.initState();
    _treinos = widget.treinos;
    _tabController = TabController(length: 2, vsync: this);
    print('Detalhes do aluno: ${widget.alunoNome}, ${_treinos.length} treinos'); // Debug
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _recarregarTreinos() async {
    List<SessaoTreino> novosTreinos = await _db.getTreinosDoAluno(widget.alunoCodigo);
    setState(() {
      _treinos = novosTreinos;
    });
  }

  void _adicionarNota() async {
    final profissional = _db.getProfissionalLogado();
    if (profissional == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profissional não logado'), backgroundColor: Colors.red),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdicionarNotaPage(
          alunoNome: widget.alunoNome,
          alunoCodigo: widget.alunoCodigo,
          profissionalTipo: widget.profissionalTipo,
          profissionalId: profissional['id'],
          profissionalNome: profissional['nome'],
        ),
      ),
    );
    
    if (result == true) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.alunoNome),
        backgroundColor: widget.cor,
        actions: [
          IconButton(
            icon: const Icon(Icons.note_add),
            onPressed: _adicionarNota,
            tooltip: 'Adicionar nota',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'HISTÓRICO', icon: Icon(Icons.fitness_center)),
            Tab(text: 'NOTAS', icon: Icon(Icons.note)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Aba Histórico
          RefreshIndicator(
            onRefresh: _recarregarTreinos,
            child: _treinos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.fitness_center, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text('Nenhum treino registrado', style: TextStyle(fontSize: 18, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text('O atleta ${widget.alunoNome} ainda não finalizou nenhum treino',
                            style: TextStyle(color: Colors.grey[400])),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _treinos.length,
                    itemBuilder: (context, index) => _buildTreinoCard(_treinos[index]),
                  ),
          ),
          // Aba Notas
          _buildNotasTab(),
        ],
      ),
    );
  }

  Widget _buildNotasTab() {
    final notas = _db.getNotasDoAtleta(widget.alunoCodigo);
    
    if (notas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Nenhuma nota ainda', style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 8),
            Text('Toque no + para adicionar uma nota', style: TextStyle(color: Colors.grey[400])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notas.length,
      itemBuilder: (context, index) {
        final nota = notas[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: nota.profissionalTipo == 'medico' 
                  ? Colors.red[100] 
                  : Colors.green[100],
              child: Icon(
                nota.profissionalTipo == 'medico' 
                    ? Icons.medical_services 
                    : Icons.restaurant,
                color: nota.profissionalTipo == 'medico' 
                    ? Colors.red 
                    : Colors.green,
              ),
            ),
            title: Text(nota.titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(nota.conteudo),
                const SizedBox(height: 4),
                Text(
                  '${nota.profissionalNome} - ${_formatarData(nota.data)}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year} ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
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