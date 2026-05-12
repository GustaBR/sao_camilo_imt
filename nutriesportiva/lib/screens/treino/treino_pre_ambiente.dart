import 'package:flutter/material.dart';
import 'treino_pre_planejamento.dart';

class TreinoPreAmbiente extends StatefulWidget {
  const TreinoPreAmbiente({super.key});

  @override
  State<TreinoPreAmbiente> createState() => _TreinoPreAmbienteState();
}

class _TreinoPreAmbienteState extends State<TreinoPreAmbiente> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _temperaturaController = TextEditingController();
  final TextEditingController _umidadeController = TextEditingController();
  final TextEditingController _sensacaoTermicaController = TextEditingController();
  final TextEditingController _ventoController = TextEditingController();
  String? _exposicaoSolar;

  final List<String> _opcoesExposicaoSolar = [
    'Sem exposição direta',
    'Exposição leve',
    'Exposição moderada',
    'Exposição intensa',
  ];

  @override
  void dispose() {
    _temperaturaController.dispose();
    _umidadeController.dispose();
    _sensacaoTermicaController.dispose();
    _ventoController.dispose();
    super.dispose();
  }

  void _avancar() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TreinoPrePlanejamento()),
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
                'Condições ambientais',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Informe o ambiente em que o treino será realizado.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _temperaturaController,
                decoration: const InputDecoration(
                  labelText: 'Temperatura (°C)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.thermostat),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe a temperatura';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _umidadeController,
                decoration: const InputDecoration(
                  labelText: 'Umidade (%)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.water_drop),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe a umidade';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _sensacaoTermicaController,
                decoration: const InputDecoration(
                  labelText: 'Sensação térmica (°C)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.dew_point),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe a sensação térmica';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ventoController,
                decoration: const InputDecoration(
                  labelText: 'Vento',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.air),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe as condições de vento';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _exposicaoSolar,
                decoration: const InputDecoration(
                  labelText: 'Exposição solar',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.wb_sunny),
                ),
                items: _opcoesExposicaoSolar.map((opcao) {
                  return DropdownMenuItem(
                    value: opcao,
                    child: Text(opcao),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _exposicaoSolar = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Selecione a exposição solar';
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
