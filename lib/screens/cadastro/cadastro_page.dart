import 'package:flutter/material.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController = TextEditingController();

  bool _senhaOculta = true;
  bool _confirmarSenhaOculta = true;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  // Validações
  String? _validarEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe o seu e-mail';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Digite um e-mail válido';
    }
    return null;
  }

  String? _validarSenha(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe uma senha';
    }
    if (value.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }

  String? _validarConfirmarSenha(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirme sua senha';
    }
    if (value != _senhaController.text) {
      return 'As senhas não coincidem';
    }
    return null;
  }

  void _cadastrar() {
    if (_formKey.currentState!.validate()) {
      // Lógica de cadastro aqui
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Processando cadastro...')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro'),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // SE A TELA FOR MAIOR QUE 600PX, TRATA COMO PC/WEB
          if (constraints.maxWidth > 600) {
            return Center(
              child: Container(
                width: 500, // Largura máxima do formulário no PC
                padding: const EdgeInsets.all(32.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: _buildFormulario(),
                  ),
                ),
              ),
            );
          }

          // CASO CONTRÁRIO, TRATA COMO CELULAR (MOBILE)
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: _buildFormulario(),
          );
        },
      ),
    );
  }

  // Componente do formulário reutilizado para ambas as versões
  Widget _buildFormulario() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Criar Conta',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // Campo Nome
          TextFormField(
            controller: _nomeController,
            decoration: const InputDecoration(
              labelText: 'Nome Completo',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) => value == null || value.isEmpty ? 'Informe seu nome' : null,
          ),
          const SizedBox(height: 16),

          // Campo E-mail
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'E-mail',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: _validarEmail,
          ),
          const SizedBox(height: 16),

          // Campo Senha
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
            validator: _validarSenha,
          ),
          const SizedBox(height: 16),

          // Campo Confirmar Senha
          TextFormField(
            controller: _confirmarSenhaController,
            obscureText: _confirmarSenhaOculta,
            decoration: InputDecoration(
              labelText: 'Confirmar Senha',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_confirmarSenhaOculta ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _confirmarSenhaOculta = !_confirmarSenhaOculta),
              ),
            ),
            validator: _validarConfirmarSenha,
          ),
          const SizedBox(height: 32),

          // Botão Cadastrar
          ElevatedButton(
            onPressed: _cadastrar,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'CADASTRAR',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}