// pages/login_profissional_page.dart
import 'package:flutter/material.dart';
import '../services/atleta_data_manager.dart';
import 'dashboard_profissional_page.dart';

class LoginProfissionalPage extends StatefulWidget {
  final String tipoProfissional;

  const LoginProfissionalPage({super.key, required this.tipoProfissional});

  @override
  State<LoginProfissionalPage> createState() => _LoginProfissionalPageState();
}

class _LoginProfissionalPageState extends State<LoginProfissionalPage> {
  final TextEditingController _codigoController = TextEditingController();
  final AtletaDataManager _dataManager = AtletaDataManager();

  void _acessar() {
    String codigo = _codigoController.text.trim().toUpperCase();

    if (_dataManager.validarCodigo(codigo)) {
      String nomeAtleta = _dataManager.getNomeAtleta(codigo) ?? 'Atleta';
      List<SessaoTreino> sessoes = _dataManager.getSessoesAtleta(codigo);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardProfissionalPage(
            tipoProfissional: widget.tipoProfissional,
            codigoAtleta: codigo,
            nomeAtleta: nomeAtleta,
            sessoes: sessoes,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código inválido! Verifique e tente novamente.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String titulo;
    IconData icone;
    Color cor;

    switch (widget.tipoProfissional) {
      case 'medico':
        titulo = 'Área do Médico';
        icone = Icons.medical_services;
        cor = const Color(0xFFB30000);
        break;
      case 'instrutor':
        titulo = 'Área do Instrutor';
        icone = Icons.fitness_center;
        cor = Colors.blue;
        break;
      case 'nutricionista':
        titulo = 'Área do Nutricionista';
        icone = Icons.restaurant;
        cor = Colors.green;
        break;
      default:
        titulo = 'Acesso Profissional';
        icone = Icons.lock;
        cor = const Color(0xFFB30000);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
        backgroundColor: cor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, size: 80, color: cor),
            const SizedBox(height: 32),
            const Text(
              'Digite o código fornecido pelo atleta',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _codigoController,
              decoration: InputDecoration(
                labelText: 'Código do atleta',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(icone, color: cor),
                hintText: 'Ex: ABC12345',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, letterSpacing: 2),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _acessar,
              style: ElevatedButton.styleFrom(
                backgroundColor: cor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('ACESSAR DADOS', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}