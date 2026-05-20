import 'package:flutter/material.dart';
import 'treino_pre_hidratacao.dart';

class TreinoPrePlanejamento extends StatefulWidget {
  const TreinoPrePlanejamento({super.key});

  @override
  State<TreinoPrePlanejamento> createState() => _TreinoPrePlanejamentoState();
}

class _TreinoPrePlanejamentoState extends State<TreinoPrePlanejamento> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _vestimentaController = TextEditingController();
  final TextEditingController _equipamentoController = TextEditingController();
  String? _corUrinaSelecionada;

  final List<Map<String, dynamic>> _coresUrina = [
    {
      'nome': 'Transparente',
      'cor': Color(0xFFE9F7FF),
    },
    {
      'nome': 'Amarelo claro',
      'cor': Color(0xFFFFF6A3),
    },
    {
      'nome': 'Amarelo',
      'cor': Color(0xFFFFE066),
    },
    {
      'nome': 'Amarelo escuro',
      'cor': Color(0xFFF4B942),
    },
    {
      'nome': 'Âmbar',
      'cor': Color(0xFFD88A24),
    },
    {
      'nome': 'Marrom escuro',
      'cor': Color(0xFF8A4B20),
    },
  ];

  @override
  void dispose() {
    _vestimentaController.dispose();
    _equipamentoController.dispose();
    super.dispose();
  }

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
        MaterialPageRoute(builder: (context) => const TreinoPreHidratacao()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pré-sessão'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Planejamento do treino',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Registre a cor da urina, vestimenta e equipamentos.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              const Text(
                'Cor da urina',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _coresUrina.map((opcao) {
                  final String nome = opcao['nome'];
                  final Color cor = opcao['cor'];
                  final bool selecionada = _corUrinaSelecionada == nome;

                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      setState(() {
                        _corUrinaSelecionada = nome;
                      });
                    },
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o tipo de vestimenta';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _equipamentoController,
                decoration: const InputDecoration(
                  labelText: 'Equipamento',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.fitness_center),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o equipamento utilizado';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _avancar,
                child: const Text('PRÓXIMO'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
