import 'package:flutter/material.dart';
import '../services/database_service.dart';
import 'medico_detalhes_page.dart';

class MedicoListaPage extends StatefulWidget {
  final String profissionalId;
  final String profissionalNome;
  const MedicoListaPage({super.key, required this.profissionalId, required this.profissionalNome});

  @override
  State<MedicoListaPage> createState() => _MedicoListaPageState();
}

class _MedicoListaPageState extends State<MedicoListaPage> {
  final DatabaseService _db = DatabaseService();
  List<Map<String, dynamic>> _atletas = [];
  final TextEditingController _codigoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarAtletas();
  }

  Future<void> _carregarAtletas() async {
    final atletas = await _db.getAtletasDoProfissional(widget.profissionalId);
    if (!mounted) return;
    setState(() {
      _atletas = atletas;
    });
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
            const Text('Digite o CÓDIGO do atleta:'),
            const SizedBox(height: 16),
            TextField(
              controller: _codigoController,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(fontSize: 20, letterSpacing: 4),
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
            onPressed: () async {
              String codigo = _codigoController.text.trim().toUpperCase();
              if (await _db.validarCodigoAtleta(codigo)) {
                if (await _db.adicionarAtletaAoProfissional(widget.profissionalId, codigo)) {
                  await _carregarAtletas();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Atleta adicionado!'), backgroundColor: Colors.green),
                  );
                  Navigator.pop(context);
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

  void _removerAtleta(String codigo, String nome) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Atleta'),
        content: Text('Tem certeza que deseja remover $nome?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (await _db.removerAtletaDoProfissional(widget.profissionalId, codigo)) {
                await _carregarAtletas();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$nome removido'), backgroundColor: Colors.green),
                );
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }

  Future<void> _sair() async {
    await _db.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.profissionalNome} - Atletas'),
        backgroundColor: const Color(0xFFB30000),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: _sair)],
      ),
      body: _atletas.isEmpty
          ? const Center(child: Text('Nenhum atleta vinculado. Use o código para adicionar.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _atletas.length,
              itemBuilder: (context, index) {
                final atleta = _atletas[index];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(atleta['nome']),
                    subtitle: Text('Código: ${atleta['codigo']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removerAtleta(atleta['codigo'], atleta['nome']),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MedicoDetalhesPage(
                            atletaCodigo: atleta['codigo'],
                            atletaNome: atleta['nome'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _adicionarAtleta,
        backgroundColor: const Color(0xFFB30000),
        child: const Icon(Icons.add),
      ),
    );
  }
}
