import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/sessao_treino.dart';
import 'detalhes_atleta_page.dart';

class ListaAtletasPage extends StatefulWidget {
  final String profissionalNome;
  final String profissionalTipo;
  final String profissionalId;
  final List<Map<String, dynamic>> atletas;

  const ListaAtletasPage({
    super.key,
    required this.profissionalNome,
    required this.profissionalTipo,
    required this.profissionalId,
    required this.atletas,
  });

  @override
  State<ListaAtletasPage> createState() => _ListaAtletasPageState();
}

class _ListaAtletasPageState extends State<ListaAtletasPage> {
  late List<Map<String, dynamic>> _atletas;
  final DatabaseService _db = DatabaseService();
  final TextEditingController _codigoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _atletas = List.from(widget.atletas);
    print('Atletas carregados: ${_atletas.length}'); // Debug
  }

  void _adicionarAtleta() {
    _codigoController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Atleta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Digite o código do atleta:'),
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              String codigo = _codigoController.text.trim().toUpperCase();

              if (codigo.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Digite um código'), backgroundColor: Colors.red),
                );
                return;
              }

              if (!(await _db.validarCodigoAtleta(codigo))) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Código inválido!'), backgroundColor: Colors.red),
                );
                return;
              }

              if (await _db.adicionarAtletaAoProfissional(widget.profissionalId, codigo)) {
                var atleta = await _db.getAtleta(codigo);
                if (!mounted) return;
                setState(() {
                  _atletas.add(atleta!);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Atleta adicionado!'), backgroundColor: Colors.green),
                );
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Erro ao adicionar atleta'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  void _removerAtleta(Map<String, dynamic> atleta, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Atleta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tem certeza que deseja remover este atleta?'),
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
                  Text('Nome: ${atleta['nome']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Código: ${atleta['codigo']}'),
                  Text('Email: ${atleta['email']}'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Esta ação removerá o vínculo com este atleta.',
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
            onPressed: () async {
              bool removido = await _db.removerAtletaDoProfissional(widget.profissionalId, atleta['codigo']);
              if (!mounted) return;

              if (removido) {
                setState(() {
                  _atletas.removeAt(index);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${atleta['nome']} foi removido'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Erro ao remover atleta'),
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

  void _verDetalhes(Map<String, dynamic> atleta) async {
    print('Abrindo detalhes do atleta: ${atleta['nome']}'); // Debug

    List<SessaoTreino> treinos = await _db.getTreinosDoAtleta(atleta['codigo']);

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalhesAtletaPage(
          atletaNome: atleta['nome'],
          atletaCodigo: atleta['codigo'],
          profissionalTipo: widget.profissionalTipo,
          cor: widget.profissionalTipo == 'medico' ? const Color(0xFFB30000) : Colors.green,
          treinos: treinos,
        ),
      ),
    );
  }

  Future<void> _sair() async {
    await _db.logoutProfissional();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    Color cor = widget.profissionalTipo == 'medico' ? const Color(0xFFB30000) : Colors.green;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.profissionalNome} - Atletas'),
        backgroundColor: cor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _sair,
            tooltip: 'Sair',
          ),
        ],
      ),
      body: _atletas.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Nenhum atleta vinculado', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text('Toque no + para adicionar um atleta', style: TextStyle(color: Colors.grey[400])),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _atletas.length,
              itemBuilder: (context, index) {
                final atleta = _atletas[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: InkWell(
                    onTap: () => _verDetalhes(atleta),
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
                                Text(atleta['nome'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                Text('Código: ${atleta['codigo']}', style: TextStyle(fontSize: 12, color: cor)),
                                Text(atleta['email'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                            onPressed: () => _removerAtleta(atleta, index),
                            tooltip: 'Remover atleta',
                          ),
                          Icon(Icons.chevron_right, size: 32, color: cor),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _adicionarAtleta,
        backgroundColor: cor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
