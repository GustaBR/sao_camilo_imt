import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import 'detalhes_aluno_page.dart';

class ListaAlunosPage extends StatefulWidget {
  final String profissionalNome;
  final String profissionalTipo;
  final String profissionalId;
  final List<Map<String, dynamic>> alunos;

  const ListaAlunosPage({
    super.key,
    required this.profissionalNome,
    required this.profissionalTipo,
    required this.profissionalId,
    required this.alunos,
  });

  @override
  State<ListaAlunosPage> createState() => _ListaAlunosPageState();
}

class _ListaAlunosPageState extends State<ListaAlunosPage> {
  late List<Map<String, dynamic>> _alunos;
  final DatabaseService _db = DatabaseService();
  final TextEditingController _codigoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _alunos = List.from(widget.alunos);
  }

  void _adicionarAluno() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Aluno'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Digite o código do aluno:'),
            const SizedBox(height: 16),
            TextField(
              controller: _codigoController,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, letterSpacing: 4),
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'ABC123',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              String codigo = _codigoController.text.trim().toUpperCase();
              if (_db.validarCodigoAluno(codigo)) {
                if (_db.adicionarAlunoAoProfissional(widget.profissionalId, codigo)) {
                  var aluno = _db.getAluno(codigo);
                  setState(() => _alunos.add(aluno!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Aluno adicionado!')),
                  );
                  Navigator.pop(context);
                  _codigoController.clear();
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Código inválido!'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  // NOVO: Método para remover aluno com confirmação
  void _removerAluno(Map<String, dynamic> aluno, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Aluno'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tem certeza que deseja remover este aluno?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nome: ${aluno['nome']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Código: ${aluno['codigo']}'),
                  Text('Email: ${aluno['email']}'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '⚠️ Esta ação removerá o vínculo com este aluno. O aluno continuará existindo no sistema, mas não será mais acessível por você.',
              style: TextStyle(fontSize: 12, color: Colors.orange),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () {
              // Remover o vínculo do profissional com o aluno
              bool removido = _db.removerAlunoDoProfissional(widget.profissionalId, aluno['codigo']);
              
              if (removido) {
                setState(() {
                  _alunos.removeAt(index);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${aluno['nome']} foi removido da sua lista'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Erro ao remover aluno'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('REMOVER', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color cor = widget.profissionalTipo == 'medico' ? const Color(0xFFB30000) : Colors.green;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.profissionalNome} - Alunos'),
        backgroundColor: cor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
          ),
        ],
      ),
      body: _alunos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Nenhum aluno vinculado', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text('Toque no + para adicionar um aluno', style: TextStyle(color: Colors.grey[400])),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _alunos.length,
              itemBuilder: (context, index) {
                final aluno = _alunos[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetalhesAlunoPage(
                            alunoNome: aluno['nome'],
                            alunoCodigo: aluno['codigo'],
                            profissionalTipo: widget.profissionalTipo,
                            cor: cor,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: cor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Icon(Icons.person, size: 32, color: cor),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(aluno['nome'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                Text('Código: ${aluno['codigo']}', style: TextStyle(fontSize: 12, color: cor)),
                                Text(aluno['email'], style: const TextStyle(fontSize: 12, color: Colors.black54)),
                              ],
                            ),
                          ),
                          // NOVO: Botão de remover
                          IconButton(
                            icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                            onPressed: () => _removerAluno(aluno, index),
                            tooltip: 'Remover aluno',
                          ),
                          Icon(Icons.chevron_right, size: 32, color: cor),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _adicionarAluno,
        backgroundColor: cor,
        icon: const Icon(Icons.add),
        label: const Text('Adicionar Aluno'),
      ),
    );
  }
}