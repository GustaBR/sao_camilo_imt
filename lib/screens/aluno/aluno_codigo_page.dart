import 'package:flutter/material.dart';
import '../../services/database_service.dart';

class AlunoCodigoPage extends StatefulWidget {
  const AlunoCodigoPage({super.key});

  @override
  State<AlunoCodigoPage> createState() => _AlunoCodigoPageState();
}

class _AlunoCodigoPageState extends State<AlunoCodigoPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final DatabaseService _db = DatabaseService();
  
  String? _codigoGerado;
  bool _isLoading = false;

  Future<void> _gerarCodigo() async {
    final nome = _nomeController.text.trim();
    final email = _emailController.text.trim();

    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite seu nome'), backgroundColor: Colors.red),
      );
      return;
    }
    
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite seu e-mail'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    String? resultado = await _db.cadastrarAluno(nome, email);

    setState(() => _isLoading = false);

    if (resultado != null) {
      setState(() => _codigoGerado = resultado);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastro realizado! Guarde seu código.'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao gerar código. Tente novamente.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu Código'), backgroundColor: const Color(0xFFB30000)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_codigoGerado == null) ...[
              const Icon(Icons.qr_code_scanner, size: 80, color: Color(0xFFB30000)),
              const SizedBox(height: 24),
              const Text('Cadastre-se para gerar seu código:', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 24),
              TextField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome completo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _gerarCodigo,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('GERAR CÓDIGO'),
                ),
              ),
            ] else ...[
              const Icon(Icons.check_circle, size: 80, color: Colors.green),
              const SizedBox(height: 24),
              const Text('Seu código exclusivo (único e permanente):', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFB30000), width: 3),
                ),
                child: SelectableText(
                  _codigoGerado!,
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 4, color: Color(0xFFB30000)),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Compartilhe este código com seu Médico e Nutricionista', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('VOLTAR'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}