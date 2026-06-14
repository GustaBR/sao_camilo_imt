// lib/screens/services/atleta_data_manager.dart
import 'dart:math';
import '../models/sessao_treino.dart';

class AtletaDataManager {
  static final AtletaDataManager _instance = AtletaDataManager._internal();
  factory AtletaDataManager() => _instance;
  AtletaDataManager._internal();

  final Map<String, Map<String, dynamic>> _perfilAtletas = {};
  final Map<String, List<SessaoTreino>> _sessoesPorAtleta = {};
  String? _codigoAtletaLogado;

  String gerarCodigoAtleta(String nomeAtleta, String email) {
    String codigo = _gerarCodigoAleatorio();
    
    _perfilAtletas[codigo] = {
      'nome': nomeAtleta,
      'email': email,
      'dataCriacao': DateTime.now(),
    };
    
    _sessoesPorAtleta[codigo] = [];
    _codigoAtletaLogado = codigo;
    
    return codigo;
  }

  String _gerarCodigoAleatorio() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    String codigo = '';
    for (int i = 0; i < 8; i++) {
      codigo += chars[random.nextInt(chars.length)];
    }
    return codigo;
  }

  bool validarCodigo(String codigo) {
    return _perfilAtletas.containsKey(codigo);
  }

  String? getNomeAtleta(String codigo) {
    return _perfilAtletas[codigo]?['nome'];
  }

  String? getEmailAtleta(String codigo) {
    return _perfilAtletas[codigo]?['email'];
  }

  void setAtletaLogado(String codigo) {
    if (_perfilAtletas.containsKey(codigo)) {
      _codigoAtletaLogado = codigo;
    }
  }

  String? getCodigoAtletaLogado() {
    return _codigoAtletaLogado;
  }

  void logout() {
    _codigoAtletaLogado = null;
  }

  void salvarSessao(SessaoTreino sessao) {
    if (_sessoesPorAtleta.containsKey(sessao.codigoAtleta)) {
      _sessoesPorAtleta[sessao.codigoAtleta]!.insert(0, sessao);
    }
  }

  List<SessaoTreino> getSessoesAtleta(String codigoAtleta) {
    return _sessoesPorAtleta[codigoAtleta] ?? [];
  }

  List<SessaoTreino> getSessoesAtletaLogado() {
    if (_codigoAtletaLogado == null) return [];
    return getSessoesAtleta(_codigoAtletaLogado!);
  }

  SessaoTreino? getUltimaSessao(String codigoAtleta) {
    List<SessaoTreino> sessoes = getSessoesAtleta(codigoAtleta);
    return sessoes.isNotEmpty ? sessoes.first : null;
  }

  void adicionarDadosExemplo() {
    String codigoExemplo = gerarCodigoAtleta("João Silva", "joao@exemplo.com");
    
    SessaoTreino exemplo = SessaoTreino(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      codigoAtleta: codigoExemplo,
      data: DateTime.now(),
      massaCorporalPreKg: 72.5,
      modalidade: "Corrida de rua",
      duracaoPrevistaMin: 60,
      temperatura: 25.0,
      umidade: 65.0,
      sensacaoTermica: 24.0,
      vento: "Fraco",
      exposicaoSolar: "Moderada",
      corUrina: "Amarelo claro",
      vestimenta: "Camiseta e short",
      equipamento: "Tênis de corrida",
      estaComSede: false,
      temSintomasPre: false,
      sintomasDescricao: "",
      historicoHidratacao: "Bebi 500ml 1 hora antes",
      duracaoRealSegundos: 3660,
      fluidosIngeridosMl: 750,
      alimentosAgua: "Nenhum",
      volumeUrinarioMl: 200,
      massaCorporalPosKg: 71.8,
      roupasEncharcadas: true,
      trocaVestimenta: false,
      observacaoRoupas: "Camiseta bastante suada",
      escalaBorg: 14,
      teveSintomasGastro: false,
      sintomasGastroDescricao: "",
      teveFadiga: true,
      fadigaDescricao: "Cansaço nas pernas",
    );
    
    salvarSessao(exemplo);
    
    print('=== CÓDIGO DE EXEMPLO ===');
    print('Código: $codigoExemplo');
    print('==========================');
  }
}