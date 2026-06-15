import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/nota.dart';
import '../models/sessao_treino.dart';

const String _sessionStorageKey = 'nutri_esportiva_sessao';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // Cliente oficial do Supabase
  final _supabase = Supabase.instance.client;

  String? _ativoLogadoId;
  String? _ativoLogadoNome;
  String? _ativoLogadoTipo;
  String? _ativoLogadoCodigo;
  Map<String, dynamic>? _profissionalLogado;

  // ========== SESSÃO LOCAL ==========
  Future<void> carregarSessaoSalva() async {
    final prefs = await SharedPreferences.getInstance();
    final rawSession = prefs.getString(_sessionStorageKey);
    if (rawSession == null || rawSession.isEmpty) return;

    try {
      final data = jsonDecode(rawSession);
      if (data is Map<String, dynamic>) {
        _aplicarSessao(data);
      } else {
        await prefs.remove(_sessionStorageKey);
      }
    } catch (error) {
      debugPrint('Erro ao carregar sessao salva: $error');
      await prefs.remove(_sessionStorageKey);
    }
  }

  void _aplicarSessao(Map<String, dynamic> data) {
    final id = data['id']?.toString();
    final nome = data['nome']?.toString();
    final tipo = data['tipo']?.toString();

    if (id == null || id.isEmpty || nome == null || nome.isEmpty || tipo == null || tipo.isEmpty) {
      return;
    }

    _ativoLogadoId = id;
    _ativoLogadoNome = nome;
    _ativoLogadoTipo = tipo;
    _ativoLogadoCodigo = data['codigo']?.toString();
    _profissionalLogado = tipo == 'atleta' ? null : Map<String, dynamic>.from(data);
  }

  Future<void> _salvarSessaoAtual() async {
    final prefs = await SharedPreferences.getInstance();
    if (_ativoLogadoId == null || _ativoLogadoNome == null || _ativoLogadoTipo == null) {
      await prefs.remove(_sessionStorageKey);
      return;
    }

    await prefs.setString(
      _sessionStorageKey,
      jsonEncode({
        'id': _ativoLogadoId,
        'nome': _ativoLogadoNome,
        'tipo': _ativoLogadoTipo,
        'codigo': _ativoLogadoCodigo,
        if (_profissionalLogado?['email'] != null) 'email': _profissionalLogado?['email'],
      }),
    );
  }

  Future<void> _limparSessaoSalva() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionStorageKey);
  }

  // ========== ATLETAS ==========
  Future<String?> cadastrarAtleta(
    String nome,
    String email,
    String senha, {
    required String dataNascimento,
    required double altura,
    required double peso,
    required String sexo,
  }) async {
    try {
      // 1. Cria usuário no Auth do Supabase
      final authResponse = await _supabase.auth.signUp(email: email, password: senha);
      if (authResponse.user == null) return null;

      final authId = authResponse.user!.id;
      final alturaBanco = altura > 3 ? altura / 100 : altura;

      // 2. Insere na tabela pessoas
      final pessoaData = await _supabase.from('pessoas').insert({
        'nome': nome,
        'email': email,
        'auth_user_id': authId,
      }).select().single();

      // 3. Insere na tabela atletas
      final atletaData = await _supabase.from('atletas').insert({
        'id': pessoaData['id'],
        'altura': alturaBanco,
        'peso': peso,
        'data_nasc': dataNascimento,
        'sexo': sexo,
      }).select().single();

      // RETORNA O ID PARA NÃO DAR ERRO DE NULO
      return atletaData['id']?.toString(); 
    } catch (error) {
      // JOGA O ERRO PRA TELA
      throw 'Erro Atleta: $error';
    }
  }

  // ========== PROFISSIONAIS ==========
  Future<Map<String, dynamic>?> cadastrarProfissional(
    String nome,
    String email,
    String senha,
    String tipo,
    String registro,
  ) async {
    try {
      // 1. Cria usuário no Auth do Supabase
      final authResponse = await _supabase.auth.signUp(email: email, password: senha);
      if (authResponse.user == null) return null;

      final authId = authResponse.user!.id;

      // 2. Insere na tabela base 'pessoas'
      final pessoaData = await _supabase.from('pessoas').insert({
        'nome': nome,
        'email': email,
        'auth_user_id': authId,
      }).select().single();

      final pessoaId = pessoaData['id'];
      Map<String, dynamic> profissionalData;

      // 3. Insere na tabela específica dependendo do tipo
        if (tipo == 'medico') {
        profissionalData = await _supabase.from('medicos').insert({
          'id': pessoaId,
          'crm': registro, 
        }).select().single();
      } else if (tipo == 'nutricionista') {
        profissionalData = await _supabase.from('nutricionistas').insert({
          'id': pessoaId,
          'crn': registro, 
        }).select().single();
      } else if (tipo == 'treinador') { 
        profissionalData = await _supabase.from('treinadores').insert({
          'id': pessoaId,
        }).select().single();
      } else {
        throw Exception('Tipo de profissional desconhecido: $tipo');
      }

      // Retorna os dados combinados
      return {
        ...pessoaData,
        ...profissionalData,
        'tipo': tipo,
      };
    } catch (error) {
      // JOGA O ERRO PRA TELA
      throw 'Erro Profissional: $error';
    }
  }

  Future<Map<String, dynamic>?> getAtleta(String codigo) async {
    try {
      final data = await _supabase
          .from('atletas')
          .select('*, pessoas(nome, email)')
          .eq('codigo_acesso', codigo)
          .single();

      final altura = data['altura'];
      if (altura is num) {
        data['altura'] = (altura * 100).round();
      }
      return data;
    } catch (error) {
      debugPrint('Erro ao buscar atleta: $error');
      return null;
    }
  }

  Future<bool> validarCodigoAtleta(String codigo) async {
    final atleta = await getAtleta(codigo);
    return atleta != null;
  }

  // ========== AUTENTICAÇÃO ==========
  Future<Map<String, dynamic>?> autenticarAtleta(String email, String senha) => _autenticar(email, senha, 'atleta');
  Future<Map<String, dynamic>?> autenticarMedico(String email, String senha) => _autenticar(email, senha, 'medico');
  Future<Map<String, dynamic>?> autenticarNutricionista(String email, String senha) => _autenticar(email, senha, 'nutricionista');
  Future<Map<String, dynamic>?> autenticarTreinador(String email, String senha) => _autenticar(email, senha, 'treinador');

  Future<Map<String, dynamic>?> _autenticar(String email, String senha, String tipo) async {
    try {
      // Faz login no Supabase Auth
      final authResponse = await _supabase.auth.signInWithPassword(email: email, password: senha);
      if (authResponse.user == null) return null;

      // Busca a pessoa atrelada a este usuário logado
      final pessoa = await _supabase
          .from('pessoas')
          .select()
          .eq('auth_user_id', authResponse.user!.id)
          .single();

      // Dependendo do tipo, busca os dados específicos
      Map<String, dynamic> usuarioFinal = {
        'id': pessoa['id'],
        'nome': pessoa['nome'],
        'email': pessoa['email'],
        'tipo': tipo,
      };

      if (tipo == 'atleta') {
        final atleta = await _supabase.from('atletas').select().eq('id', pessoa['id']).single();
        usuarioFinal['codigo'] = atleta['codigo_acesso'];
        usuarioFinal.addAll(atleta);
      } else if (tipo == 'medico') {
        final medico = await _supabase.from('medicos').select().eq('id', pessoa['id']).single();
        usuarioFinal.addAll(medico);
      } else if (tipo == 'nutricionista') {
        final nutri = await _supabase.from('nutricionistas').select().eq('id', pessoa['id']).single();
        usuarioFinal.addAll(nutri);
      } else if (tipo == 'treinador') { 
        final treinador = await _supabase.from('treinadores').select().eq('id', pessoa['id']).single();
        usuarioFinal.addAll(treinador);
      }

      // Salva sessão local 
      _ativoLogadoId = tipo == 'atleta' ? usuarioFinal['codigo']?.toString() : usuarioFinal['id']?.toString();
      _ativoLogadoNome = usuarioFinal['nome']?.toString();
      _ativoLogadoTipo = tipo;
      _ativoLogadoCodigo = usuarioFinal['codigo']?.toString();
      _profissionalLogado = tipo != 'atleta' ? usuarioFinal : null;
      
      await _salvarSessaoAtual();
      
      return usuarioFinal;
    } catch (error) {
      // JOGA O ERRO PRA TELA
      throw 'Erro Login Automático: $error';
    }
  }

  Future<Map<String, dynamic>?> atualizarDadosAtleta(
    String codigo, {
    double? peso,
    double? altura,
    String? dataNascimento,
    String? sexo,
  }) async {
    try {
      final alturaBanco = altura != null && altura > 3 ? altura / 100 : altura;
      
      final updateData = <String, dynamic>{};
      if (peso != null) updateData['peso'] = peso;
      if (alturaBanco != null) updateData['altura'] = alturaBanco;
      if (dataNascimento != null) updateData['data_nasc'] = dataNascimento;
      if (sexo != null) updateData['sexo'] = sexo;

      final data = await _supabase
          .from('atletas')
          .update(updateData)
          .eq('codigo_acesso', codigo)
          .select()
          .single();

      final alturaAtualizada = data['altura'];
      if (alturaAtualizada is num) {
        data['altura'] = (alturaAtualizada * 100).round();
      }
      return data;
    } catch (error) {
      debugPrint('Erro ao atualizar atleta: $error');
      return null;
    }
  }

  // ========== TREINOS ==========
  Future<bool> salvarTreino(SessaoTreino treino) async {
    try {
      await _supabase.from('treinos').insert(treino.toJson());
      return true;
    } catch (error) {
      debugPrint('Erro ao salvar treino: $error');
      return false;
    }
  }

  Future<List<SessaoTreino>> getTreinosDoAtleta(String atletaId) async {
    try {
      final data = await _supabase
          .from('treinos')
          .select()
          .eq('atletas_id', atletaId)
          .order('data_hora', ascending: false);

      return data.map((json) => SessaoTreino.fromJson(json)).toList();
    } catch (error) {
      debugPrint('Erro ao buscar treinos: $error');
      return [];
    }
  }

  // ========== NOTAS ==========
  Future<bool> salvarNota(Nota nota) async {
    try {
      await _supabase.from('notas_atletas').insert(nota.toJson());
      return true;
    } catch (error) {
      debugPrint('Erro ao salvar nota: $error');
      return false;
    }
  }

  Future<List<Nota>> getNotasDoAtleta(String atletaCodigo) async {
    try {
      final atleta = await getAtleta(atletaCodigo);
      if (atleta == null) return [];

      final data = await _supabase
          .from('notas_atletas')
          .select()
          .eq('atletas_id', atleta['id'])
          .order('criado_em', ascending: false);

      return data.map((json) => Nota.fromJson(json)).toList();
    } catch (error) {
      debugPrint('Erro ao buscar notas: $error');
      return [];
    }
  }

  // ========== GETTERS & LOGOUT ==========
  Map<String, dynamic>? getProfissional(String usuario) {
    if (_profissionalLogado?['id']?.toString() == usuario) {
      return _profissionalLogado;
    }
    return null;
  }

  Map<String, dynamic>? getAtivoLogado() {
    if (_ativoLogadoId == null) return null;
    return {
      'id': _ativoLogadoId,
      'nome': _ativoLogadoNome,
      'tipo': _ativoLogadoTipo,
      'codigo': _ativoLogadoCodigo,
    };
  }

  Map<String, dynamic>? getProfissionalLogado() => _profissionalLogado;

  Future<void> logout() async {
    await _supabase.auth.signOut();
    
    _ativoLogadoId = null;
    _ativoLogadoNome = null;
    _ativoLogadoTipo = null;
    _ativoLogadoCodigo = null;
    _profissionalLogado = null;
    await _limparSessaoSalva();
  }

  Future<void> logoutProfissional() => logout();

  // ========== RELACIONAMENTOS N-N ==========
  Future<List<Map<String, dynamic>>> getAtletasDoProfissional(String profissionalId) async {
    try {
      final tipoTabela = _ativoLogadoTipo == 'medico' ? 'medicos_atletas' : 'nutricionistas_atletas';
      final colunaProfissional = _ativoLogadoTipo == 'medico' ? 'medicos_id' : 'nutricionistas_id';

      final data = await _supabase
          .from(tipoTabela)
          .select('atletas(*, pessoas(nome, email))')
          .eq(colunaProfissional, profissionalId);

      return data.map<Map<String, dynamic>>((e) => e['atletas'] as Map<String, dynamic>).toList();
    } catch (error) {
      debugPrint('Erro ao buscar atletas do profissional: $error');
      return [];
    }
  }

  Future<bool> adicionarAtletaAoProfissional(String profissionalId, String codigoAtleta) async {
    try {
      final atleta = await getAtleta(codigoAtleta);
      if (atleta == null) return false;

      final tipoTabela = _ativoLogadoTipo == 'medico' ? 'medicos_atletas' : 'nutricionistas_atletas';
      final colunaProfissional = _ativoLogadoTipo == 'medico' ? 'medicos_id' : 'nutricionistas_id';

      await _supabase.from(tipoTabela).insert({
        colunaProfissional: profissionalId,
        'atletas_id': atleta['id'],
      });
      return true;
    } catch (error) {
      debugPrint('Erro ao adicionar atleta: $error');
      return false;
    }
  }

  Future<bool> removerAtletaDoProfissional(String profissionalId, String atletaCodigo) async {
    try {
      final atleta = await getAtleta(atletaCodigo);
      if (atleta == null) return false;

      final tipoTabela = _ativoLogadoTipo == 'medico' ? 'medicos_atletas' : 'nutricionistas_atletas';
      final colunaProfissional = _ativoLogadoTipo == 'medico' ? 'medicos_id' : 'nutricionistas_id';

      await _supabase.from(tipoTabela)
          .delete()
          .eq(colunaProfissional, profissionalId)
          .eq('atletas_id', atleta['id']);
      return true;
    } catch (error) {
      debugPrint('Erro ao remover atleta: $error');
      return false;
    }
  }
}