import 'package:flutter/material.dart';
import 'treino_pre_hidratacao.dart';
import '../../../services/database_service.dart';
import '../../../models/sessao_treino.dart';

class TreinoPrePlanejamento extends StatefulWidget {
  final double massaCorporalPre;
  final String modalidade;
  final int duracaoPrevista;
  final int temperatura;
  final int umidade;
  final double sensacaoTermica;
  final String vento;
  final String exposicaoSolar;

  const TreinoPrePlanejamento({
    super.key,
    required this.massaCorporalPre,
    required this.modalidade,
    required this.duracaoPrevista,
    required this.temperatura,
    required this.umidade,
    required this.sensacaoTermica,
    required this.vento,
    required this.exposicaoSolar,
  });

  @override
  State<TreinoPrePlanejamento> createState() => _TreinoPrePlanejamentoState();
}

class _TreinoPrePlanejamentoState extends State<TreinoPrePlanejamento> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _vestimentaController = TextEditingController();
  final TextEditingController _equipamentoController = TextEditingController();
  String? _corUrinaSelecionada;

  final List<Map<String, dynamic>> _coresUrina = [
    {'nome': 'Transparente', 'cor': Color(0xFFE9F7FF)},
    {'nome': 'Amarelo claro', 'cor': Color(0xFFFFF6A3)},
    {'nome': 'Amarelo', 'cor': Color(0xFFFFE066)},
    {'nome': 'Amarelo escuro', 'cor': Color(0xFFF4B942)},
    {'nome': 'Âmbar', 'cor': Color(0xFFD88A24)},
    {'nome': 'Marrom escuro', 'cor': Color(0xFF8A4B20)},
  ];

  void _avancar() {
    if (_corUrinaSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a cor da urina.')),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TreinoPreHidratacao(
            massaCorporalPre: widget.massaCorporalPre,
            modalidade: widget.modalidade,
            duracaoPrevista: widget.duracaoPrevista,
            temperatura: widget.temperatura,
            umidade: widget.umidade,
            sensacaoTermica: widget.sensacaoTermica,
            vento: widget.vento,
            exposicaoSolar: widget.exposicaoSolar,
            corUrina: _corUrinaSelecionada!,
            vestimenta: _vestimentaController.text,
            equipamento: _equipamentoController.text,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pré-sessão - Planejamento'),
        centerTitle: true,
        backgroundColor: const Color(0xFFB30000),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Planejamento do treino',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Registre a cor da urina, vestimenta e equipamentos.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 32),
              const Text(
                'Cor da urina',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _coresUrina.map((opcao) {
                  final nome = opcao['nome'];
                  final cor = opcao['cor'];
                  final selecionada = _corUrinaSelecionada == nome;
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setState(() => _corUrinaSelecionada = nome),
                    child: Container(
                      width: 140,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selecionada ? const Color(0xFFB30000) : Colors.grey,
                          width: selecionada ? 3 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: cor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black26),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            nome,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: selecionada ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _vestimentaController,
                decoration: const InputDecoration(
                  labelText: 'Tipo de vestimenta',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.checkroom),
                ),
                validator: (v) => v!.isEmpty ? 'Informe o tipo de vestimenta' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _equipamentoController,
                decoration: const InputDecoration(
                  labelText: 'Equipamento',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.fitness_center),
                ),
                validator: (v) => v!.isEmpty ? 'Informe o equipamento utilizado' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _avancar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB30000),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('PRÓXIMO', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}