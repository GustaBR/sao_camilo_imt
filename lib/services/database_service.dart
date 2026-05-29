import 'dart:math';
import '../models/sessao_treino.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final Map<String, Map<String, dynamic>> _alunos = {};
  final Map<String, List<SessaoTreino>> _treinosPorAluno = {};
  
  final Map<String, Map<String, dynamic>> _profissionais = {
    'medico_joao': {'id': 'medico_joao', 'nome': 'Dr. João Silva', 'tipo': 'medico', 'senha': '123'},
    'nutri_maria': {'id': 'nutri_maria', 'nome': 'Nutri. Maria Santos', 'tipo': 'nutricionista', 'senha': '123'},
  };
  
  final Map<String, List<String>> _profissionaisAlunos = {
    'medico_joao': [],
    'nutri_maria': [],
  };

  String cadastrarAluno(String nome, String email) {
    String codigo = _gerarCodigo();
    _alunos[codigo] = {
      'codigo': codigo,
      'nome': nome,
      'email': email,
      'dataCadastro': DateTime.now(),
    };
    _treinosPorAluno[codigo] = [];
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

  Map<String, dynamic>? getAluno(String codigo) {
    return _alunos[codigo];
  }

  bool validarCodigoAluno(String codigo) {
    return _alunos.containsKey(codigo);
  }

  void salvarTreino(SessaoTreino treino) {
    if (_treinosPorAluno.containsKey(treino.alunoId)) {
      _treinosPorAluno[treino.alunoId]!.insert(0, treino);
    }
  }

  List<SessaoTreino> getTreinosDoAluno(String alunoId) {
    return _treinosPorAluno[alunoId] ?? [];
  }

  bool autenticarProfissional(String usuario, String senha) {
    return _profissionais.containsKey(usuario) && _profissionais[usuario]!['senha'] == senha;
  }

  Map<String, dynamic>? getProfissional(String usuario) {
    return _profissionais[usuario];
  }

  List<Map<String, dynamic>> getAlunosDoProfissional(String profissionalId) {
    List<String> codigosAlunos = _profissionaisAlunos[profissionalId] ?? [];
    List<Map<String, dynamic>> alunos = [];
    for (String codigo in codigosAlunos) {
      if (_alunos.containsKey(codigo)) {
        alunos.add(_alunos[codigo]!);
      }
    }
    return alunos;
  }

  bool adicionarAlunoAoProfissional(String profissionalId, String codigoAluno) {
    if (!_alunos.containsKey(codigoAluno)) return false;
    if (!_profissionaisAlunos.containsKey(profissionalId)) {
      _profissionaisAlunos[profissionalId] = [];
    }
    if (!_profissionaisAlunos[profissionalId]!.contains(codigoAluno)) {
      _profissionaisAlunos[profissionalId]!.add(codigoAluno);
    }
    return true;
  }

  void carregarDadosExemplo() {
    String aluno1 = cadastrarAluno("João Silva", "joao@email.com");
    _treinosPorAluno[aluno1] = [
      SessaoTreino(
        id: '1',
        alunoId: aluno1,
        alunoNome: "João Silva",
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

    String aluno2 = cadastrarAluno("Maria Oliveira", "maria@email.com");
    _treinosPorAluno[aluno2] = [
      SessaoTreino(
        id: '2',
        alunoId: aluno2,
        alunoNome: "Maria Oliveira",
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

    String aluno3 = cadastrarAluno("Pedro Costa", "pedro@email.com");
    _treinosPorAluno[aluno3] = [];

    _profissionaisAlunos['medico_joao'] = [aluno1, aluno2, aluno3];
    _profissionaisAlunos['nutri_maria'] = [aluno1, aluno3];

    print('=== DADOS DE TESTE ===');
    print('Médico: medico_joao / 123');
    print('Nutricionista: nutri_maria / 123');
    print('João código: $aluno1');
    print('Maria código: $aluno2');
    print('Pedro código: $aluno3');
    print('=====================');
  }
}