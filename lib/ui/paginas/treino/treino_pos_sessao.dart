import 'package:flutter/material.dart';

class TreinoPosSessao extends StatefulWidget {
  const TreinoPosSessao({super.key});

  @override
  State<TreinoPosSessao> createState() => _TreinoPosSessaoState();
}

class _TreinoPosSessaoState extends State<TreinoPosSessao> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _massaCorporalController = TextEditingController();
  final TextEditingController _observacaoRoupasController = TextEditingController();
  final TextEditingController _sintomasGastroController = TextEditingController();
  final TextEditingController _fadigaController = TextEditingController();
  bool? _roupasEncharcadas;
  bool? _trocaVestimenta;
  bool? _temSintomasGastro;
  bool? _temFadiga;
  int? _borgSelecionado;

  @override
  void dispose() {
    _massaCorporalController.dispose();
    _observacaoRoupasController.dispose();
    _sintomasGastroController.dispose();
    _fadigaController.dispose();
    super.dispose();
  }

  void _finalizarTreino() {
    if (_roupasEncharcadas == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe se as roupas ficaram muito encharcadas.')),
      );
      return;
    }

    if (_trocaVestimenta == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe se houve troca de vestimenta.')),
      );
      return;
    }

    if (_temSintomasGastro == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe se teve sintomas gastrointestinais.')),
      );
      return;
    }

    if (_temFadiga == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe se teve fadiga.')),
      );
      return;
    }

    if (_borgSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a intensidade na escala de Borg.')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Text("Treino concluído."), // Placeholder
          ),
        ),
        (route) => false,
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
        title: const Text('Pós-sessão'),
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
                'Após o treino',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _massaCorporalController,
                decoration: const InputDecoration(
                  labelText: 'Massa corporal pós-exercício (kg)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe a massa corporal pós-exercício';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _buildOpcaoSimNao(
                titulo: 'As roupas ficaram muito encharcadas?',
                valorAtual: _roupasEncharcadas,
                onChanged: (value) {
                  setState(() {
                    _roupasEncharcadas = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildOpcaoSimNao(
                titulo: 'Houve troca de vestimenta?',
                valorAtual: _trocaVestimenta,
                onChanged: (value) {
                  setState(() {
                    _trocaVestimenta = value;
                    if (value == false && _roupasEncharcadas == false) {
                      _observacaoRoupasController.clear();
                    }
                  });
                },
              ),
              if (_roupasEncharcadas == true || _trocaVestimenta == true) ...[
                const SizedBox(height: 8),
                const Text(
                  'Roupas encharcadas ou troca de vestimenta podem aumentar o erro na medida da massa corporal.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _observacaoRoupasController,
                  decoration: const InputDecoration(
                    labelText: 'Observação sobre roupas ou troca de vestimenta',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if ((_roupasEncharcadas == true || _trocaVestimenta == true) && (value == null || value.isEmpty)) {
                      return 'Descreva a situação das roupas ou troca de vestimenta';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 24),
              DropdownButtonFormField<int>(
                initialValue: _borgSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Escala de Borg para Intensidade Percebida',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(15, (index) {
                  final int valor = index + 6;
                  return DropdownMenuItem<int>(
                    value: valor,
                    child: Text(valor.toString()),
                  );
                }),
                onChanged: (value) {
                  setState(() {
                    _borgSelecionado = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Selecione a intensidade na escala de Borg';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _buildOpcaoSimNao(
                titulo: 'Teve sintomas gastrointestinais?',
                valorAtual: _temSintomasGastro,
                onChanged: (value) {
                  setState(() {
                    _temSintomasGastro = value;
                    if (value == false) {
                      _sintomasGastroController.clear();
                    }
                  });
                },
              ),
              if (_temSintomasGastro == true) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _sintomasGastroController,
                  decoration: const InputDecoration(
                    labelText: 'Descreva os sintomas gastrointestinais',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (_temSintomasGastro == true && (value == null || value.isEmpty)) {
                      return 'Descreva os sintomas gastrointestinais';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 24),
              _buildOpcaoSimNao(
                titulo: 'Sentiu fadiga?',
                valorAtual: _temFadiga,
                onChanged: (value) {
                  setState(() {
                    _temFadiga = value;
                    if (value == false) {
                      _fadigaController.clear();
                    }
                  });
                },
              ),
              if (_temFadiga == true) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _fadigaController,
                  decoration: const InputDecoration(
                    labelText: 'Descreva a fadiga',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (_temFadiga == true && (value == null || value.isEmpty)) {
                      return 'Descreva a fadiga';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _finalizarTreino,
                child: const Text('FINALIZAR TREINO'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
