import 'dart:async';
import 'package:flutter/material.dart';
import 'treino_pos_sessao.dart';

class TreinoIntraSessao extends StatefulWidget {
  const TreinoIntraSessao({super.key});

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

  @override
  void dispose() {
    _timerTreino?.cancel();
    _volumePersonalizadoController.dispose();
    _alimentosController.dispose();
    _volumeUrinarioController.dispose();
    super.dispose();
  }

  String get _tempoFormatado {
    final int horas = _segundosTreino ~/ 3600;
    final int minutos = (_segundosTreino % 3600) ~/ 60;
    final int segundos = _segundosTreino % 60;

    String doisDigitos(int numero) => numero.toString().padLeft(2, '0');

    return '${doisDigitos(horas)}:${doisDigitos(minutos)}:${doisDigitos(segundos)}';
  }

  void _iniciarOuContinuarTimer() {
    if (_timerRodando) {
      return;
    }

    setState(() {
      _timerRodando = true;
    });

    _timerTreino = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _segundosTreino++;
      });
    });
  }

  void _pausarTimer() {
    _timerTreino?.cancel();
    setState(() {
      _timerRodando = false;
    });
  }

  void _zerarTimer() {
    _timerTreino?.cancel();
    setState(() {
      _segundosTreino = 0;
      _timerRodando = false;
    });
  }

  void _adicionarFluido(int volumeMl) {
    setState(() {
      _totalFluidosMl += volumeMl;
    });
  }

  void _adicionarVolumePersonalizado() {
    final int? volume = int.tryParse(_volumePersonalizadoController.text);

    if (volume == null || volume <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um volume válido em mL.')),
      );
      return;
    }

    _adicionarFluido(volume);
    _volumePersonalizadoController.clear();
  }

  void _removerUltimoAtalho(int volumeMl) {
    setState(() {
      _totalFluidosMl -= volumeMl;
      if (_totalFluidosMl < 0) {
        _totalFluidosMl = 0;
      }
    });
  }

  void _finalizarIntraSessao() {
    if (_totalFluidosMl <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registre pelo menos uma ingestão de fluidos.')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      _pausarTimer();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TreinoPosSessao()),
      );
    }
  }

  Widget _buildAtalhoFluido({
    required String titulo,
    required int volumeMl,
  }) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          _adicionarFluido(volumeMl);
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text('$titulo\n+$volumeMl mL', textAlign: TextAlign.center),
      ),
    );
  }

  Widget _buildTimerTreino() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          const Text(
            'Tempo de treino',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _tempoFormatado,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Color(0xFFB30000),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _iniciarOuContinuarTimer,
                  child: Text(_segundosTreino == 0 ? 'INICIAR' : 'CONTINUAR'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: _timerRodando ? _pausarTimer : null,
                  child: const Text('PAUSAR'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _segundosTreino > 0 ? _zerarTimer : null,
            child: const Text('ZERAR TIMER'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Intra-sessão'),
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
                'Durante o treino',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildTimerTreino(),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Total de fluidos ingeridos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_totalFluidosMl mL',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB30000),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Registre sua ingestão de fluidos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildAtalhoFluido(titulo: 'Copo', volumeMl: 200),
                  const SizedBox(width: 8),
                  _buildAtalhoFluido(titulo: 'Squeeze', volumeMl: 500),
                  const SizedBox(width: 8),
                  _buildAtalhoFluido(titulo: 'Garrafa', volumeMl: 750),
                ],
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  _removerUltimoAtalho(200);
                },
                child: const Text('REMOVER 200 mL'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _volumePersonalizadoController,
                      decoration: const InputDecoration(
                        labelText: 'Outro volume (mL)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _adicionarVolumePersonalizado,
                    child: const Text('ADICIONAR'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _alimentosController,
                decoration: const InputDecoration(
                  labelText: 'Alimentos com água relevante',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe os alimentos consumidos ou escreva "nenhum"';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _volumeUrinarioController,
                decoration: const InputDecoration(
                  labelText: 'Volume urinário durante a sessão (mL)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o volume urinário estimado ou 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _finalizarIntraSessao,
                child: const Text('FINALIZAR INTRA-SESSÃO'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
