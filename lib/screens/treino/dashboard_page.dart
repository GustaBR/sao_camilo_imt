import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // 0 = Perfil/Início, 1 = Nova Sessão, 2 = Histórico/Relatórios
  int _telaAtiva = 0;

  // Controllers para a tela de informações do treino
  final _formKeyTreino = GlobalKey<FormState>();
  final TextEditingController _modalidadeController = TextEditingController();
  final TextEditingController _duracaoController = TextEditingController();
  String? _intensidadeSelecionada;

  // Variável que guarda se existe um treino rodando no momento (Null = Nenhum treino)
  Map<String, String>? _treinoEmProgresso;

  // Lista dinâmica do Histórico de Treinos (Começa com alguns dados fictícios)
  final List<Map<String, String>> _historicoTreinos = [
    {'data': '18/05/2026', 'modalidade': 'Corrida de Rua', 'duracao': '75 min', 'intensidade': 'Alta', 'fluidos': '750 mL'},
    {'data': '15/05/2026', 'modalidade': 'Musculação', 'duracao': '50 min', 'intensidade': 'Média', 'fluidos': '500 mL'},
  ];

  @override
  void dispose() {
    _modalidadeController.dispose();
    _duracaoController.dispose();
    super.dispose();
  }

  // Função para finalizar o treino atual e mandar para o histórico usando data nativa
  void _finalizarTreinoAtual() {
    if (_treinoEmProgresso != null) {
      final agora = DateTime.now();
      final dataFormatada = "${agora.day.toString().padLeft(2, '0')}/${agora.month.toString().padLeft(2, '0')}/${agora.year}";

      setState(() {
        _historicoTreinos.insert(0, {
          'data': dataFormatada, 
          'modalidade': _treinoEmProgresso!['modalidade']!,
          'duracao': '${_treinoEmProgresso!['duracao']!} min',
          'intensidade': _treinoEmProgresso!['intensidade']!,
          'fluidos': 'Calculando...', 
        });
        
        _treinoEmProgresso = null; 
        _telaAtiva = 2; 
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sessão finalizada e salva no histórico!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0), 
      body: Column(
        children: [
          _buildNavBarHeader(), 
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 900), 
                  child: _renderizarTelaAtiva(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- COMPONENTE: NAVBAR SUPERIOR ---
  Widget _buildNavBarHeader() {
    return Container(
      color: const Color(0xFFB30000),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const Row(
              children: [
                Icon(Icons.gpp_good, color: Colors.white, size: 28),
                SizedBox(width: 8),
                Text(
                  'NUTRIESPORTIVA\nSÃO CAMILO',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5),
                ),
              ],
            ),
            const Spacer(),
            _buildTabItem('Início', 0),
            const SizedBox(width: 16),
            _buildTabItem('Iniciar sessão', 1),
            const SizedBox(width: 16),
            _buildTabItem('Histórico', 2),
            const SizedBox(width: 24),
            const CircleAvatar(
              backgroundColor: Colors.white,
              radius: 18,
              child: Text(
                'NS',
                style: TextStyle(color: Color(0xFFB30000), fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(String titulo, int index) {
    bool ativo = _telaAtiva == index;
    return TextButton(
      onPressed: () => setState(() => _telaAtiva = index),
      style: TextButton.styleFrom(padding: EdgeInsets.zero),
      child: Text(
        titulo,
        style: TextStyle(
          color: Colors.white,
          fontWeight: ativo ? FontWeight.bold : FontWeight.normal,
          decoration: ativo ? TextDecoration.underline : TextDecoration.none,
          decorationThickness: 2,
        ),
      ),
    );
  }

  Widget _renderizarTelaAtiva() {
    switch (_telaAtiva) {
      case 0:
        return _buildTelaPerfilGraficos();
      case 1:
        return _buildTelaInformacoesTreino();
      case 2:
        return _buildTelaHistoricoAtleta();
      default:
        return _buildTelaPerfilGraficos();
    }
  }

  // --- TELA 1: PERFIL / INÍCIO ---
  Widget _buildTelaPerfilGraficos() {
    bool temTreinoAtivo = _treinoEmProgresso != null;

    return Column(
      children: [
        Text(
          temTreinoAtivo ? 'Sessão em progresso ⏱️' : 'Sua última sessão',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 16),

        if (temTreinoAtivo) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Column(
              children: [
                Text(
                  '${_treinoEmProgresso!['modalidade']} - Intensidade ${_treinoEmProgresso!['intensidade']}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87), // Corrigido aqui para Colors.black87
                ),
                const SizedBox(height: 4),
                Text(
                  'Tempo estimado: ${_treinoEmProgresso!['duracao']} minutos',
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _finalizarTreinoAtual,
                  icon: const Icon(Icons.stop, color: Colors.white),
                  label: const Text('Finalizar Sessão', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB30000),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        LayoutBuilder(
          builder: (context, constraints) {
            bool usarRow = constraints.maxWidth > 600;
            return usarRow
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildGraficoCircular('600', 'Ingestão de fluidos (ml)', 0.6, Colors.red),
                      _buildGraficoCircular('-1,87', 'Variação de massa corporal (%)', 0.8, Colors.amber),
                      _buildGraficoCircular('1,0', 'Taxa de Sudorese Estimada (L/h)', 0.3, Colors.red),
                    ],
                  )
                : Column(
                    children: [
                      _buildGraficoCircular('600', 'Ingestão de fluidos (ml)', 0.6, Colors.red),
                      const SizedBox(height: 24),
                      _buildGraficoCircular('-1,87', 'Variação de massa corporal (%)', 0.8, Colors.amber),
                      const SizedBox(height: 24),
                      _buildGraficoCircular('1,0', 'Taxa de Sudorese Estimada (L/h)', 0.3, Colors.red),
                    ],
                  );
          },
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFB30000), shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.red.withOpacity(0.4), shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.red.withOpacity(0.4), shape: BoxShape.circle)),
          ],
        )
      ],
    );
  }

  Widget _buildGraficoCircular(String valor, String legenda, double percentual, Color corDestaque) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 140,
              height: 140,
              child: CircularProgressIndicator(
                value: percentual,
                strokeWidth: 10,
                backgroundColor: Colors.white,
                valueColor: AlwaysStoppedAnimation<Color>(corDestaque),
              ),
            ),
            Text(
              valor,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: corDestaque == Colors.amber ? Colors.amber : Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          legenda,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // --- TELA 2: INFORMAÇÕES PARA O TREINO ---
  Widget _buildTelaInformacoesTreino() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500), 
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Form(
        key: _formKeyTreino,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Nos conte um pouco sobre a sua sessão',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 32),
            
            TextFormField(
              controller: _modalidadeController, 
              decoration: _inputStyle('Modalidade'),
              validator: (v) => v!.isEmpty ? 'Insira a modalidade' : null,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _duracaoController, 
              decoration: _inputStyle('Duração estimada (em minutos)'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) => v!.isEmpty ? 'Insira a duração' : null,
            ),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              value: _intensidadeSelecionada,
              decoration: _inputStyle('Intensidade'),
              dropdownColor: const Color(0xFFEBEBEB),
              hint: const Text('Selecione a Intensidade', style: TextStyle(color: Colors.black38)),
              validator: (v) => v == null ? 'Selecione a intensidade' : null,
              items: const [
                DropdownMenuItem(value: 'Baixa', child: Text('Baixa Intensidade')),
                DropdownMenuItem(value: 'Média', child: Text('Média Intensidade')),
                DropdownMenuItem(value: 'Alta', child: Text('Alta Intensidade')),
              ],
              onChanged: (valor) => setState(() => _intensidadeSelecionada = valor),
            ),
            const SizedBox(height: 32),
            
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_formKeyTreino.currentState!.validate()) {
                    setState(() {
                      _treinoEmProgresso = {
                        'modalidade': _modalidadeController.text,
                        'duracao': _duracaoController.text,
                        'intensidade': _intensidadeSelecionada ?? 'Média'
                      };
                      
                      _modalidadeController.clear();
                      _duracaoController.clear();
                      _intensidadeSelecionada = null;
                      _telaAtiva = 0; 
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sessão iniciada com sucesso!')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB30000),
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Seguinte', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38),
      filled: true,
      fillColor: const Color(0xFFEBEBEB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  // --- TELA 3: HISTÓRICO DE TREINOS ---
  Widget _buildTelaHistoricoAtleta() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Histórico de Sessões',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        _historicoTreinos.isEmpty
            ? const Center(child: Text('Nenhum treino salvo no histórico ainda.', style: TextStyle(color: Colors.white70)))
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _historicoTreinos.length,
                itemBuilder: (context, index) {
                  final item = _historicoTreinos[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 2,
                    child: ListTile(
                      leading: const Icon(Icons.fitness_center, color: Color(0xFFB30000), size: 32),
                      title: Text(item['modalidade']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Data: ${item['data']} | Duração: ${item['duracao']} | Int: ${item['intensidade']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.local_drink, color: Colors.blue, size: 18),
                          const SizedBox(width: 4),
                          Text(item['fluidos']!, style: const TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }
}