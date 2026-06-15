class SessaoTreino {
  static final DateTime _dataIndisponivel = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  final String id;
  final String atletaId;
  final String atletaNome;
  final DateTime data;
  final String modalidade;
  final int duracaoMinutos;
  final int duracaoPrevistaMin;
  final int duracaoRealSegundos;
  final int fluidosMl;
  final String alimentosAgua;
  final int volumeUrinarioMl;
  final double massaCorporalPreKg;
  final double massaCorporalPosKg;
  final int escalaBorg;
  final double sensacaoTermica;
  final String vento;
  final String exposicaoSolar;
  final String corUrina;
  final String vestimenta;
  final String equipamento;
  final bool estaComSede;
  final String sintomasPreDescricao;
  final String historicoHidratacao;
  final bool roupasEncharcadas;
  final bool trocaVestimenta;
  final String observacaoRoupas;
  final bool teveSintomasGastro;
  final String sintomasDescricao;
  final bool teveFadiga;
  final String fadigaDescricao;
  final int temperatura;
  final int umidade;

  SessaoTreino({
    String? id,
    required this.atletaId,
    String? atletaNome,
    DateTime? data,
    required this.modalidade,
    required this.duracaoMinutos,
    int? duracaoPrevistaMin,
    int? duracaoRealSegundos,
    required this.fluidosMl,
    this.alimentosAgua = '',
    this.volumeUrinarioMl = 0,
    required this.massaCorporalPreKg,
    required this.massaCorporalPosKg,
    required this.escalaBorg,
    this.sensacaoTermica = 0,
    this.vento = '',
    this.exposicaoSolar = '',
    this.corUrina = '',
    this.vestimenta = '',
    this.equipamento = '',
    this.estaComSede = false,
    this.sintomasPreDescricao = '',
    this.historicoHidratacao = '',
    this.roupasEncharcadas = false,
    this.trocaVestimenta = false,
    this.observacaoRoupas = '',
    required this.teveSintomasGastro,
    required this.sintomasDescricao,
    required this.teveFadiga,
    required this.fadigaDescricao,
    required this.temperatura,
    required this.umidade,
  })  : id = id ?? '',
        atletaNome = atletaNome ?? '',
        data = data ?? _dataIndisponivel,
        duracaoPrevistaMin = duracaoPrevistaMin ?? duracaoMinutos,
        duracaoRealSegundos = duracaoRealSegundos ?? duracaoMinutos * 60;

  factory SessaoTreino.fromJson(Map<String, dynamic> json) {
    return SessaoTreino(
      id: json['id'].toString(),
      atletaId: json['atletaId'].toString(),
      atletaNome: json['atletaNome']?.toString() ?? '',
      data: DateTime.parse(json['data'].toString()),
      modalidade: json['modalidade']?.toString() ?? '',
      duracaoMinutos: _lerInt(json['duracaoMinutos']),
      duracaoPrevistaMin: json['duracaoPrevistaMin'] == null ? null : _lerInt(json['duracaoPrevistaMin']),
      duracaoRealSegundos: json['duracaoRealSegundos'] == null ? null : _lerInt(json['duracaoRealSegundos']),
      fluidosMl: _lerInt(json['fluidosMl']),
      alimentosAgua: json['alimentosAgua']?.toString() ?? '',
      volumeUrinarioMl: _lerInt(json['volumeUrinarioMl']),
      massaCorporalPreKg: _lerDouble(json['massaCorporalPreKg']),
      massaCorporalPosKg: _lerDouble(json['massaCorporalPosKg']),
      escalaBorg: _lerInt(json['escalaBorg']),
      sensacaoTermica: _lerDouble(json['sensacaoTermica']),
      vento: json['vento']?.toString() ?? '',
      exposicaoSolar: json['exposicaoSolar']?.toString() ?? '',
      corUrina: json['corUrina']?.toString() ?? '',
      vestimenta: json['vestimenta']?.toString() ?? '',
      equipamento: json['equipamento']?.toString() ?? '',
      estaComSede: _lerBool(json['estaComSede']),
      sintomasPreDescricao: json['sintomasPreDescricao']?.toString() ?? '',
      historicoHidratacao: json['historicoHidratacao']?.toString() ?? '',
      roupasEncharcadas: _lerBool(json['roupasEncharcadas']),
      trocaVestimenta: _lerBool(json['trocaVestimenta']),
      observacaoRoupas: json['observacaoRoupas']?.toString() ?? '',
      teveSintomasGastro: json['teveSintomasGastro'] == true,
      sintomasDescricao: json['sintomasDescricao']?.toString() ?? '',
      teveFadiga: json['teveFadiga'] == true,
      fadigaDescricao: json['fadigaDescricao']?.toString() ?? '',
      temperatura: _lerInt(json['temperatura']),
      umidade: _lerInt(json['umidade']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'atletaId': atletaId,
      'modalidade': modalidade,
      'duracaoMinutos': duracaoMinutos,
      'duracaoPrevistaMin': duracaoPrevistaMin,
      'duracaoRealSegundos': duracaoRealSegundos,
      'fluidosMl': fluidosMl,
      'alimentosAgua': alimentosAgua,
      'volumeUrinarioMl': volumeUrinarioMl,
      'massaCorporalPreKg': massaCorporalPreKg,
      'massaCorporalPosKg': massaCorporalPosKg,
      'escalaBorg': escalaBorg,
      'sensacaoTermica': sensacaoTermica,
      'vento': vento,
      'exposicaoSolar': exposicaoSolar,
      'corUrina': corUrina,
      'vestimenta': vestimenta,
      'equipamento': equipamento,
      'estaComSede': estaComSede,
      'sintomasPreDescricao': sintomasPreDescricao,
      'historicoHidratacao': historicoHidratacao,
      'roupasEncharcadas': roupasEncharcadas,
      'trocaVestimenta': trocaVestimenta,
      'observacaoRoupas': observacaoRoupas,
      'teveSintomasGastro': teveSintomasGastro,
      'sintomasDescricao': sintomasDescricao,
      'teveFadiga': teveFadiga,
      'fadigaDescricao': fadigaDescricao,
      'temperatura': temperatura,
      'umidade': umidade,
    };
  }

  static int _lerInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _lerDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _lerBool(dynamic value) {
    if (value is bool) return value;
    return value?.toString().toLowerCase() == 'true';
  }

  double get percentualPerdaMassa {
    if (massaCorporalPreKg <= 0) return 0;
    return ((massaCorporalPreKg - massaCorporalPosKg) / massaCorporalPreKg) * 100;
  }

  String get dataFormatada {
    return "${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}";
  }

  int get fluidosIngeridosMl => fluidosMl;

  String get sintomasGastroDescricao => sintomasDescricao;

  String get nivelHidratacao {
    if (fluidosMl >= 1000) return "Excelente";
    if (fluidosMl >= 700) return "Boa";
    if (fluidosMl >= 500) return "Regular";
    return "Atenção - baixa ingestão";
  }

  double get taxaSudorese {
    if (duracaoRealSegundos <= 0) return 0;
    return (fluidosMl / 1000) / (duracaoRealSegundos / 3600);
  }
}
