import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/nota.dart';
import '../models/sessao_treino.dart';

const String _configuredApiBaseUrl = String.fromEnvironment('API_BASE_URL');
const String _sessionStorageKey = 'nutri_esportiva_sessao';

String _defaultApiBaseUrl() {
  if (kIsWeb) return 'http://localhost:8000';
  if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:8000';
  return 'http://localhost:8000';
}

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  String? _ativoLogadoId;
  String? _ativoLogadoNome;
  String? _ativoLogadoTipo;
  String? _ativoLogadoCodigo;
  Map<String, dynamic>? _profissionalLogado;
  String? _ultimoErro;

  String? get ultimoErro => _ultimoErro;

  String get _apiBaseUrl {
    if (_configuredApiBaseUrl.isNotEmpty) return _configuredApiBaseUrl;
    return _defaultApiBaseUrl();
  }

  Uri _uri(String path) => Uri.parse('$_apiBaseUrl$path');

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

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    _ultimoErro = null;
    final headers = {'Content-Type': 'application/json'};
    late http.Response response;

    try {
      switch (method) {
        case 'GET':
          response = await http.get(_uri(path), headers: headers);
          break;
        case 'POST':
          response = await http.post(_uri(path), headers: headers, body: jsonEncode(body ?? {}));
          break;
        case 'PATCH':
          response = await http.patch(_uri(path), headers: headers, body: jsonEncode(body ?? {}));
          break;
        case 'DELETE':
          response = await http.delete(_uri(path), headers: headers);
          break;
        default:
          throw ArgumentError('Metodo HTTP nao suportado: $method');
      }
    } catch (error) {
      _ultimoErro =
          'Nao foi possivel conectar a API em $_apiBaseUrl. Confirme se o backend esta rodando e se a URL esta acessivel pelo dispositivo.';
      throw Exception(_ultimoErro);
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      _ultimoErro = _mensagemErroResposta(response);
      throw Exception('Erro ${response.statusCode}: $_ultimoErro');
    }

    if (response.bodyBytes.isEmpty) return null;
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  String _mensagemErroResposta(http.Response response) {
    final rawBody = utf8.decode(response.bodyBytes);
    if (rawBody.isEmpty) return 'Erro ${response.statusCode} na API.';

    try {
      final data = jsonDecode(rawBody);
      if (data is Map<String, dynamic>) {
        final detail = data['detail'];
        if (detail is String && detail.trim().isNotEmpty) {
          return detail;
        }
        if (detail != null) return detail.toString();
      }
    } catch (_) {
      // Usa o corpo bruto quando a API nao retorna JSON.
    }

    return rawBody;
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
      final alturaBanco = altura > 3 ? altura / 100 : altura;
      final data = await _request(
        'POST',
        '/atletas',
        body: {
          'nome': nome,
          'email': email,
          'senha': senha,
          'dataNascimento': dataNascimento,
          'altura': alturaBanco,
          'peso': peso,
          'sexo': sexo,
        },
      );
      if (data is Map<String, dynamic>) {
        return data['codigo']?.toString();
      }
    } catch (error) {
      _ultimoErro ??= error.toString();
      debugPrint('Erro ao cadastrar atleta: $error');
    }
    return null;
  }

  Future<Map<String, dynamic>?> cadastrarProfissional(
    String nome,
    String email,
    String senha,
    String tipo,
    String registro,
  ) async {
    try {
      final data = await _request(
        'POST',
        '/profissionais',
        body: {
          'nome': nome,
          'email': email,
          'senha': senha,
          'tipo': tipo,
          'registro': registro,
        },
      );
      if (data is Map<String, dynamic>) {
        return data;
      }
    } catch (error) {
      _ultimoErro ??= error.toString();
      debugPrint('Erro ao cadastrar profissional: $error');
    }
    return null;
  }

  Future<Map<String, dynamic>?> getAtleta(String codigo) async {
    try {
      final data = await _request('GET', '/atletas/${Uri.encodeComponent(codigo)}');
      if (data is Map<String, dynamic>) {
        final altura = data['altura'];
        if (altura is num) {
          data['altura'] = (altura * 100).round();
        }
        return data;
      }
    } catch (error) {
      debugPrint('Erro ao buscar atleta: $error');
    }
    return null;
  }

  Future<bool> validarCodigoAtleta(String codigo) async {
    final atleta = await getAtleta(codigo);
    return atleta != null;
  }

  Future<Map<String, dynamic>?> autenticarAtleta(String email, String senha) {
    return _autenticar(email, senha, 'atleta');
  }

  Future<Map<String, dynamic>?> autenticarMedico(String email, String senha) {
    return _autenticar(email, senha, 'medico');
  }

  Future<Map<String, dynamic>?> autenticarNutricionista(String email, String senha) {
    return _autenticar(email, senha, 'nutricionista');
  }

  Future<Map<String, dynamic>?> autenticarTreinador(String email, String senha) {
    return _autenticar(email, senha, 'treinador');
  }

  Future<Map<String, dynamic>?> _autenticar(String email, String senha, String tipo) async {
    try {
      final data = await _request(
        'POST',
        '/auth/login',
        body: {'email': email, 'senha': senha, 'tipo': tipo},
      );
      if (data is Map<String, dynamic>) {
        _ativoLogadoId = tipo == 'atleta'
            ? data['codigo']?.toString() ?? data['id']?.toString()
            : data['id']?.toString();
        _ativoLogadoNome = data['nome']?.toString();
        _ativoLogadoTipo = data['tipo']?.toString();
        _ativoLogadoCodigo = data['codigo']?.toString();
        if (tipo != 'atleta') {
          _profissionalLogado = data;
        } else {
          _profissionalLogado = null;
        }
        await _salvarSessaoAtual();
        return data;
      }
    } catch (error) {
      debugPrint('Erro ao autenticar $tipo: $error');
    }
    return null;
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
      final data = await _request(
        'PATCH',
        '/atletas/${Uri.encodeComponent(codigo)}',
        body: {
          'peso': peso,
          'altura': alturaBanco,
          'dataNascimento': dataNascimento,
          'sexo': sexo,
        },
      );
      if (data is Map<String, dynamic>) {
        final altura = data['altura'];
        if (altura is num) {
          data['altura'] = (altura * 100).round();
        }
        return data;
      }
    } catch (error) {
      debugPrint('Erro ao atualizar atleta: $error');
    }
    return null;
  }

  Future<bool> salvarTreino(SessaoTreino treino) async {
    try {
      await _request('POST', '/treinos', body: treino.toJson());
      return true;
    } catch (error) {
      debugPrint('Erro ao salvar treino: $error');
      return false;
    }
  }

  Future<bool> deletarTreino(String treinoId) async {
    try {
      await _request('DELETE', '/treinos/${Uri.encodeComponent(treinoId)}');
      return true;
    } catch (error) {
      debugPrint('Erro ao deletar treino: $error');
      return false;
    }
  }

  Future<List<SessaoTreino>> getTreinosDoAtleta(String atletaId) async {
    try {
      final data = await _request('GET', '/atletas/${Uri.encodeComponent(atletaId)}/treinos');
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(SessaoTreino.fromJson)
            .toList();
      }
    } catch (error) {
      debugPrint('Erro ao buscar treinos: $error');
    }
    return [];
  }

  // ========== NOTAS ==========
  Future<bool> salvarNota(Nota nota) async {
    try {
      await _request(
        'POST',
        '/atletas/${Uri.encodeComponent(nota.atletaCodigo)}/notas',
        body: nota.toJson(),
      );
      return true;
    } catch (error) {
      debugPrint('Erro ao salvar nota: $error');
      return false;
    }
  }

  Future<List<Nota>> getNotasDoAtleta(String atletaCodigo) async {
    try {
      final data = await _request('GET', '/atletas/${Uri.encodeComponent(atletaCodigo)}/notas');
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(Nota.fromJson)
            .toList();
      }
    } catch (error) {
      debugPrint('Erro ao buscar notas: $error');
    }
    return [];
  }

  // ========== PROFISSIONAIS ==========
  Future<bool> autenticarProfissional(String usuario, String senha) async {
    final medico = await autenticarMedico(usuario, senha);
    if (medico != null) return true;
    
    final nutricionista = await autenticarNutricionista(usuario, senha);
    if (nutricionista != null) return true;
    
    final treinador = await autenticarTreinador(usuario, senha);
    return treinador != null;
  }

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

  Map<String, dynamic>? getProfissionalLogado() {
    return _profissionalLogado;
  }

  Future<void> logout() async {
    _ativoLogadoId = null;
    _ativoLogadoNome = null;
    _ativoLogadoTipo = null;
    _ativoLogadoCodigo = null;
    _profissionalLogado = null;
    await _limparSessaoSalva();
  }

  Future<List<Map<String, dynamic>>> getAtletasDoProfissional(String profissionalId) async {
    try {
      final data = await _request(
        'GET',
        '/profissionais/${Uri.encodeComponent(profissionalId)}/atletas',
      );
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().toList();
      }
    } catch (error) {
      debugPrint('Erro ao buscar atletas do profissional: $error');
    }
    return [];
  }

  Future<bool> adicionarAtletaAoProfissional(String profissionalId, String codigoAtleta) async {
    try {
      final data = await _request(
        'POST',
        '/profissionais/${Uri.encodeComponent(profissionalId)}/atletas',
        body: {'codigo': codigoAtleta},
      );
      if (data is Map<String, dynamic>) {
        return data['ok'] == true;
      }
      return true;
    } catch (error) {
      debugPrint('Erro ao adicionar atleta ao profissional: $error');
      return false;
    }
  }

  Future<bool> removerAtletaDoProfissional(String profissionalId, String atletaCodigo) async {
    try {
      final data = await _request(
        'DELETE',
        '/profissionais/${Uri.encodeComponent(profissionalId)}/atletas/${Uri.encodeComponent(atletaCodigo)}',
      );
      if (data is Map<String, dynamic>) {
        return data['ok'] == true;
      }
      return true;
    } catch (error) {
      debugPrint('Erro ao remover atleta do profissional: $error');
      return false;
    }
  }

  Future<void> logoutProfissional() {
    return logout();
  }
}