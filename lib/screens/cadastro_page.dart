import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../services/database_service.dart';
import 'medico_lista_page.dart';
import 'nutricionista_lista_page.dart';
import 'atleta_perfil_page.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _db = DatabaseService(); // <-- Nosso serviço

  int _passoAtual = 0;
  bool _isLoading = false; // <-- Para bloquear os botões durante o cadastro

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController = TextEditingController();

  final TextEditingController _crmController = TextEditingController();
  final TextEditingController _crnController = TextEditingController();
  final TextEditingController _dataNascController = TextEditingController();
  final TextEditingController _altController = TextEditingController();
  
  final _dataMaskFormatter = MaskTextInputFormatter(
    mask: '##/##/####', 
    filter: { "#": RegExp(r'[0-9]') },
    type: MaskAutoCompletionType.lazy,
  );

  final _alturaMaskFormatter = MaskTextInputFormatter(
    mask: '#,##', 
    filter: { "#": RegExp(r'[0-9]') },
    type: MaskAutoCompletionType.lazy,
  );

  String _perfilSelecionado = 'Atleta'; 
  String _sexoSelecionado = 'nao_informado'; // <-- Ajustado para o padrão do banco
  bool _senhaOculta = true;
  bool _confirmarSenhaOculta = true;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    _crmController.dispose();
    _crnController.dispose();
    _dataNascController.dispose(); 
    _altController.dispose(); 
    super.dispose();
  }

  void _avancar() {
    if (_formKey.currentState!.validate()) {
      if (_passoAtual < 2) {
        setState(() => _passoAtual++);
      } else {
        _cadastrar();
      }
    }
  }

  void _voltar() {
    if (_passoAtual > 0) {
      setState(() => _passoAtual--);
    } else {
      Navigator.pop(context);
    }
  }

  // Função para limpar e traduzir o sexo para o formato que o banco aceita
  String _formatarSexoParaBanco(String sexoDisplay) {
    if (sexoDisplay == 'Masculino') return 'masculino';
    if (sexoDisplay == 'Feminino') return 'feminino';
    return 'nao_informado';
  }

  // Redirecionamento igual ao do Login
  void _redirecionarParaHome(Map<String, dynamic>? usuarioLogado) {
    if (usuarioLogado == null) return;
    
    final tipo = usuarioLogado['tipo']?.toString();
    final id = usuarioLogado['id']?.toString() ?? '';
    final nome = usuarioLogado['nome']?.toString() ?? '';

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
    } else {
      // Se for treinador (que ainda não tem tela específica), volta pro início
      Navigator.pop(context); 
    }
  }

  Future<void> _cadastrar() async {
    setState(() => _isLoading = true);

    try {
      String nome = _nomeController.text.trim();
      String email = _emailController.text.trim();
      String senha = _senhaController.text;

      Map<String, dynamic>? usuarioCriado;

      if (_perfilSelecionado == 'Atleta') {
        // Formatar Data
        List<String> partesData = _dataNascController.text.split('/');
        String dataProBanco = '${partesData[2]}-${partesData[1]}-${partesData[0]}';
        
        // Formatar Altura
        double alturaParsed = double.tryParse(_altController.text.replaceAll(',', '.')) ?? 0.0;

        // Formatar Sexo (o banco espera minúsculo)
        String sexoProBanco = _formatarSexoParaBanco(_sexoSelecionado);

        final codigoAcesso = await _db.cadastrarAtleta(
          nome, email, senha,
          dataNascimento: dataProBanco,
          altura: alturaParsed,
          peso: 70.0, // Peso padrão (você pode adicionar um campo no form depois)
          sexo: sexoProBanco,
        );

        if (codigoAcesso != null) {
          // Loga o atleta recém-criado para pegar a sessão completa
          usuarioCriado = await _db.autenticarAtleta(email, senha);
        }

      } else {
        // Médico, Nutricionista ou Treinador
        String tipo = _perfilSelecionado.toLowerCase(); 
        String registro = '';
        
        if (tipo == 'médico') {
          tipo = 'medico';
          registro = _crmController.text.trim();
        } else if (tipo == 'nutricionista') {
          registro = _crnController.text.trim();
        }

        final profData = await _db.cadastrarProfissional(nome, email, senha, tipo, registro);
        
       if (profData != null) {
          if (tipo == 'medico') {
            usuarioCriado = await _db.autenticarMedico(email, senha);
          } else if (tipo == 'nutricionista') {
            usuarioCriado = await _db.autenticarNutricionista(email, senha);
          } else if (tipo == 'treinador') {
             usuarioCriado = await _db.autenticarTreinador(email, senha); 
          }
        }
      }

      if (!mounted) return;

      if (usuarioCriado != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conta criada com sucesso!'), backgroundColor: Colors.green),
        );
        _redirecionarParaHome(usuarioCriado);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao criar conta. Tente novamente.'), backgroundColor: Colors.red),
        );
      }

    } catch (erro) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro inesperado: $erro'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('Passo ${_passoAtual + 1} de 3'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isLoading ? null : _voltar, 
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              LinearProgressIndicator(
                value: (_passoAtual + 1) / 3,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFB30000)),
              ),
              
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _construirPassoAtual(), 
                      ),
                    ),
                  ),
                ),
              ),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))
                  ],
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Row(
                      children: [
                        if (_passoAtual > 0) ...[
                          Expanded(
                            flex: 1,
                            child: OutlinedButton(
                              onPressed: _isLoading ? null : _voltar,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Voltar', style: TextStyle(fontSize: 16)),
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                        
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _avancar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB30000), 
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: _isLoading && _passoAtual == 2
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text(
                                    _passoAtual == 2 ? 'FINALIZAR' : 'AVANÇAR',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirPassoAtual() {
    switch (_passoAtual) {
      case 0: return _buildPasso1();
      case 1: return _buildPasso2();
      case 2: return _buildPasso3();
      default: return _buildPasso1();
    }
  }

  Widget _buildPasso1() {
    return Column(
      key: const ValueKey(1), 
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Vamos começar!',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
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
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'E-mail',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Informe o seu e-mail';
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'E-mail inválido';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasso2() {
    return Column(
      key: const ValueKey(2),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Qual é o seu perfil?',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        DropdownButtonFormField<String>(
          value: _perfilSelecionado,
          decoration: const InputDecoration(
            labelText: 'Eu sou um...',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.assignment_ind),
          ),
          items: <String>['Atleta', 'Médico', 'Nutricionista', 'Treinador']
              .map((String value) => DropdownMenuItem<String>(value: value, child: Text(value)))
              .toList(),
          onChanged: (String? novoPerfil) {
            setState(() {
              _perfilSelecionado = novoPerfil!;
            });
          },
        ),
        const SizedBox(height: 16),

        if (_perfilSelecionado == 'Nutricionista') 
          TextFormField(
            controller: _crnController,
            maxLength: 15,
            decoration: const InputDecoration(
              labelText: 'Registro CRN', 
              border: OutlineInputBorder(), 
              prefixIcon: Icon(Icons.badge),
              counterText: '',
            ),
            validator: (value) => value == null || value.isEmpty ? 'Informe seu CRN' : null,
          ),
          
        if (_perfilSelecionado == 'Médico') 
          TextFormField(
            controller: _crmController,
            maxLength: 15,
            decoration: const InputDecoration(
              labelText: 'Registro CRM', 
              border: OutlineInputBorder(), 
              prefixIcon: Icon(Icons.medical_services),
              counterText: '',
            ),
            validator: (value) => value == null || value.isEmpty ? 'Informe seu CRM' : null,
          ),
          
       if (_perfilSelecionado == 'Atleta') ...[
          TextFormField(
            controller: _dataNascController,
            inputFormatters: [_dataMaskFormatter], 
            decoration: const InputDecoration(
              labelText: 'Data de Nascimento (DD/MM/AAAA)', 
              border: OutlineInputBorder(), 
              prefixIcon: Icon(Icons.calendar_today),
            ),
            keyboardType: TextInputType.datetime,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Informe a data';
              if (value.length != 10) return 'Digite a data completa';

              List<String> partes = value.split('/');
              int dia = int.tryParse(partes[0]) ?? 0;
              int mes = int.tryParse(partes[1]) ?? 0;
              int ano = int.tryParse(partes[2]) ?? 0;

              if (dia < 1 || dia > 31 || mes < 1 || mes > 12 || ano < 1900) {
                return 'Data inválida';
              }

              DateTime dataNasc = DateTime(ano, mes, dia);
              if (dataNasc.year != ano || dataNasc.month != mes || dataNasc.day != dia) {
                return 'Data inexistente no calendário';
              }

              DateTime hoje = DateTime.now();
              if (dataNasc.isAfter(hoje)) {
                return 'Você não pode ter nascido no futuro!';
              }

              int idade = hoje.year - dataNasc.year;
              if (hoje.month < dataNasc.month || (hoje.month == dataNasc.month && hoje.day < dataNasc.day)) {
                idade--;
              }

              if (idade < 5) return 'A idade mínima é 5 anos';
              if (idade > 120) return 'Idade limite excedida (120 anos)';

              return null; 
            },
          ),
          const SizedBox(height: 16), // Adicionado espaçamento
          TextFormField(
            controller: _altController,
            inputFormatters: [_alturaMaskFormatter], 
            decoration: const InputDecoration(
              labelText: 'Altura (m)', 
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.straighten), 
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Informe sua altura';
              if (value.length != 4) return 'Digite no formato X,XX';

              double alturaParsed = double.tryParse(value.replaceAll(',', '.')) ?? 0.0;

              if (alturaParsed < 0.50) return 'Altura muito baixa (mín. 0,50m)';
              if (alturaParsed > 2.50) return 'Altura muito alta (máx. 2,50m)';

              return null; 
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _sexoSelecionado == 'nao_informado' ? 'Prefiro não informar' : _sexoSelecionado,
            decoration: const InputDecoration(
              labelText: 'Sexo',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.people),
            ),
            items: <String>['Masculino', 'Feminino', 'Prefiro não informar']
                .map((String value) => DropdownMenuItem<String>(value: value, child: Text(value)))
                .toList(),
            onChanged: (String? novoSexo) {
              if (novoSexo != null) {
                setState(() => _sexoSelecionado = novoSexo);
              }
            },
          ),
        ],
      ],
    );
  }

  Widget _buildPasso3() {
    return Column(
      key: const ValueKey(3),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Crie sua senha',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
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
          validator: (value) {
            if (value == null || value.isEmpty) return 'Informe uma senha';
            if (value.length < 6) return 'A senha deve ter pelo menos 6 caracteres';
            return null;
          },
        ),
        const SizedBox(height: 16),
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
          validator: (value) {
            if (value == null || value.isEmpty) return 'Confirme sua senha';
            if (value != _senhaController.text) return 'As senhas não coincidem';
            return null;
          },
        ),
      ],
    );
  }
}