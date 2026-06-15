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
  String? _sexoSelecionado;

  final TextEditingController _dataNascimentoController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  void dispose() {
    _dataNascimentoController.dispose();
    _pesoController.dispose();
    _alturaController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    final atleta = await _db.getAtleta(widget.codigo);
    final treinos = await _db.getTreinosDoAtleta(widget.codigo);
    if (!mounted) return;

    if (atleta != null) {
      _dadosAtleta = atleta;
      _dataNascimentoController.text = _dadosAtleta['dataNascimento']?.toString() ?? '';
      _pesoController.text = _dadosAtleta['peso']?.toString() ?? '';
      _alturaController.text = _dadosAtleta['altura']?.toString() ?? '';
      _sexoSelecionado = _dadosAtleta['sexo']?.toString();
    }
    _treinos = treinos;
    setState(() => _isLoading = false);
  }

  double? _lerDecimal(String valor) {
    return double.tryParse(valor.trim().replaceAll(',', '.'));
  }

  Future<void> _salvarDadosAdicionais() async {
    final dataNascimento = _dataNascimentoController.text.trim();

    if (dataNascimento.isNotEmpty &&
        (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dataNascimento) ||
            DateTime.tryParse(dataNascimento) == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe a data no formato AAAA-MM-DD'), backgroundColor: Colors.red),
      );
      return;
    }

    final atletaAtualizado = await _db.atualizarDadosAtleta(
      widget.codigo,
      peso: _pesoController.text.isNotEmpty ? _lerDecimal(_pesoController.text) : null,
      altura: _alturaController.text.isNotEmpty ? _lerDecimal(_alturaController.text) : null,
      dataNascimento: dataNascimento.isNotEmpty ? dataNascimento : null,
      sexo: _sexoSelecionado,
    );
    if (!mounted) return;

    if (atletaAtualizado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao atualizar dados'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _dadosAtleta = atletaAtualizado;
      _sexoSelecionado = atletaAtualizado['sexo']?.toString();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dados atualizados!'), backgroundColor: Colors.green),
    );
  }

  Future<void> _sair() async {
    await _db.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  int get _totalTreinos => _treinos.length;
  int get _totalHoras => _treinos.fold(0, (sum, t) => sum + t.duracaoMinutos) ~/ 60;
  double get _mediaBorg => _treinos.isEmpty ? 0 : _treinos.fold(0, (sum, t) => sum + t.escalaBorg) / _treinos.length;
  double get _mediaPerdaMassa => _treinos.isEmpty ? 0 : _treinos.fold(0.0, (sum, t) => sum + t.percentualPerdaMassa) / _treinos.length;

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
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _sair, tooltip: 'Sair'),
        ],
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
                    const Text('Seu código exclusivo', style: TextStyle(color: Colors.white, fontSize: 16)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: SelectableText(
                        widget.codigo,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 4, color: Color(0xFFB30000)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Compartilhe este código com seu Médico e Nutricionista',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
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
                        Text('Informações Pessoais', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(height: 24),
                    ListTile(leading: const Icon(Icons.badge, color: Colors.grey), title: const Text('Nome completo'), subtitle: Text(_dadosAtleta['nome'] ?? 'Não informado'), dense: true),
                    ListTile(leading: const Icon(Icons.email, color: Colors.grey), title: const Text('E-mail'), subtitle: Text(_dadosAtleta['email'] ?? 'Não informado'), dense: true),
                    const Divider(),
                    ListTile(leading: const Icon(Icons.cake, color: Colors.grey), title: const Text('Data de nascimento'), subtitle: TextField(controller: _dataNascimentoController, decoration: const InputDecoration(hintText: 'AAAA-MM-DD', border: InputBorder.none), keyboardType: TextInputType.datetime, style: const TextStyle(fontSize: 14)), dense: true),
                    ListTile(leading: const Icon(Icons.calendar_today, color: Colors.grey), title: const Text('Idade'), subtitle: Text(_dadosAtleta['idade'] == null ? 'Não informado' : '${_dadosAtleta['idade']} anos'), dense: true),
                    ListTile(leading: const Icon(Icons.monitor_weight, color: Colors.grey), title: const Text('Peso (kg)'), subtitle: TextField(controller: _pesoController, decoration: const InputDecoration(hintText: 'Digite seu peso', border: InputBorder.none), keyboardType: TextInputType.number, style: const TextStyle(fontSize: 14)), dense: true),
                    ListTile(leading: const Icon(Icons.height, color: Colors.grey), title: const Text('Altura (cm)'), subtitle: TextField(controller: _alturaController, decoration: const InputDecoration(hintText: 'Digite sua altura', border: InputBorder.none), keyboardType: TextInputType.number, style: const TextStyle(fontSize: 14)), dense: true),
                    ListTile(
                      leading: const Icon(Icons.wc, color: Colors.grey),
                      title: const Text('Sexo'),
                      subtitle: DropdownButton<String>(
                        value: _sexoSelecionado,
                        isExpanded: true,
                        underline: const SizedBox.shrink(),
                        items: const [
                          DropdownMenuItem(value: 'masculino', child: Text('Masculino')),
                          DropdownMenuItem(value: 'feminino', child: Text('Feminino')),
                          DropdownMenuItem(value: 'outro', child: Text('Outro')),
                          DropdownMenuItem(value: 'nao_informado', child: Text('Prefiro não informar')),
                        ],
                        onChanged: (value) => setState(() => _sexoSelecionado = value),
                      ),
                      dense: true,
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _salvarDadosAdicionais,
                        icon: const Icon(Icons.save),
                        label: const Text('SALVAR ALTERAÇÕES'),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB30000), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      ),
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
                        Text('Estatísticas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        _buildEstatisticaCard(titulo: 'Total de Treinos', valor: _totalTreinos.toString(), icone: Icons.fitness_center, cor: const Color(0xFFB30000)),
                        const SizedBox(width: 12),
                        _buildEstatisticaCard(titulo: 'Total de Horas', valor: '$_totalHoras h', icone: Icons.timer, cor: const Color(0xFFB30000)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildEstatisticaCard(titulo: 'Média Borg', valor: _mediaBorg.toStringAsFixed(1), icone: Icons.speed, cor: const Color(0xFFB30000)),
                        const SizedBox(width: 12),
                        _buildEstatisticaCard(titulo: 'Média Perda %', valor: '${_mediaPerdaMassa.toStringAsFixed(1)}%', icone: Icons.water_drop, cor: const Color(0xFFB30000)),
                      ],
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
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pushNamed(context, '/atleta/treino'),
                        icon: const Icon(Icons.fitness_center),
                        label: const Text('VER DASHBOARD DE TREINOS'),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB30000), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      ),
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

  Widget _buildEstatisticaCard({required String titulo, required String valor, required IconData icone, required Color cor}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: cor.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: cor.withOpacity(0.2))),
        child: Column(
          children: [
            Icon(icone, color: cor, size: 28),
            const SizedBox(height: 8),
            Text(valor, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: cor)),
            Text(titulo, style: const TextStyle(fontSize: 11, color: Colors.grey), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
