import 'package:flutter/material.dart';
import '../services/database_service.dart';
import 'tela_login.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController = TextEditingController();
  final DatabaseService _db = DatabaseService();
  bool _isLoading = false;
  String? _tipoUsuario;
  bool _senhaOculta = true;
  bool _confirmarSenhaOculta = true;

  void _cadastrar() async {
    if (_tipoUsuario == null) {
      _mostrarSnackbar('Selecione o tipo de usuário');
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      if (_tipoUsuario == 'atleta') {
        String? codigo = await _db.cadastrarAtleta(
          _nomeController.text.trim(),
          _emailController.text.trim(),
          _senhaController.text.trim(),
        );
        setState(() => _isLoading = false);
        if (codigo != null) {
          _mostrarSnackbar('Cadastro realizado! Seu código: $codigo', isError: false);
          if (mounted) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const TelaLogin()));
          }
        } else {
          _mostrarSnackbar('Erro ao cadastrar. Tente novamente.');
        }
      } else {
        setState(() => _isLoading = false);
        _mostrarSnackbar('Para médico/nutricionista, use as credenciais padrão', isError: false);
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const TelaLogin()));
        }
      }
    }
  }

  void _mostrarSnackbar(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: isError ? Colors.red : Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro'), backgroundColor: const Color(0xFFB30000)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text('Criar Conta', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              const Text('Tipo de conta:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildTipoCard('ATLETA', Icons.person, const Color(0xFFB30000), 'atleta'),
                  const SizedBox(width: 12),
                  _buildTipoCard('MÉDICO', Icons.medical_services, const Color(0xFFB30000), 'medico'),
                  const SizedBox(width: 12),
                  _buildTipoCard('NUTRI', Icons.restaurant, Colors.green, 'nutricionista'),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome Completo', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Informe seu nome' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'E-mail', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Informe seu e-mail' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _senhaController,
                obscureText: _senhaOculta,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_senhaOculta ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _senhaOculta = !_senhaOculta),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe uma senha';
                  if (v.length < 6) return 'Mínimo 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmarSenhaController,
                obscureText: _confirmarSenhaOculta,
                decoration: InputDecoration(
                  labelText: 'Confirmar senha',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_confirmarSenhaOculta ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _confirmarSenhaOculta = !_confirmarSenhaOculta),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Confirme sua senha';
                  if (v != _senhaController.text) return 'As senhas não coincidem';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _cadastrar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB30000),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('CADASTRAR'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipoCard(String titulo, IconData icon, Color cor, String tipo) {
    bool selecionado = _tipoUsuario == tipo;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tipoUsuario = tipo),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selecionado ? cor.withOpacity(0.1) : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selecionado ? cor : Colors.grey[300]!),
          ),
          child: Column(
            children: [
              Icon(icon, color: selecionado ? cor : Colors.grey),
              Text(titulo, style: TextStyle(color: selecionado ? cor : Colors.grey, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}