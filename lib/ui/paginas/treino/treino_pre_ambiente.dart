import 'package:flutter/material.dart';
import 'treino_pre_planejamento.dart';
import '../../../services/database_service.dart';
import '../../../models/sessao_treino.dart';

class TreinoPreAmbiente extends StatefulWidget {
  final double massaCorporalPre;
  final String modalidade;
  final int duracaoPrevista;

  const TreinoPreAmbiente({
    super.key,
    required this.massaCorporalPre,
    required this.modalidade,
    required this.duracaoPrevista,
  });

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

  void _avancar() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TreinoPrePlanejamento(
            massaCorporalPre: widget.massaCorporalPre,
            modalidade: widget.modalidade,
            duracaoPrevista: widget.duracaoPrevista,
            temperatura: int.parse(_temperaturaController.text),
            umidade: int.parse(_umidadeController.text),
            sensacaoTermica: double.parse(_sensacaoTermicaController.text),
            vento: _ventoController.text,
            exposicaoSolar: _exposicaoSolar!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pré-sessão - Condições Ambientais'),
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
                'Condições ambientais',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Informe o ambiente em que o treino será realizado.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _temperaturaController,
                decoration: const InputDecoration(
                  labelText: 'Temperatura (°C)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.thermostat),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Informe a temperatura' : null,
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
                validator: (v) => v!.isEmpty ? 'Informe a umidade' : null,
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
                validator: (v) => v!.isEmpty ? 'Informe a sensação térmica' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ventoController,
                decoration: const InputDecoration(
                  labelText: 'Vento',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.air),
                ),
                validator: (v) => v!.isEmpty ? 'Informe as condições de vento' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _exposicaoSolar,
                decoration: const InputDecoration(
                  labelText: 'Exposição solar',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.wb_sunny),
                ),
                items: _opcoesExposicaoSolar.map((opcao) {
                  return DropdownMenuItem(value: opcao, child: Text(opcao));
                }).toList(),
                onChanged: (value) => setState(() => _exposicaoSolar = value),
                validator: (v) => v == null ? 'Selecione a exposição solar' : null,
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