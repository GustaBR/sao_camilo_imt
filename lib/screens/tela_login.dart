import 'package:flutter/material.dart';
import '../services/database_service.dart';
import 'medico_lista_page.dart';
import 'nutricionista_lista_page.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final DatabaseService _db = DatabaseService();
  
  bool _isLoading = false;
  String? _tipoSelecionado;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final logado = _db.getAtivoLogado();
      if (logado != null) {
        _redirecionarPorPerfil(logado);
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _redirecionarPorPerfil(Map<String, dynamic> dadosUsuario) {
    final tipo = dadosUsuario['tipo']?.toString();
    final id = dadosUsuario['id']?.toString() ?? '';
    final nome = dadosUsuario['nome']?.toString() ?? '';

    if (tipo == 'atleta') {
      Navigator.pushReplacementNamed(context, '/atleta/treino');
    } else if (tipo == 'medico') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MedicoListaPage(profissionalId: id, profissionalNome: nome)),
      );
    } else if (tipo == 'nutricionista') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NutricionistaListaPage(profissionalId: id, profissionalNome: nome)),
      );
    } else if (tipo == 'treinador') {
      // Como ainda não temos a tela TreinadorListaPage, vou colocar uma tela provisória.
      // Quando você criar a tela dele, é só trocar aqui!
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Painel do Treinador')),
            body: Center(child: Text('Bem-vindo, Treinador $nome!')),
          ),
        ),
      );
    }
  }

  Future<void> _fazerLogin() async {
    if (_tipoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione seu perfil antes de entrar."), backgroundColor: Colors.red),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        Map<String, dynamic>? usuario;
        String email = _emailController.text.trim();
        String senha = _senhaController.text;

        if (_tipoSelecionado == 'atleta') {
          usuario = await _db.autenticarAtleta(email, senha);
        } else if (_tipoSelecionado == 'medico') {
          usuario = await _db.autenticarMedico(email, senha);
        } else if (_tipoSelecionado == 'nutricionista') {
          usuario = await _db.autenticarNutricionista(email, senha);
        } else if (_tipoSelecionado == 'treinador') {
          usuario = await _db.autenticarTreinador(email, senha); // <-- Agora chama o método certo!
        }

        if (!mounted) return;

        if (usuario != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Login efetuado com sucesso!"), backgroundColor: Colors.green),
          ); 
          
          _redirecionarPorPerfil(usuario);

        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Erro: E-mail ou senha incorretos."), backgroundColor: Colors.red),
          );
        }
      } catch (erro) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erro inesperado: $erro"), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildTipoBotao(String titulo, IconData icon, Color cor, String tipo) {
    bool selecionado = _tipoSelecionado == tipo;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tipoSelecionado = tipo),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selecionado ? cor.withOpacity(0.1) : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: selecionado ? cor : Colors.transparent, width: 2),
          ),
          child: Column(
            children: [
              Icon(icon, color: selecionado ? cor : Colors.grey, size: 20),
              const SizedBox(height: 4),
              Text(titulo, style: TextStyle(color: selecionado ? cor : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB30000),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB30000),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(32.0),
            margin: const EdgeInsets.symmetric(horizontal: 24),
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
                  Image.asset('assets/images/logo.png', height: 60),
                  const SizedBox(height: 30),
                  
                  // Primeira linha de botões
                  Row(
                    children: [
                      _buildTipoBotao('ATLETA', Icons.person, const Color(0xFFB30000), 'atleta'),
                      const SizedBox(width: 8),
                      _buildTipoBotao('MÉDICO', Icons.medical_services, const Color(0xFFB30000), 'medico'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Segunda linha de botões
                  Row(
                    children: [
                      _buildTipoBotao('NUTRI', Icons.restaurant, Colors.green, 'nutricionista'),
                      const SizedBox(width: 8),
                      _buildTipoBotao('TREINADOR', Icons.sports, Colors.blue, 'treinador'),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Por favor, insira o e-mail';
                      if (!value.contains('@')) return 'Insira um e-mail válido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _senhaController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Senha',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Por favor, insira a senha';
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _fazerLogin,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: const Color(0xFFB30000),
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('ENTRAR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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