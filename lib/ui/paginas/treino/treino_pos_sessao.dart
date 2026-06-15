import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../services/database_service.dart';
import '../../../models/sessao_treino.dart';

class TreinoPosSessao extends StatefulWidget {
  final double massaCorporalPre;
  final String modalidade;
  final int duracaoPrevista;
  final int duracaoRealSegundos;
  final int fluidosIngeridosMl;
  final String alimentosAgua;
  final int volumeUrinarioMl;
  final int temperatura;
  final int umidade;
  final double sensacaoTermica;
  final String vento;
  final String exposicaoSolar;
  final String corUrina;
  final String vestimenta;
  final String equipamento;
  final bool estaComSede;
  final String sintomasDescricao;
  final String historicoHidratacao;

  const TreinoPosSessao({
    super.key,
    required this.massaCorporalPre,
    required this.modalidade,
    required this.duracaoPrevista,
    required this.duracaoRealSegundos,
    required this.fluidosIngeridosMl,
    required this.alimentosAgua,
    required this.volumeUrinarioMl,
    required this.temperatura,
    required this.umidade,
    required this.sensacaoTermica,
    required this.vento,
    required this.exposicaoSolar,
    required this.corUrina,
    required this.vestimenta,
    required this.equipamento,
    required this.estaComSede,
    required this.sintomasDescricao,
    required this.historicoHidratacao,
  });

  @override
  State<TreinoPosSessao> createState() => _TreinoPosSessaoState();
}

class _TreinoPosSessaoState extends State<TreinoPosSessao> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _massaCorporalController = TextEditingController();
  final TextEditingController _observacaoRoupasController = TextEditingController();
  final TextEditingController _sintomasGastroController = TextEditingController();
  final TextEditingController _fadigaController = TextEditingController();
  final DatabaseService _db = DatabaseService();
  final _supabase = Supabase.instance.client;
  
  bool? _roupasEncharcadas;
  bool? _trocaVestimenta;
  bool? _temSintomasGastro;
  bool? _temFadiga;
  int? _borgSelecionado;
  bool _isSaving = false;

  Future<void> _finalizarTreino() async {
    if (_roupasEncharcadas == null) {
      _mostrarErro('Informe se as roupas ficaram encharcadas');
      return;
    }
    if (_trocaVestimenta == null) {
      _mostrarErro('Informe se houve troca de vestimenta');
      return;
    }
    if (_temSintomasGastro == null) {
      _mostrarErro('Informe se teve sintomas gastrointestinais');
      return;
    }
    if (_temFadiga == null) {
      _mostrarErro('Informe se teve fadiga');
      return;
    }
    if (_borgSelecionado == null) {
      _mostrarErro('Selecione a intensidade na escala de Borg');
      return;
    }
    
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() => _isSaving = true);
    
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) {
        _mostrarErro('Usuario nao autenticado');
        setState(() => _isSaving = false);
        return;
      }
      
      final userId = session.user!.id;
      
      final pessoa = await _supabase
          .from('pessoas')
          .select()
          .eq('auth_user_id', userId)
          .maybeSingle();
      
      if (pessoa == null) {
        _mostrarErro('Dados do usuario nao encontrados');
        setState(() => _isSaving = false);
        return;
      }
      
      final atletaId = pessoa['id'].toString();
      
      final treino = SessaoTreino(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        atletaId: atletaId,
        atletaNome: pessoa['nome'],
        data: DateTime.now(),
        modalidade: widget.modalidade,
        duracaoMinutos: widget.duracaoRealSegundos ~/ 60,
        fluidosMl: widget.fluidosIngeridosMl,
        massaCorporalPreKg: widget.massaCorporalPre,
        massaCorporalPosKg: double.parse(_massaCorporalController.text),
        escalaBorg: _borgSelecionado!,
        teveSintomasGastro: _temSintomasGastro!,
        sintomasDescricao: _temSintomasGastro == true ? _sintomasGastroController.text : '',
        teveFadiga: _temFadiga!,
        fadigaDescricao: _temFadiga == true ? _fadigaController.text : '',
        temperatura: widget.temperatura,
        umidade: widget.umidade,
      );
      
      final salvo = await _db.salvarTreino(treino);
      
      if (!mounted) return;
      
      if (salvo) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Treino finalizado com sucesso'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      } else {
        _mostrarErro('Erro ao salvar o treino');
      }
    } catch (e) {
      print('Erro ao finalizar treino: $e');
      _mostrarErro('Erro inesperado ao salvar treino');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
  
  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: Colors.red),
    );
  }

  Widget _buildRadioGroup(String titulo, bool? valor, Function(bool?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('Sim'),
                value: true,
                groupValue: valor,
                onChanged: onChanged,
                activeColor: const Color(0xFFB30000),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('Nao'),
                value: false,
                groupValue: valor,
                onChanged: onChanged,
                activeColor: const Color(0xFFB30000),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pos-sessao'),
        centerTitle: true,
        backgroundColor: const Color(0xFFB30000),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Apos o treino',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              
              TextFormField(
                controller: _massaCorporalController,
                decoration: const InputDecoration(
                  labelText: 'Massa corporal pos-exercicio (kg)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Informe a massa corporal' : null,
              ),
              const SizedBox(height: 24),
              
              _buildRadioGroup('As roupas ficaram muito encharcadas?', _roupasEncharcadas, (v) => setState(() => _roupasEncharcadas = v)),
              const SizedBox(height: 16),
              
              _buildRadioGroup('Houve troca de vestimenta?', _trocaVestimenta, (v) => setState(() => _trocaVestimenta = v)),
              
              if (_roupasEncharcadas == true || _trocaVestimenta == true) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _observacaoRoupasController,
                  decoration: const InputDecoration(
                    labelText: 'Observacao sobre roupas',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (v) => v!.isEmpty ? 'Descreva a situacao' : null,
                ),
              ],
              const SizedBox(height: 24),
              
              DropdownButtonFormField<int>(
                value: _borgSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Escala de Borg (6 a 20)',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(15, (i) => DropdownMenuItem(value: i + 6, child: Text((i + 6).toString()))),
                onChanged: (v) => setState(() => _borgSelecionado = v),
                validator: (v) => v == null ? 'Selecione a intensidade' : null,
              ),
              const SizedBox(height: 24),
              
              _buildRadioGroup('Teve sintomas gastrointestinais?', _temSintomasGastro, (v) => setState(() => _temSintomasGastro = v)),
              
              if (_temSintomasGastro == true) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _sintomasGastroController,
                  decoration: const InputDecoration(
                    labelText: 'Descreva os sintomas',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (v) => v!.isEmpty ? 'Descreva os sintomas' : null,
                ),
              ],
              const SizedBox(height: 24),
              
              _buildRadioGroup('Sentiu fadiga?', _temFadiga, (v) => setState(() => _temFadiga = v)),
              
              if (_temFadiga == true) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _fadigaController,
                  decoration: const InputDecoration(
                    labelText: 'Descreva a fadiga',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (v) => v!.isEmpty ? 'Descreva a fadiga' : null,
                ),
              ],
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: _isSaving ? null : _finalizarTreino,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFB30000),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFB30000)),
                      )
                    : const Text('FINALIZAR TREINO', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}