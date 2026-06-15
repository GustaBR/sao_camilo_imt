import 'package:flutter/material.dart';
import 'treino_intra_sessao.dart';
import '../../../services/radio_group.dart';

class TreinoPreHidratacao extends StatefulWidget {
  final double massaCorporalPre;
  final String modalidade;
  final int duracaoPrevista;
  final int temperatura;
  final int umidade;
  final double sensacaoTermica;
  final String vento;
  final String exposicaoSolar;
  final String corUrina;
  final String vestimenta;
  final String equipamento;

  const TreinoPreHidratacao({
    super.key,
    required this.massaCorporalPre,
    required this.modalidade,
    required this.duracaoPrevista,
    required this.temperatura,
    required this.umidade,
    required this.sensacaoTermica,
    required this.vento,
    required this.exposicaoSolar,
    required this.corUrina,
    required this.vestimenta,
    required this.equipamento,
  });

  @override
  State<TreinoPreHidratacao> createState() => _TreinoPreHidratacaoState();
}

class _TreinoPreHidratacaoState extends State<TreinoPreHidratacao> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _sintomasController = TextEditingController();
  final TextEditingController _historicoHidratacaoController = TextEditingController();
  bool? _estaComSede;
  bool? _temSintomas;

  void _finalizarPreSessao() {
    if (_estaComSede == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe se está com sede antes do treino.')));
      return;
    }
    if (_temSintomas == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe se sente algum sintoma antes do treino.')));
      return;
    }
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TreinoIntraSessao(
            massaCorporalPre: widget.massaCorporalPre,
            modalidade: widget.modalidade,
            duracaoPrevista: widget.duracaoPrevista,
            temperatura: widget.temperatura,
            umidade: widget.umidade,
            sensacaoTermica: widget.sensacaoTermica,
            vento: widget.vento,
            exposicaoSolar: widget.exposicaoSolar,
            corUrina: widget.corUrina,
            vestimenta: widget.vestimenta,
            equipamento: widget.equipamento,
            estaComSede: _estaComSede!,
            sintomasDescricao: _temSintomas == true ? _sintomasController.text : '',
            historicoHidratacao: _historicoHidratacaoController.text,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pré-sessão - Hidratação'),
        centerTitle: true,
        backgroundColor: const Color(0xFFB30000),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text('Hidratação e sintomas', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              const Text('Está com sede antes do treino?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              CustomRadioGroup(
                value: _estaComSede,
                onChanged: (v) => setState(() => _estaComSede = v),
              ),
              const SizedBox(height: 24),
              const Text('Sente algum sintoma antes do treino?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              CustomRadioGroup(
                value: _temSintomas,
                onChanged: (v) => setState(() => _temSintomas = v),
              ),
              if (_temSintomas == true) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _sintomasController,
                  decoration: const InputDecoration(labelText: 'Descreva os sintomas', border: OutlineInputBorder()),
                  maxLines: 3,
                  validator: (v) => v!.isEmpty ? 'Descreva os sintomas' : null,
                ),
              ],
              const SizedBox(height: 24),
              TextFormField(
                controller: _historicoHidratacaoController,
                decoration: const InputDecoration(labelText: 'Quanta água você bebeu recentemente?', border: OutlineInputBorder()),
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Informe a hidratação recente' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _finalizarPreSessao,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFB30000),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('FINALIZAR PRÉ-SESSÃO', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}