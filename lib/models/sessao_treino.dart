class SessaoTreino {
  final String id;
  final String alunoId;
  final String alunoNome;
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
    required this.alunoId,
    required this.alunoNome,
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
}