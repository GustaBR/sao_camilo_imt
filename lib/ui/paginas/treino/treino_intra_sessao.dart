import 'dart:async';
import 'package:flutter/material.dart';
import 'treino_pos_sessao.dart';

class TreinoIntraSessao extends StatefulWidget {
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
  final bool estaComSede;
  final String sintomasDescricao;
  final String historicoHidratacao;

  const TreinoIntraSessao({
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
    required this.estaComSede,
    required this.sintomasDescricao,
    required this.historicoHidratacao,
  });

  @override
  State<TreinoIntraSessao> createState() => _TreinoIntraSessaoState();
}

class _TreinoIntraSessaoState extends State<TreinoIntraSessao> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _volumePersonalizadoController = TextEditingController();
  final TextEditingController _alimentosController = TextEditingController();
  final TextEditingController _volumeUrinarioController = TextEditingController();
  int _totalFluidosMl = 0;
  int _segundosTreino = 0;
  Timer? _timerTreino;
  bool _timerRodando = false;

  String get _tempoFormatado {
    final horas = _segundosTreino ~/ 3600;
    final minutos = (_segundosTreino % 3600) ~/ 60;
    final segundos = _segundosTreino % 60;
    return '${horas.toString().padLeft(2, '0')}:${minutos.toString().padLeft(2, '0')}:${segundos.toString().padLeft(2, '0')}';
  }

  void _iniciarTimer() {
    if (_timerRodando) return;
    setState(() => _timerRodando = true);
    _timerTreino = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _segundosTreino++);
    });
  }

  void _pausarTimer() {
    _timerTreino?.cancel();
    setState(() => _timerRodando = false);
  }

  void _adicionarFluido(int volume) {
    setState(() => _totalFluidosMl += volume);
  }

  void _finalizarIntraSessao() {
    if (_totalFluidosMl <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registre pelo menos uma ingestão de fluidos.')));
      return;
    }
    if (_formKey.currentState!.validate()) {
      _pausarTimer();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TreinoPosSessao(
            massaCorporalPre: widget.massaCorporalPre,
            modalidade: widget.modalidade,
            duracaoPrevista: widget.duracaoPrevista,
            duracaoRealSegundos: _segundosTreino,
            fluidosIngeridosMl: _totalFluidosMl,
            alimentosAgua: _alimentosController.text,
            volumeUrinarioMl: int.parse(_volumeUrinarioController.text),
            temperatura: widget.temperatura,
            umidade: widget.umidade,
            sensacaoTermica: widget.sensacaoTermica,
            vento: widget.vento,
            exposicaoSolar: widget.exposicaoSolar,
            corUrina: widget.corUrina,
            vestimenta: widget.vestimenta,
            equipamento: widget.equipamento,
            estaComSede: widget.estaComSede,
            sintomasDescricao: widget.sintomasDescricao,
            historicoHidratacao: widget.historicoHidratacao,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Intra-sessão'),
        centerTitle: true,
        backgroundColor: const Color(0xFFB30000),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text('Durante o treino', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    const Text('Tempo de treino', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    Text(_tempoFormatado, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFFB30000))),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _iniciarTimer,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFFB30000)),
                            child: Text(_segundosTreino == 0 ? 'INICIAR' : 'CONTINUAR', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _timerRodando ? _pausarTimer : null,
                            child: const Text('PAUSAR', style: TextStyle(fontSize: 14)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    const Text('Total de fluidos ingeridos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    Text('$_totalFluidosMl mL', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFFB30000))),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('Registre sua ingestão de fluidos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _adicionarFluido(200),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFFB30000)),
                      child: const Text('Copo\n+200 mL', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _adicionarFluido(500),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFFB30000)),
                      child: const Text('Squeeze\n+500 mL', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _adicionarFluido(750),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFFB30000)),
                      child: const Text('Garrafa\n+750 mL', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _volumePersonalizadoController,
                      decoration: const InputDecoration(labelText: 'Outro volume (mL)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => _adicionarFluido(int.tryParse(_volumePersonalizadoController.text) ?? 0),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFFB30000)),
                    child: const Text('ADICIONAR', style: TextStyle(fontSize: 14)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _alimentosController,
                decoration: const InputDecoration(labelText: 'Alimentos com água relevante', border: OutlineInputBorder()),
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Informe os alimentos' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _volumeUrinarioController,
                decoration: const InputDecoration(labelText: 'Volume urinário durante a sessão (mL)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Informe o volume urinário' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _finalizarIntraSessao,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFB30000),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('FINALIZAR INTRA-SESSÃO', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}