import 'package:flutter/material.dart';
import '../services/database_service.dart';
import 'medico_lista_page.dart';
import 'nutricionista_lista_page.dart';
import 'treinador_lista_page.dart';

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
  bool _obscureText = true;
  String _perfilSelecionado = 'Atleta';

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String email = _emailController.text.trim();
    String senha = _senhaController.text;

    setState(() => _isLoading = true);

    try {
      if (_perfilSelecionado == 'Atleta') {
        var atleta = await _db.autenticarAtleta(email, senha);
        if (!mounted) return;
        
        if (atleta != null) {
          Navigator.pushReplacementNamed(context, '/atleta/treino');
        } else {
          _mostrarSnackbar(_db.ultimoErro ?? 'E-mail ou senha inválidos');
        }
      } 
      else if (_perfilSelecionado == 'Médico') {
        var medico = await _db.autenticarMedico(email, senha);
        if (!mounted) return;
        
        if (medico != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MedicoListaPage(
                profissionalId: medico['id'], 
                profissionalNome: medico['nome']
              )
            ),
          );
        } else {
          _mostrarSnackbar(_db.ultimoErro ?? 'E-mail ou senha inválidos');
        }
      } 
      else if (_perfilSelecionado == 'Nutricionista') {
        var nutri = await _db.autenticarNutricionista(email, senha);
        if (!mounted) return;
        
        if (nutri != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => NutricionistaListaPage(
                profissionalId: nutri['id'], 
                profissionalNome: nutri['nome']
              )
            ),
          );
        } else {
          _mostrarSnackbar(_db.ultimoErro ?? 'E-mail ou senha inválidos');
        }
      }
      else if (_perfilSelecionado == 'Treinador') {
        var treinador = await _db.autenticarTreinador(email, senha); 
        if (!mounted) return;
        
        if (treinador != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TreinadorListaPage(
                profissionalId: treinador['id'], 
                profissionalNome: treinador['nome']
              )
            ),
          );
        } else {
          _mostrarSnackbar(_db.ultimoErro ?? 'E-mail ou senha inválidos');
        }
      }
    } catch (erro) {
      if (mounted) {
        _mostrarSnackbar('Erro inesperado: $erro');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
      backgroundColor: const Color(0xFFB30000),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB30000),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            margin: const EdgeInsets.symmetric(horizontal: 24.0),
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
                 const Text('HydroTrack', style: TextStyle(color: const Color(0xFFB30000), 
                 fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  const SizedBox(height: 30),
                  
                  DropdownButtonFormField<String>(
                    initialValue: _perfilSelecionado,
                    decoration: const InputDecoration(
                      labelText: 'Entrar como:',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.assignment_ind),
                    ),
                    items: <String>['Atleta', 'Médico', 'Nutricionista', 'Treinador']
                        .map((String value) => DropdownMenuItem<String>(value: value, child: Text(value)))
                        .toList(),
                    onChanged: _isLoading ? null : (String? novoPerfil) {
                      setState(() {
                        _perfilSelecionado = novoPerfil!;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _emailController,
                    enabled: !_isLoading,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Preencha o e-mail';
                      }
                      if (!value.contains('@')) {
                        return 'Insira um e-mail válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  TextFormField(
                    controller: _senhaController,
                    enabled: !_isLoading,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                        onPressed: _isLoading ? null : () => setState(() => _obscureText = !_obscureText),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Preencha a senha';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB30000),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('ENTRAR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pushReplacementNamed(context, '/cadastro'),
                    child: const Text(
                      'Não tem conta? Cadastre-se',
                      style: TextStyle(color: Color(0xFFB30000)),
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