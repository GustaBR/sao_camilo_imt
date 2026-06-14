class SessaoTreino {
  final String id;
  final String atletaId;
  final String atletaNome;
  final DateTime data;
  final String modalidade;
  final int duracaoMinutos;
  final int fluidosMl;
  final double massaCorporalPreKg;
  final double massaCorporalPosKg;
  final int escalaBorg;
  final bool teveSintomasGastro;
  final String sintomasDescricao;
  final bool teveFadiga;
  final String fadigaDescricao;
  final int temperatura;
  final int umidade;

  SessaoTreino({
    required this.id,
    required this.atletaId,
    required this.atletaNome,
    required this.data,
    required this.modalidade,
    required this.duracaoMinutos,
    required this.fluidosMl,
    required this.massaCorporalPreKg,
    required this.massaCorporalPosKg,
    required this.escalaBorg,
    required this.teveSintomasGastro,
    required this.sintomasDescricao,
    required this.teveFadiga,
    required this.fadigaDescricao,
    required this.temperatura,
    required this.umidade,
  });

  double get percentualPerdaMassa {
    if (massaCorporalPreKg <= 0) return 0;
    return ((massaCorporalPreKg - massaCorporalPosKg) / massaCorporalPreKg) * 100;
  }

  String get dataFormatada {
    return "${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}";
  }

  int get duracaoRealSegundos => duracaoMinutos * 60;

  int get fluidosIngeridosMl => fluidosMl;

  String get sintomasGastroDescricao => sintomasDescricao;

  bool get roupasEncharcadas => false;

  String get nivelHidratacao {
    if (fluidosMl >= 1000) return "Excelente";
    if (fluidosMl >= 700) return "Boa";
    if (fluidosMl >= 500) return "Regular";
    return "Atenção - baixa ingestão";
  }

  double get taxaSudorese {
    if (duracaoMinutos <= 0) return 0;
    return (fluidosMl / 1000) / (duracaoMinutos / 60);
  }
}
