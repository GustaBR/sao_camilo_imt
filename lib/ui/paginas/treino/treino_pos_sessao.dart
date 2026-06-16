import 'package:flutter/material.dart';
import '../../../services/radio_group.dart';
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
  
  bool? _roupasEncharcadas, _trocaVestimenta, _temSintomasGastro, _temFadiga;
  int? _borgSelecionado;
  bool _isSaving = false;

  double? _lerDecimal(String valor) {
    return double.tryParse(valor.trim().replaceAll(',', '.'));
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: Colors.red),
    );
  }

  Future<void> _finalizarTreino() async {
    if (_isSaving) return;

    if (_roupasEncharcadas == null || _trocaVestimenta == null || _temSintomasGastro == null || _temFadiga == null || _borgSelecionado == null) {
      _mostrarErro('Preencha todos os campos');
      return;
    }
    
    if (_formKey.currentState!.validate()) {
      final massaCorporalPos = _lerDecimal(_massaCorporalController.text);
      if (massaCorporalPos == null || massaCorporalPos <= 0) {
        _mostrarErro('Informe uma massa corporal valida');
        return;
      }

      final ativo = _db.getAtivoLogado();
      if (ativo == null) {
        _mostrarErro('Sessao do atleta nao encontrada. Faca login novamente.');
        return;
      }

      setState(() => _isSaving = true);

      try {
        final treino = SessaoTreino(
          atletaId: ativo['id'],
          atletaNome: ativo['nome'],
          modalidade: widget.modalidade,
          duracaoMinutos: widget.duracaoRealSegundos ~/ 60,
          duracaoPrevistaMin: widget.duracaoPrevista,
          duracaoRealSegundos: widget.duracaoRealSegundos,
          fluidosMl: widget.fluidosIngeridosMl,
          alimentosAgua: widget.alimentosAgua,
          volumeUrinarioMl: widget.volumeUrinarioMl,
          massaCorporalPreKg: widget.massaCorporalPre,
          massaCorporalPosKg: massaCorporalPos,
          escalaBorg: _borgSelecionado!,
          sensacaoTermica: widget.sensacaoTermica,
          vento: widget.vento,
          exposicaoSolar: widget.exposicaoSolar,
          corUrina: widget.corUrina,
          vestimenta: widget.vestimenta,
          equipamento: widget.equipamento,
          estaComSede: widget.estaComSede,
          sintomasPreDescricao: widget.sintomasDescricao,
          historicoHidratacao: widget.historicoHidratacao,
          roupasEncharcadas: _roupasEncharcadas!,
          trocaVestimenta: _trocaVestimenta!,
          observacaoRoupas: _roupasEncharcadas == true || _trocaVestimenta == true
              ? _observacaoRoupasController.text.trim()
              : '',
          teveSintomasGastro: _temSintomasGastro!,
          sintomasDescricao: _temSintomasGastro == true ? _sintomasGastroController.text : '',
          teveFadiga: _temFadiga!,
          fadigaDescricao: _temFadiga == true ? _fadigaController.text : '',
          temperatura: widget.temperatura,
          umidade: widget.umidade,
        );

        final salvo = await _db.salvarTreino(treino);
        if (!mounted) return;

        if (!salvo) {
          _mostrarErro(_db.ultimoErro ?? 'Erro ao salvar treino');
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Treino finalizado com sucesso!'), backgroundColor: Colors.green),
        );

        Navigator.popUntil(context, (route) => route.settings.name == '/atleta/treino');
      } catch (error) {
        if (!mounted) return;
        _mostrarErro('Erro inesperado ao finalizar treino: $error');
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pos-sessao'), centerTitle: true, backgroundColor: const Color(0xFFB30000)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text('Apos o treino', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextFormField(
                controller: _massaCorporalController,
                decoration: const InputDecoration(labelText: 'Massa corporal pos-exercicio (kg)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Informe a massa corporal' : null,
              ),
              const SizedBox(height: 24),
              const Text('As roupas ficaram muito encharcadas?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              CustomRadioGroup(value: _roupasEncharcadas, onChanged: (v) => setState(() => _roupasEncharcadas = v)),
              const SizedBox(height: 16),
              const Text('Houve troca de vestimenta?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              CustomRadioGroup(value: _trocaVestimenta, onChanged: (v) => setState(() => _trocaVestimenta = v)),
              if (_roupasEncharcadas == true || _trocaVestimenta == true) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _observacaoRoupasController,
                  decoration: const InputDecoration(labelText: 'Observacao sobre roupas', border: OutlineInputBorder()),
                  maxLines: 3,
                  validator: (v) => v!.isEmpty ? 'Descreva a situacao' : null,
                ),
              ],
              const SizedBox(height: 24),
              DropdownButtonFormField<int>(
                value: _borgSelecionado,
                decoration: const InputDecoration(labelText: 'Escala de Borg (6 a 20)', border: OutlineInputBorder()),
                items: List.generate(15, (i) => DropdownMenuItem(value: i + 6, child: Text((i + 6).toString()))),
                onChanged: (v) => setState(() => _borgSelecionado = v),
                validator: (v) => v == null ? 'Selecione a intensidade' : null,
              ),
              const SizedBox(height: 24),
              const Text('Teve sintomas gastrointestinais?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              CustomRadioGroup(value: _temSintomasGastro, onChanged: (v) => setState(() => _temSintomasGastro = v)),
              if (_temSintomasGastro == true) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _sintomasGastroController,
                  decoration: const InputDecoration(labelText: 'Descreva os sintomas', border: OutlineInputBorder()),
                  maxLines: 3,
                  validator: (v) => v!.isEmpty ? 'Descreva os sintomas' : null,
                ),
              ],
              const SizedBox(height: 24),
              const Text('Sentiu fadiga?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              CustomRadioGroup(value: _temFadiga, onChanged: (v) => setState(() => _temFadiga = v)),
              if (_temFadiga == true) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _fadigaController,
                  decoration: const InputDecoration(labelText: 'Descreva a fadiga', border: OutlineInputBorder()),
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
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFB30000)))
                    : const Text('FINALIZAR TREINO', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}