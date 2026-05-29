import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../profissional/lista_alunos_page.dart';

class LoginProfissionalPage extends StatefulWidget {
  final String tipo;
  const LoginProfissionalPage({super.key, required this.tipo});

  @override
  State<LoginProfissionalPage> createState() => _LoginProfissionalPageState();
}

class _LoginProfissionalPageState extends State<LoginProfissionalPage> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final DatabaseService _db = DatabaseService();
  bool _isLoading = false;
  bool _obscureText = true;

  void _login() async {
    String usuario = _usuarioController.text.trim();
    String senha = _senhaController.text;

    if (usuario.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha usuário e senha'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));

    if (_db.autenticarProfissional(usuario, senha)) {
      var profissional = _db.getProfissional(usuario);
      List<Map<String, dynamic>> alunos = _db.getAlunosDoProfissional(usuario);

      setState(() => _isLoading = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ListaAlunosPage(
            profissionalNome: profissional!['nome'],
            profissionalTipo: widget.tipo,
            profissionalId: usuario,
            alunos: alunos,
          ),
        ),
      );
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário ou senha inválidos'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Color cor = widget.tipo == 'medico' ? const Color(0xFFB30000) : Colors.green;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tipo == 'medico' ? 'Login Médico' : 'Login Nutricionista'),
        backgroundColor: cor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.tipo == 'medico' ? Icons.medical_services : Icons.restaurant, size: 80, color: cor),
            const SizedBox(height: 32),
            TextField(
              controller: _usuarioController,
              decoration: InputDecoration(
                labelText: 'Usuário',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(Icons.person, color: cor),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _senhaController,
              obscureText: _obscureText,
              decoration: InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(Icons.lock, color: cor),
                suffixIcon: IconButton(
                  icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: cor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Column(
                children: [
                  Text(
                    'Usuário: ${widget.tipo == 'medico' ? 'medico_joao' : 'nutri_maria'}',
                    style: TextStyle(color: cor, fontWeight: FontWeight.bold),
                  ),
                  const Text('Senha: 123', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(backgroundColor: cor),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('ENTRAR', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}