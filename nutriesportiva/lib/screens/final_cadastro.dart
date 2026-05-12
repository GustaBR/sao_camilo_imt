import 'package:flutter/material.dart';
import 'home.dart';

class TelaFinalCadastro extends StatefulWidget {
  const TelaFinalCadastro({super.key});

  @override
  State<TelaFinalCadastro> createState() => _TelaFinalCadastroState();
}

class _TelaFinalCadastroState extends State<TelaFinalCadastro> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _alturaController = TextEditingController();
  final TextEditingController _dataNascimentoController = TextEditingController();
  String? _sexoSelecionado;
  DateTime? _dataNascimento;

  final List<String> _opcoesSexo = [
    'Feminino',
    'Masculino',
    'Outro',
    'Prefiro não informar',
  ];

  @override
  void dispose() {
    _alturaController.dispose();
    _dataNascimentoController.dispose();
    super.dispose();
  }

  Future<void> _selecionarDataNascimento() async {
    final DateTime hoje = DateTime.now();
    final DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: hoje,
      firstDate: DateTime(1900),
      lastDate: hoje,
    );

    if (dataSelecionada != null) {
      setState(() {
        _dataNascimento = dataSelecionada;
        _dataNascimentoController.text =
            '${dataSelecionada.day.toString().padLeft(2, '0')}/${dataSelecionada.month.toString().padLeft(2, '0')}/${dataSelecionada.year}';
      });
    }
  }

  void _finalizarCadastro() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB30000),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB30000),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/logo_hydrotrack_horizontal.png',
                    height: 110,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Quase lá!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text('Complete seus dados para finalizar o cadastro'),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<String>(
                    initialValue: _sexoSelecionado,
                    decoration: const InputDecoration(
                      labelText: 'Sexo',
                      border: OutlineInputBorder(),
                    ),
                    items: _opcoesSexo.map((sexo) {
                      return DropdownMenuItem<String>(
                        value: sexo,
                        child: Text(sexo),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _sexoSelecionado = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Selecione o sexo';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _alturaController,
                    decoration: const InputDecoration(
                      labelText: 'Altura (m)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Informe a altura';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dataNascimentoController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Data de nascimento',
                      border: OutlineInputBorder(),
                    ),
                    onTap: _selecionarDataNascimento,
                    validator: (value) {
                      if (_dataNascimento == null || value == null || value.isEmpty) {
                        return 'Informe a data de nascimento';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _finalizarCadastro,
                      child: const Text('CADASTRAR-SE'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
