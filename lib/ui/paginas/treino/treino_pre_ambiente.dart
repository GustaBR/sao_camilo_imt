import 'package:flutter/material.dart';
import 'package:sao_camilo_imt/data/services/weather_service.dart';
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
  final TextEditingController _sensacaoTermicaController =
      TextEditingController();
  final TextEditingController _ventoController = TextEditingController();
  final WeatherService _weatherService = const WeatherService();
  String? _exposicaoSolar;
  bool _carregandoClima = false;
  String? _mensagemClima;

  final List<String> _opcoesExposicaoSolar = [
    'Sem exposição direta',
    'Exposição leve',
    'Exposição moderada',
    'Exposição intensa',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(_carregarClimaAtual);
  }

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

  Future<void> _carregarClimaAtual() async {
    setState(() {
      _carregandoClima = true;
      _mensagemClima = null;
    });

    try {
      final clima = await _weatherService.buscarClimaAtual();

      if (!mounted) {
        return;
      }

      final exposicaoSolar = _opcaoExposicaoSolarPorCodigo(
        clima.exposicaoSolarCodigo,
      );

      setState(() {
        _temperaturaController.text = _formatarNumero(clima.temperatura);
        _umidadeController.text = clima.umidade == null
            ? ''
            : _formatarNumero(clima.umidade!, casasDecimais: 0);
        _sensacaoTermicaController.text = clima.sensacaoTermica == null
            ? ''
            : _formatarNumero(clima.sensacaoTermica!);
        _ventoController.text = clima.vento;
        if (exposicaoSolar != null) {
          _exposicaoSolar = exposicaoSolar;
        }
        _mensagemClima = 'Dados climaticos preenchidos pela localizacao atual.';
      });
    } on WeatherException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _mensagemClima = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _mensagemClima = 'Nao foi possivel preencher o clima automaticamente.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _carregandoClima = false;
        });
      }
    }
  }

  String _formatarNumero(double valor, {int casasDecimais = 1}) {
    return valor.toStringAsFixed(casasDecimais);
  }

  String? _opcaoExposicaoSolarPorCodigo(String? codigo) {
    switch (codigo) {
      case 'sem_direta':
        return _opcoesExposicaoSolar[0];
      case 'leve':
        return _opcoesExposicaoSolar[1];
      case 'moderada':
        return _opcoesExposicaoSolar[2];
      case 'intensa':
        return _opcoesExposicaoSolar[3];
    }

    return null;
  }

  Widget _buildStatusClima() {
    final mensagem = _mensagemClima;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (_carregandoClima) ...[
            const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ] else ...[
            const Icon(Icons.my_location, size: 20),
          ],
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _carregandoClima
                  ? 'Buscando clima pela localizacao...'
                  : mensagem ?? 'Clima automatico pela localizacao.',
            ),
          ),
          IconButton(
            tooltip: 'Atualizar clima',
            onPressed: _carregandoClima ? null : _carregarClimaAtual,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pré-sessão'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Condições ambientais',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Informe o ambiente em que o treino será realizado.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              _buildStatusClima(),
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
                key: ValueKey(_exposicaoSolar),
                initialValue: _exposicaoSolar,
                decoration: const InputDecoration(
                  labelText: 'Exposição solar',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.wb_sunny),
                ),
                items: _opcoesExposicaoSolar.map((opcao) {
                  return DropdownMenuItem(value: opcao, child: Text(opcao));
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
              ElevatedButton(onPressed: _avancar, child: const Text('PRÓXIMO')),
            ],
          ),
        ),
      ),
    );
  }
}
