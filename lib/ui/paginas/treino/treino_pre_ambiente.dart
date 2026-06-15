import 'package:flutter/material.dart';
import 'treino_pre_planejamento.dart';
import '../../../services/weather_service.dart';

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
        MaterialPageRoute(
          builder: (context) => TreinoPrePlanejamento(
            massaCorporalPre: widget.massaCorporalPre,
            modalidade: widget.modalidade,
            duracaoPrevista: widget.duracaoPrevista,
            temperatura: double.parse(_temperaturaController.text.replaceAll(',', '.')).round(),
            umidade: double.parse(_umidadeController.text.replaceAll(',', '.')).round(),
            sensacaoTermica: double.parse(_sensacaoTermicaController.text.replaceAll(',', '.')),
            vento: _ventoController.text,
            exposicaoSolar: _exposicaoSolar!,
          ),
        ),
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
      if (!mounted) return;

      final exposicaoSolar = _opcaoExposicaoSolarPorCodigo(clima.exposicaoSolarCodigo);

      setState(() {
        _temperaturaController.text = clima.temperatura.round().toString();
        _umidadeController.text = clima.umidade?.round().toString() ?? '';
        _sensacaoTermicaController.text = clima.sensacaoTermica?.toStringAsFixed(1) ?? '';
        _ventoController.text = clima.vento;
        if (exposicaoSolar != null) {
          _exposicaoSolar = exposicaoSolar;
        }
        _mensagemClima = 'Dados climáticos preenchidos pela localização atual.';
      });
    } on WeatherException catch (error) {
      if (!mounted) return;
      setState(() {
        _mensagemClima = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _mensagemClima = 'Não foi possível preencher o clima automaticamente.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _carregandoClima = false;
        });
      }
    }
  }

  String? _validarNumero(String? valor, String mensagem) {
    if (valor == null || valor.trim().isEmpty) {
      return mensagem;
    }
    if (double.tryParse(valor.replaceAll(',', '.')) == null) {
      return 'Informe um número válido';
    }
    return null;
  }

  String? _opcaoExposicaoSolarPorCodigo(String? codigo) {
    switch (codigo) {
      case 'sem_direta': return _opcoesExposicaoSolar[0];
      case 'leve': return _opcoesExposicaoSolar[1];
      case 'moderada': return _opcoesExposicaoSolar[2];
      case 'intensa': return _opcoesExposicaoSolar[3];
      default: return null;
    }
  }

  Widget _buildStatusClima() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (_carregandoClima)
            const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
          else
            const Icon(Icons.my_location, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _carregandoClima
                  ? 'Buscando clima pela localização...'
                  : _mensagemClima ?? 'Clima automático pela localização.',
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
              const Text('Condições ambientais', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Informe o ambiente em que o treino será realizado.', style: TextStyle(fontSize: 16, color: Colors.black54)),
              const SizedBox(height: 16),
              _buildStatusClima(),
              const SizedBox(height: 32),
              TextFormField(
                controller: _temperaturaController,
                decoration: const InputDecoration(labelText: 'Temperatura (°C)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.thermostat)),
                keyboardType: TextInputType.number,
                validator: (v) => _validarNumero(v, 'Informe a temperatura'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _umidadeController,
                decoration: const InputDecoration(labelText: 'Umidade (%)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.water_drop)),
                keyboardType: TextInputType.number,
                validator: (v) => _validarNumero(v, 'Informe a umidade'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _sensacaoTermicaController,
                decoration: const InputDecoration(labelText: 'Sensação térmica (°C)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.dew_point)),
                keyboardType: TextInputType.number,
                validator: (v) => _validarNumero(v, 'Informe a sensação térmica'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ventoController,
                decoration: const InputDecoration(labelText: 'Vento', border: OutlineInputBorder(), prefixIcon: Icon(Icons.air)),
                validator: (v) => v!.isEmpty ? 'Informe as condições de vento' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _exposicaoSolar,
                decoration: const InputDecoration(labelText: 'Exposição solar', border: OutlineInputBorder(), prefixIcon: Icon(Icons.wb_sunny)),
                items: _opcoesExposicaoSolar.map((opcao) => DropdownMenuItem(value: opcao, child: Text(opcao))).toList(),
                onChanged: (value) => setState(() => _exposicaoSolar = value),
                validator: (v) => v == null ? 'Selecione a exposição solar' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _avancar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFB30000),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('PRÓXIMO', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}