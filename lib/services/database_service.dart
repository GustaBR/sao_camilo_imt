import 'dart:math';
import '../models/sessao_treino.dart';
import '../models/nota.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final Map<String, Map<String, dynamic>> _atletas = {};
  final Map<String, List<SessaoTreino>> _treinosPorAtleta = {};
  final Map<String, List<Nota>> _notasPorAtleta = {};
  
  final Map<String, Map<String, dynamic>> _profissionais = {
    'medico_joao': {
      'id': 'medico_joao',
      'nome': 'Dr. João Silva',
      'tipo': 'medico',
      'email': 'medico@email.com',
      'senha': '123',
    },
    'nutri_maria': {
      'id': 'nutri_maria',
      'nome': 'Nutri. Maria Santos',
      'tipo': 'nutricionista',
      'email': 'nutri@email.com',
      'senha': '123',
    },
  };
  
  final Map<String, List<String>> _profissionaisAtletas = {
    'medico_joao': [],
    'nutri_maria': [],
  };

  String? _ativoLogadoId;
  String? _ativoLogadoNome;

  // ========== ATLETAS ==========
  String cadastrarAtleta(String nome, String email, String senha) {
    String codigo = _gerarCodigo();
    _atletas[codigo] = {
      'codigo': codigo,
      'nome': nome,
      'email': email,
      'senha': senha,
      'idade': null,
      'peso': null,
      'altura': null,
      'telefone': null,
      'dataCadastro': DateTime.now(),
    };
    _treinosPorAtleta[codigo] = [];
    return codigo;
  }

  String _gerarCodigo() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    String codigo = '';
    for (int i = 0; i < 6; i++) {
      codigo += chars[random.nextInt(chars.length)];
    }
    return codigo;
  }

  Map<String, dynamic>? getAtleta(String codigo) {
    return _atletas[codigo];
  }

  bool validarCodigoAtleta(String codigo) {
    return _atletas.containsKey(codigo);
  }

  Map<String, dynamic>? autenticarAtleta(String email, String senha) {
    for (var atleta in _atletas.values) {
      if (atleta['email'] == email && atleta['senha'] == senha) {
        return atleta;
      }
    }
    return null;
  }

  Map<String, dynamic>? autenticarMedico(String email, String senha) {
    for (var medico in _profissionais.values) {
      if (medico['tipo'] == 'medico' && medico['email'] == email && medico['senha'] == senha) {
        return medico;
      }
    }
    return null;
  }

  Map<String, dynamic>? autenticarNutricionista(String email, String senha) {
    for (var nutri in _profissionais.values) {
      if (nutri['tipo'] == 'nutricionista' && nutri['email'] == email && nutri['senha'] == senha) {
        return nutri;
      }
    }
    return null;
  }

  void atualizarDadosAtleta(String codigo, {int? idade, double? peso, double? altura, String? telefone}) {
    if (_atletas.containsKey(codigo)) {
      if (idade != null) _atletas[codigo]!['idade'] = idade;
      if (peso != null) _atletas[codigo]!['peso'] = peso;
      if (altura != null) _atletas[codigo]!['altura'] = altura;
      if (telefone != null) _atletas[codigo]!['telefone'] = telefone;
    }
  }

  void salvarTreino(SessaoTreino treino) {
    if (_treinosPorAtleta.containsKey(treino.atletaId)) {
      _treinosPorAtleta[treino.atletaId]!.insert(0, treino);
    }
  }

  List<SessaoTreino> getTreinosDoAtleta(String atletaId) {
    return _treinosPorAtleta[atletaId] ?? [];
  }

  // ========== NOTAS ==========
  void salvarNota(Nota nota) {
    if (!_notasPorAtleta.containsKey(nota.atletaCodigo)) {
      _notasPorAtleta[nota.atletaCodigo] = [];
    }
    _notasPorAtleta[nota.atletaCodigo]!.insert(0, nota);
  }

  List<Nota> getNotasDoAtleta(String atletaCodigo) {
    return _notasPorAtleta[atletaCodigo] ?? [];
  }

  // ========== PROFISSIONAIS ==========
  bool autenticarProfissional(String usuario, String senha) {
    return _profissionais.containsKey(usuario) && _profissionais[usuario]!['senha'] == senha;
  }

  Map<String, dynamic>? getProfissional(String usuario) {
    return _profissionais[usuario];
  }

  void setAtivoLogado(String id, String nome) {
    _ativoLogadoId = id;
    _ativoLogadoNome = nome;
  }

  Map<String, dynamic>? getAtivoLogado() {
    if (_ativoLogadoId == null) return null;
    return {'id': _ativoLogadoId, 'nome': _ativoLogadoNome};
  }

  Map<String, dynamic>? getProfissionalLogado() {
    if (_ativoLogadoId == null) return null;
    return getProfissional(_ativoLogadoId!);
  }

  void logout() {
    _ativoLogadoId = null;
    _ativoLogadoNome = null;
  }

  void logoutProfissional() {
    logout();
  }

  List<Map<String, dynamic>> getAtletasDoProfissional(String profissionalId) {
    List<String> codigosAtletas = _profissionaisAtletas[profissionalId] ?? [];
    List<Map<String, dynamic>> atletas = [];
    for (String codigo in codigosAtletas) {
      if (_atletas.containsKey(codigo)) {
        atletas.add(_atletas[codigo]!);
      }
    }
    return atletas;
  }

  bool adicionarAtletaAoProfissional(String profissionalId, String codigoAtleta) {
    if (!_atletas.containsKey(codigoAtleta)) return false;
    if (!_profissionaisAtletas.containsKey(profissionalId)) {
      _profissionaisAtletas[profissionalId] = [];
    }
    if (!_profissionaisAtletas[profissionalId]!.contains(codigoAtleta)) {
      _profissionaisAtletas[profissionalId]!.add(codigoAtleta);
    }
    return true;
  }

  bool removerAtletaDoProfissional(String profissionalId, String atletaCodigo) {
    if (_profissionaisAtletas.containsKey(profissionalId)) {
      return _profissionaisAtletas[profissionalId]!.remove(atletaCodigo);
    }
    return false;
  }

  void carregarDadosExemplo() {
    String atleta1 = cadastrarAtleta("João Silva", "joao@email.com", "123");
    _treinosPorAtleta[atleta1] = [
      SessaoTreino(
        id: '1',
        atletaId: atleta1,
        atletaNome: "João Silva",
        data: DateTime.now().subtract(const Duration(days: 2)),
        modalidade: "Corrida de rua",
        duracaoMinutos: 75,
        fluidosMl: 750,
        massaCorporalPreKg: 72.5,
        massaCorporalPosKg: 71.8,
        escalaBorg: 14,
        teveSintomasGastro: false,
        sintomasDescricao: "",
        teveFadiga: true,
        fadigaDescricao: "Cansaço nas pernas",
        temperatura: 28,
        umidade: 65,
      ),
    ];

    String atleta2 = cadastrarAtleta("Maria Oliveira", "maria@email.com", "123");
    _treinosPorAtleta[atleta2] = [
      SessaoTreino(
        id: '2',
        atletaId: atleta2,
        atletaNome: "Maria Oliveira",
        data: DateTime.now().subtract(const Duration(days: 1)),
        modalidade: "Natação",
        duracaoMinutos: 60,
        fluidosMl: 900,
        massaCorporalPreKg: 65.0,
        massaCorporalPosKg: 64.5,
        escalaBorg: 13,
        teveSintomasGastro: true,
        sintomasDescricao: "Leve náusea",
        teveFadiga: true,
        fadigaDescricao: "Cansaço geral",
        temperatura: 26,
        umidade: 70,
      ),
    ];

    String atleta3 = cadastrarAtleta("Pedro Costa", "pedro@email.com", "123");
    _treinosPorAtleta[atleta3] = [];

    _profissionaisAtletas['medico_joao'] = [atleta1, atleta2, atleta3];
    _profissionaisAtletas['nutri_maria'] = [atleta1, atleta3];

    print('=== DADOS DE TESTE ===');
    print('Médico: medico@email.com / 123');
    print('Nutricionista: nutri@email.com / 123');
    print('Atletas: joao@email.com / 123, maria@email.com / 123, pedro@email.com / 123');
    print('Códigos: $atleta1, $atleta2, $atleta3');
    print('=====================');
  }
}