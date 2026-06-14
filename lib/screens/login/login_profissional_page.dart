import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../models/sessao_treino.dart';  // ← IMPORTANTE
import '../profissional/detalhes_aluno_page.dart';

class LoginProfissionalPage extends StatefulWidget {
  final String tipo;
  const LoginProfissionalPage({super.key, required this.tipo});

  @override
  State<LoginProfissionalPage> createState() => _LoginProfissionalPageState();
}

class _LoginProfissionalPageState extends State<LoginProfissionalPage> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _codigoAtletaController = TextEditingController();
  final DatabaseService _db = DatabaseService();
  
  bool _isLoading = false;
  bool _obscureText = true;

  void _login() async {
    String usuario = _usuarioController.text.trim();
    String senha = _senhaController.text;
    String codigoAtleta = _codigoAtletaController.text.trim().toUpperCase();

    if (usuario.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha usuário e senha'), backgroundColor: Colors.red),
      );
      return;
    }

    if (codigoAtleta.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite o código do atleta'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    // 1. Autenticar profissional
    if (!_db.autenticarProfissional(usuario, senha)) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário ou senha inválidos'), backgroundColor: Colors.red),
      );
      return;
    }

    // 2. Validar código do atleta
    bool codigoValido = _db.validarCodigoAluno(codigoAtleta);
    
    if (!codigoValido) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código do atleta inválido!'), backgroundColor: Colors.red),
      );
      return;
    }

    // 3. Buscar dados do atleta
    var atleta = _db.getAluno(codigoAtleta);
    if (atleta == null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Atleta não encontrado'), backgroundColor: Colors.red),
      );
      return;
    }

    // 4. Buscar histórico de treinos do atleta
    List<SessaoTreino> treinos = await _db.getTreinosDoAluno(codigoAtleta);

    setState(() => _isLoading = false);

    // 5. Ir para o dashboard com os dados do atleta
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DetalhesAlunoPage(
          alunoNome: atleta['nome'],
          alunoCodigo: codigoAtleta,
          profissionalTipo: widget.tipo,
          cor: widget.tipo == 'medico' ? const Color(0xFFB30000) : Colors.green,
          treinos: treinos,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color cor = widget.tipo == 'medico' ? const Color(0xFFB30000) : Colors.green;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tipo == 'medico' ? 'Acesso Médico' : 'Acesso Nutricionista'),
        backgroundColor: cor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.tipo == 'medico' ? Icons.medical_services : Icons.restaurant, size: 80, color: cor),
            const SizedBox(height: 32),
            
            // Campo para digitar o código do atleta
            TextField(
              controller: _codigoAtletaController,
              decoration: InputDecoration(
                labelText: 'CÓDIGO DO ATLETA',
                hintText: 'Ex: ABC123',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(Icons.qr_code, color: cor),
              ),
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(fontSize: 18, letterSpacing: 2, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
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
                  const SizedBox(height: 8),
                  Text(
                    'Códigos disponíveis: ABC123, DEF456, GHI789',
                    style: TextStyle(fontSize: 11, color: cor),
                  ),
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
                    : const Text('ACESSAR ATLETA', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}