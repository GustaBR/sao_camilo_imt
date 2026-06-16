import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/sessao_treino.dart';
import '../models/nota.dart';
import 'adicionar_nota_page.dart';

class DetalhesAtletaPage extends StatefulWidget {
  final String atletaNome;
  final String atletaCodigo;
  final String profissionalTipo;
  final Color cor;
  final List<SessaoTreino> treinos;

  const DetalhesAtletaPage({
    super.key,
    required this.atletaNome,
    required this.atletaCodigo,
    required this.profissionalTipo,
    required this.cor,
    required this.treinos,
  });

  @override
  State<DetalhesAtletaPage> createState() => _DetalhesAtletaPageState();
}

class _DetalhesAtletaPageState extends State<DetalhesAtletaPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<SessaoTreino> _treinos;
  List<Nota> _notas = [];
  bool _isLoadingNotas = true;
  final DatabaseService _db = DatabaseService();

  @override
  void initState() {
    super.initState();
    _treinos = widget.treinos;
    _tabController = TabController(length: 2, vsync: this);
    _carregarNotas();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _recarregarTreinos() async {
    List<SessaoTreino> novosTreinos = await _db.getTreinosDoAtleta(widget.atletaCodigo);
    setState(() {
      _treinos = novosTreinos;
    });
  }

  Future<void> _carregarNotas() async {
    final notas = await _db.getNotasDoAtleta(widget.atletaCodigo);
    if (!mounted) return;
    setState(() {
      _notas = notas;
      _isLoadingNotas = false;
    });
  }

  void _adicionarNota() async {
    final profissional = _db.getProfissionalLogado();
    if (profissional == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profissional nao logado'), backgroundColor: Colors.red),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdicionarNotaPage(
          atletaNome: widget.atletaNome,
          atletaCodigo: widget.atletaCodigo,
          profissionalTipo: widget.profissionalTipo,
          profissionalId: profissional['id'],
          profissionalNome: profissional['nome'],
        ),
      ),
    );

    if (result == true) {
      await _carregarNotas();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.atletaNome),
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
            Tab(text: 'HISTORICO', icon: Icon(Icons.fitness_center)),
            Tab(text: 'NOTAS', icon: Icon(Icons.note)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
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
                        Text('O atleta ${widget.atletaNome} ainda nao finalizou nenhum treino',
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
          _buildNotasTab(),
        ],
      ),
    );
  }

  Widget _buildNotasTab() {
    if (_isLoadingNotas) {
      return const Center(child: CircularProgressIndicator());
    }

    final notas = _notas;

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
        subtitle: Text('Duracao: ${treino.duracaoMinutos} min | Borg: ${treino.escalaBorg}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow('Data', treino.dataFormatada),
                _infoRow('Modalidade', treino.modalidade),
                _infoRow('Duracao', '${treino.duracaoMinutos} minutos'),
                _infoRow('Duracao real', '${treino.duracaoRealSegundos ~/ 60} minutos'),
                const Divider(),
                _infoRow('Temperatura', '${treino.temperatura}°C'),
                _infoRow('Umidade', '${treino.umidade}%'),
                _infoRow('Sensacao termica', '${treino.sensacaoTermica}°C'),
                _infoRow('Vento', treino.vento),
                _infoRow('Exposicao solar', treino.exposicaoSolar),
                const Divider(),
                _infoRow('Ingestao de fluidos', '${treino.fluidosMl} mL'),
                _infoRow('Alimentos com agua', treino.alimentosAgua),
                _infoRow('Volume urinario', '${treino.volumeUrinarioMl} mL'),
                const Divider(),
                _infoRow('Massa corporal pre', '${treino.massaCorporalPreKg} kg'),
                _infoRow('Massa corporal pos', '${treino.massaCorporalPosKg} kg'),
                _infoRow('Perda de massa', '${treino.percentualPerdaMassa.toStringAsFixed(1)}%'),
                _infoRow('Cor da urina', treino.corUrina),
                _infoRow('Vestimenta', treino.vestimenta),
                _infoRow('Equipamento', treino.equipamento),
                const Divider(),
                _infoRow('Escala de Borg', '${treino.escalaBorg}/20'),
                _infoRow('Estava com sede', treino.estaComSede ? 'Sim' : 'Nao'),
                _infoRow('Sintomas pre-treino', treino.sintomasPreDescricao.isNotEmpty ? treino.sintomasPreDescricao : 'Nenhum'),
                _infoRow('Historico de hidratacao', treino.historicoHidratacao),
                const Divider(),
                _infoRow('Roupas encharcadas', treino.roupasEncharcadas ? 'Sim' : 'Nao'),
                _infoRow('Troca de vestimenta', treino.trocaVestimenta ? 'Sim' : 'Nao'),
                if (treino.observacaoRoupas.isNotEmpty) _infoRow('Observacao roupas', treino.observacaoRoupas),
                const Divider(),
                if (widget.profissionalTipo == 'medico') ...[
                  _infoRow('Sintomas gastrointestinais', treino.teveSintomasGastro ? 'Sim' : 'Nao'),
                  if (treino.sintomasDescricao.isNotEmpty) _infoRow('Descricao sintomas', treino.sintomasDescricao),
                  _infoRow('Fadiga', treino.teveFadiga ? 'Sim' : 'Nao'),
                  if (treino.fadigaDescricao.isNotEmpty) _infoRow('Descricao fadiga', treino.fadigaDescricao),
                ],
                if (widget.profissionalTipo == 'nutricionista') ...[
                  _infoRow('Nivel de hidratacao', treino.nivelHidratacao),
                ],
              ],
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black54)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}