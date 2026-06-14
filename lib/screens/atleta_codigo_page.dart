import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../ui/paginas/treino/dashboard_page.dart';

class AtletaCodigoPage extends StatefulWidget {
  const AtletaCodigoPage({super.key});

  @override
  State<AtletaCodigoPage> createState() => _AtletaCodigoPageState();
}

class _AtletaCodigoPageState extends State<AtletaCodigoPage> {
  final DatabaseService _db = DatabaseService();
  String? _codigoGerado;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _carregarCodigo();
  }

  void _carregarCodigo() {
    final ativo = _db.getAtivoLogado();
    if (ativo != null) {
      setState(() => _codigoGerado = ativo['id']);
    }
  }

  void _sair() {
    _db.logout();
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu Código'), backgroundColor: const Color(0xFFB30000), actions: [IconButton(icon: const Icon(Icons.logout), onPressed: _sair)]),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.qr_code, size: 80, color: Color(0xFFB30000)),
              const SizedBox(height: 24),
              const Text('Seu código exclusivo:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFB30000), width: 3)),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : SelectableText(_codigoGerado ?? 'Carregando...', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 4, color: Color(0xFFB30000))),
              ),
              const SizedBox(height: 24),
              const Text('Compartilhe este código com seu Médico e Nutricionista', textAlign: TextAlign.center),
              const SizedBox(height: 32),
              ElevatedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back), label: const Text('VOLTAR')),
            ],
          ),
        ),
      ),
    );
  }
}