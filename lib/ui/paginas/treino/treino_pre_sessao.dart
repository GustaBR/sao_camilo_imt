import 'package:flutter/material.dart';
import 'treino_pre_ambiente.dart';
import '../../../services/database_service.dart';

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

  void _avancar() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TreinoPreAmbiente(
            massaCorporalPre: double.parse(_massaCorporalController.text),
            modalidade: _modalidadeController.text,
            duracaoPrevista: int.parse(_duracaoPrevistaController.text),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pré-sessão - Dados Iniciais'),
        centerTitle: true,
        backgroundColor: const Color(0xFFB30000),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text('Dados iniciais do treino', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Informe os dados antes do início da sessão.', style: TextStyle(fontSize: 16, color: Colors.black54)),
              const SizedBox(height: 32),
              TextFormField(
                controller: _massaCorporalController,
                decoration: const InputDecoration(labelText: 'Massa corporal pré-exercício (kg)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.monitor_weight)),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Informe a massa corporal' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _modalidadeController,
                decoration: const InputDecoration(labelText: 'Modalidade', border: OutlineInputBorder(), prefixIcon: Icon(Icons.sports)),
                validator: (v) => v!.isEmpty ? 'Informe a modalidade' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _duracaoPrevistaController,
                decoration: const InputDecoration(labelText: 'Duração prevista (min)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.timer)),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Informe a duração prevista' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _avancar,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB30000), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('PRÓXIMO', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}