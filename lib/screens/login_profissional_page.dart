import 'package:flutter/material.dart';
import '../services/database_service.dart';
import 'lista_atletas_page.dart';

class LoginProfissionalPage extends StatefulWidget {
  final String tipo;
  const LoginProfissionalPage({super.key, required this.tipo});

  @override
  State<LoginProfissionalPage> createState() => _LoginProfissionalPageState();
}

class _LoginProfissionalPageState extends State<LoginProfissionalPage> {
  final DatabaseService _db = DatabaseService();
  bool _isLoading = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _redirecionar();
  }

  void _redirecionar() async {
    String profissionalId = _db.getProfissionalLogado()?['id'] ?? '';
    
    if (profissionalId.isEmpty) {
      setState(() {
        _erro = 'Nenhum profissional logado';
        _isLoading = false;
      });
      return;
    }
    
    var profissional = _db.getProfissional(profissionalId);
    if (profissional == null) {
      setState(() {
        _erro = 'Profissional não encontrado';
        _isLoading = false;
      });
      return;
    }
    
    List<Map<String, dynamic>> atletas = await _db.getAtletasDoProfissional(profissionalId);
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ListaAtletasPage(
            profissionalNome: profissional['nome'],
            profissionalTipo: widget.tipo,
            profissionalId: profissionalId,
            atletas: atletas,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tipo == 'medico' ? 'Acesso Médico' : 'Acesso Nutricionista'),
        backgroundColor: widget.tipo == 'medico' ? const Color(0xFFB30000) : Colors.green,
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(_erro ?? 'Erro desconhecido'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('VOLTAR'),
                  ),
                ],
              ),
      ),
    );
  }
}
