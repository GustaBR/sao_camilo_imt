import 'package:flutter/material.dart';
import '../services/database_service.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _registroController = TextEditingController();
  final TextEditingController _dataNascimentoController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController = TextEditingController();
  final DatabaseService _db = DatabaseService();
  bool _isLoading = false;
  String? _tipoUsuario;
  String? _sexoSelecionado;
  bool _senhaOculta = true;
  bool _confirmarSenhaOculta = true;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _registroController.dispose();
    _dataNascimentoController.dispose();
    _alturaController.dispose();
    _pesoController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  double? _lerDecimal(String valor) {
    return double.tryParse(valor.trim().replaceAll(',', '.'));
  }

  void _cadastrar() async {
    if (_tipoUsuario == null) {
      _mostrarSnackbar('Selecione o tipo de usuario');
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      if (_tipoUsuario == 'atleta') {
        String? codigo = await _db.cadastrarAtleta(
          _nomeController.text.trim(),
          _emailController.text.trim(),
          _senhaController.text.trim(),
          dataNascimento: _dataNascimentoController.text.trim(),
          altura: _lerDecimal(_alturaController.text)!,
          peso: _lerDecimal(_pesoController.text)!,
          sexo: _sexoSelecionado!,
        );
        if (!mounted) return;
        setState(() => _isLoading = false);
        if (codigo != null) {
          _mostrarSnackbar('Cadastro realizado! Seu codigo: $codigo', isError: false);
          if (mounted) Navigator.pushReplacementNamed(context, '/login');
        } else {
          _mostrarSnackbar(_db.ultimoErro ?? 'Erro ao cadastrar. Tente novamente.');
        }
      } else {
        final profissional = await _db.cadastrarProfissional(
          _nomeController.text.trim(),
          _emailController.text.trim(),
          _senhaController.text.trim(),
          _tipoUsuario!,
          _registroController.text.trim(),
        );
        if (!mounted) return;
        setState(() => _isLoading = false);
        if (profissional != null) {
          _mostrarSnackbar('Cadastro realizado!', isError: false);
          if (mounted) Navigator.pushReplacementNamed(context, '/login');
        } else {
          _mostrarSnackbar(_db.ultimoErro ?? 'Erro ao cadastrar. Verifique os dados e tente novamente.');
        }
      }
    }
  }

  void _mostrarSnackbar(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: isError ? Colors.red : Colors.green));
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
                  _buildTipoCard('MEDICO', Icons.medical_services, const Color(0xFFB30000), 'medico'),
                  const SizedBox(width: 12),
                  _buildTipoCard('NUTRI', Icons.restaurant, const Color(0xFFB30000), 'nutricionista'),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(controller: _nomeController, decoration: const InputDecoration(labelText: 'Nome Completo', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Informe seu nome' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'E-mail', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Informe seu e-mail' : null),
              if (_tipoUsuario == 'atleta') ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dataNascimentoController,
                  decoration: const InputDecoration(labelText: 'Data de nascimento', hintText: 'AAAA-MM-DD', border: OutlineInputBorder()),
                  keyboardType: TextInputType.datetime,
                  validator: (v) {
                    final valor = v?.trim() ?? '';
                    if (valor.isEmpty) return 'Informe sua data de nascimento';
                    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(valor) || DateTime.tryParse(valor) == null) {
                      return 'Use o formato AAAA-MM-DD';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _alturaController,
                  decoration: const InputDecoration(labelText: 'Altura (cm)', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final altura = _lerDecimal(v ?? '');
                    if (altura == null) return 'Informe sua altura';
                    if (altura <= 0) return 'Altura deve ser maior que zero';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pesoController,
                  decoration: const InputDecoration(labelText: 'Peso (kg)', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final peso = _lerDecimal(v ?? '');
                    if (peso == null) return 'Informe seu peso';
                    if (peso <= 0) return 'Peso deve ser maior que zero';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _sexoSelecionado,
                  decoration: const InputDecoration(labelText: 'Sexo', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'masculino', child: Text('Masculino')),
                    DropdownMenuItem(value: 'feminino', child: Text('Feminino')),
                    DropdownMenuItem(value: 'outro', child: Text('Outro')),
                    DropdownMenuItem(value: 'nao_informado', child: Text('Prefiro nao informar')),
                  ],
                  onChanged: (value) => setState(() => _sexoSelecionado = value),
                  validator: (value) => value == null ? 'Informe seu sexo' : null,
                ),
              ],
              if (_tipoUsuario == 'medico' || _tipoUsuario == 'nutricionista') ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _registroController,
                  decoration: InputDecoration(labelText: _tipoUsuario == 'medico' ? 'CRM' : 'CRN', border: const OutlineInputBorder()),
                  validator: (v) {
                    if ((_tipoUsuario == 'medico' || _tipoUsuario == 'nutricionista') && (v == null || v.trim().isEmpty)) {
                      return _tipoUsuario == 'medico' ? 'Informe o CRM' : 'Informe o CRN';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _senhaController,
                obscureText: _senhaOculta,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(icon: Icon(_senhaOculta ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _senhaOculta = !_senhaOculta)),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe uma senha';
                  if (v.length < 6) return 'Minimo 6 caracteres';
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
                  suffixIcon: IconButton(icon: Icon(_confirmarSenhaOculta ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _confirmarSenhaOculta = !_confirmarSenhaOculta)),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Confirme sua senha';
                  if (v != _senhaController.text) return 'As senhas nao coincidem';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _cadastrar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFB30000),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading ? const CircularProgressIndicator(color: Color(0xFFB30000)) : const Text('CADASTRAR'),
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