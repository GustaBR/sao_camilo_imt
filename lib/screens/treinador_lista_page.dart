import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/pdf_service.dart';
import 'treinador_detalhes_page.dart';

class TreinadorListaPage extends StatefulWidget {
  final String profissionalId;
  final String profissionalNome;
  const TreinadorListaPage({super.key, required this.profissionalId, required this.profissionalNome});

  @override
  State<TreinadorListaPage> createState() => _TreinadorListaPageState();
}

class _TreinadorListaPageState extends State<TreinadorListaPage> {
  final DatabaseService _db = DatabaseService();
  List<Map<String, dynamic>> _atletas = [];
  final TextEditingController _codigoController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _carregarAtletas();
  }

  Future<void> _carregarAtletas() async {
    setState(() => _isLoading = true);
    try {
      final atletas = await _db.getAtletasDoProfissional(widget.profissionalId);
      if (!mounted) return;
      setState(() {
        _atletas = atletas;
      });
    } catch (e) {
      _mostrarSnackbar('Erro ao carregar atletas: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
            const Text('Digite o CODIGO do atleta:'),
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
              if (codigo.isEmpty) return;

              if (await _db.validarCodigoAtleta(codigo)) {
                if (await _db.adicionarAtletaAoProfissional(widget.profissionalId, codigo)) {
                  await _carregarAtletas();
                  if (!mounted) return;
                  _mostrarSnackbar('Atleta adicionado com sucesso!', isError: false);
                  Navigator.pop(context);
                } else {
                  if (!mounted) return;
                  _mostrarSnackbar(_db.ultimoErro ?? 'Erro ao vincular atleta.', isError: true);
                }
              } else {
                if (!mounted) return;
                _mostrarSnackbar('Codigo de atleta invalido!', isError: true);
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
        content: Text('Tem a certeza que deseja remover o atleta $nome?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (await _db.removerAtletaDoProfissional(widget.profissionalId, codigo)) {
                await _carregarAtletas();
                if (!mounted) return;
                _mostrarSnackbar('Atleta $nome removido.', isError: false);
              } else {
                if (!mounted) return;
                _mostrarSnackbar(_db.ultimoErro ?? 'Erro ao remover atleta.', isError: true);
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

  void _sair() async {
    await _db.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  void _mostrarSnackbar(String mensagem, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: isError ? Colors.red : Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.profissionalNome} - Treinador'),
        backgroundColor: const Color(0xFFB30000),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: _sair)],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _atletas.isEmpty
              ? const Center(child: Text('Nenhum atleta vinculado. Use o botao + para adicionar.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _atletas.length,
                  itemBuilder: (context, index) {
                    final atleta = _atletas[index];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.directions_run)),
                        title: Text(atleta['nome']),
                        subtitle: Text('Codigo: ${atleta['codigo']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removerAtleta(atleta['codigo'], atleta['nome']),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TreinadorDetalhesPage(
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