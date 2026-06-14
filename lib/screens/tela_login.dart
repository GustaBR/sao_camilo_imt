import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../ui/paginas/treino/dashboard_page.dart';
import 'medico_lista_page.dart';
import 'nutricionista_lista_page.dart';
import 'cadastro_page.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final DatabaseService _db = DatabaseService();
  bool _isLoading = false;
  bool _obscureText = true;
  String? _tipoSelecionado;

  void _login() async {
    if (_tipoSelecionado == null) {
      _mostrarSnackbar('Selecione o tipo de usuário');
      return;
    }

    String email = _emailController.text.trim();
    String senha = _senhaController.text;

    if (email.isEmpty || senha.isEmpty) {
      _mostrarSnackbar('Preencha e-mail e senha');
      return;
    }

    setState(() => _isLoading = true);

    if (_tipoSelecionado == 'atleta') {
      var atleta = _db.autenticarAtleta(email, senha);
      if (atleta != null) {
        _db.setAtivoLogado(atleta['codigo'], atleta['nome']);
        setState(() => _isLoading = false);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardPage()),
          );
        }
      } else {
        setState(() => _isLoading = false);
        _mostrarSnackbar('E-mail ou senha inválidos');
      }
    } else if (_tipoSelecionado == 'medico') {
      var medico = _db.autenticarMedico(email, senha);
      if (medico != null) {
        _db.setAtivoLogado(medico['id'], medico['nome']);
        setState(() => _isLoading = false);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MedicoListaPage(
                profissionalId: medico['id'],
                profissionalNome: medico['nome'],
              ),
            ),
          );
        }
      } else {
        setState(() => _isLoading = false);
        _mostrarSnackbar('E-mail ou senha inválidos');
      }
    } else if (_tipoSelecionado == 'nutricionista') {
      var nutri = _db.autenticarNutricionista(email, senha);
      if (nutri != null) {
        _db.setAtivoLogado(nutri['id'], nutri['nome']);
        setState(() => _isLoading = false);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => NutricionistaListaPage(
                profissionalId: nutri['id'],
                profissionalNome: nutri['nome'],
              ),
            ),
          );
        }
      } else {
        setState(() => _isLoading = false);
        _mostrarSnackbar('E-mail ou senha inválidos');
      }
    }
  }

  void _mostrarSnackbar(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: const Color(0xFFB30000),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 80, color: Color(0xFFB30000)),
            const SizedBox(height: 24),
            const Text('Bem-vindo!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),

            const Text('Entrar como:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildTipoBotao('ATLETA', Icons.person, const Color(0xFFB30000), 'atleta'),
                const SizedBox(width: 12),
                _buildTipoBotao('MÉDICO', Icons.medical_services, const Color(0xFFB30000), 'medico'),
                const SizedBox(width: 12),
                _buildTipoBotao('NUTRI', Icons.restaurant, Colors.green, 'nutricionista'),
              ],
            ),
            const SizedBox(height: 32),

            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _senhaController,
              obscureText: _obscureText,
              decoration: InputDecoration(
                labelText: 'Senha',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                ),
              ),
            ),

            if (_tipoSelecionado != 'atleta') ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (_tipoSelecionado == 'medico' ? const Color(0xFFB30000) : Colors.green).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Email: ${_tipoSelecionado == 'medico' ? 'medico@email.com' : 'nutri@email.com'} | Senha: 123',
                  style: TextStyle(
                    color: _tipoSelecionado == 'medico' ? const Color(0xFFB30000) : Colors.green,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB30000),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('ENTRAR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const CadastroPage()),
                );
              },
              child: const Text('Não tem conta? Cadastre-se'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipoBotao(String titulo, IconData icon, Color cor, String tipo) {
    bool selecionado = _tipoSelecionado == tipo;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tipoSelecionado = tipo),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selecionado ? cor.withOpacity(0.1) : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selecionado ? cor : Colors.grey[300]!,
              width: selecionado ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: selecionado ? cor : Colors.grey, size: 24),
              const SizedBox(height: 4),
              Text(
                titulo,
                style: TextStyle(
                  color: selecionado ? cor : Colors.grey,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}