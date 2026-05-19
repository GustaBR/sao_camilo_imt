import 'package:flutter/material.dart';
import 'treino_intra_sessao.dart';

class TreinoPreHidratacao extends StatefulWidget {
  const TreinoPreHidratacao({super.key});

  @override
  State<TreinoPreHidratacao> createState() => _TreinoPreHidratacaoState();
}

class _TreinoPreHidratacaoState extends State<TreinoPreHidratacao> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _sintomasController = TextEditingController();
  final TextEditingController _historicoHidratacaoController = TextEditingController();
  bool? _estaComSede;
  bool? _temSintomas;

  @override
  void dispose() {
    _sintomasController.dispose();
    _historicoHidratacaoController.dispose();
    super.dispose();
  }

  void _finalizarPreSessao() {
    if (_estaComSede == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe se está com sede antes do treino.')),
      );
      return;
    }

    if (_temSintomas == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe se sente algum sintoma antes do treino.')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TreinoIntraSessao()),
      );
    }
  }

  Widget _buildOpcaoSimNao({
    required String titulo,
    required bool? valorAtual,
    required ValueChanged<bool?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        RadioGroup<bool>(
          groupValue: valorAtual,
          onChanged: onChanged,
          child: const Column(
            children: [
              RadioListTile<bool>(
                title: Text('Sim'),
                value: true,
                activeColor: Color(0xFFB30000),
              ),
              RadioListTile<bool>(
                title: Text('Não'),
                value: false,
                activeColor: Color(0xFFB30000),
              ),
            ],
          ),
        ),
      ],
    );
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
                'Hidratação e sintomas',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildOpcaoSimNao(
                titulo: 'Está com sede antes do treino?',
                valorAtual: _estaComSede,
                onChanged: (value) {
                  setState(() {
                    _estaComSede = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildOpcaoSimNao(
                titulo: 'Sente algum sintoma antes do treino?',
                valorAtual: _temSintomas,
                onChanged: (value) {
                  setState(() {
                    _temSintomas = value;
                    if (value == false) {
                      _sintomasController.clear();
                    }
                  });
                },
              ),
              if (_temSintomas == true) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _sintomasController,
                  decoration: const InputDecoration(
                    labelText: 'Descreva os sintomas',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (_temSintomas == true && (value == null || value.isEmpty)) {
                      return 'Descreva os sintomas';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 24),
              TextFormField(
                controller: _historicoHidratacaoController,
                decoration: const InputDecoration(
                  labelText: 'Quanta água você bebeu recentemente?',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe a hidratação recente';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _finalizarPreSessao,
                child: const Text('FINALIZAR PRÉ-SESSÃO'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
