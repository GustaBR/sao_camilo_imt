import 'package:flutter/material.dart';
import 'treino_pre_ambiente.dart';

class TreinoPreSessao extends StatefulWidget {
  const TreinoPreSessao({super.key});

  @override
  State<TreinoPreSessao> createState() => _TreinoPreSessaoState();
}

class _TreinoPreSessaoState extends State<TreinoPreSessao> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _massaCorporalController = TextEditingController();
  final TextEditingController _modalidadeController = TextEditingController();
  final TextEditingController _duracaoPrevistaController = TextEditingController();

  @override
  void dispose() {
    _massaCorporalController.dispose();
    _modalidadeController.dispose();
    _duracaoPrevistaController.dispose();
    super.dispose();
  }

  void _avancar() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TreinoPreAmbiente()),
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
                'Dados iniciais do treino',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Informe os dados antes do inicio da sessão.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _massaCorporalController,
                decoration: const InputDecoration(
                  labelText: 'Massa corporal pré-exercício (kg)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.monitor_weight),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe a massa corporal';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _modalidadeController,
                decoration: const InputDecoration(
                  labelText: 'Modalidade',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.sports),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe a modalidade';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _duracaoPrevistaController,
                decoration: const InputDecoration(
                  labelText: 'Duração prevista (min)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.timer),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe a duração prevista';
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
