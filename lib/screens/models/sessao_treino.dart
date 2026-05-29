// lib/screens/models/sessao_treino.dart
class SessaoTreino {
  final String id;
  final String codigoAtleta;
  final DateTime data;
  
  // Dados básicos
  final double massaCorporalPreKg;
  final String modalidade;
  final int duracaoPrevistaMin;
  
  // Ambiente
  final double temperatura;
  final double umidade;
  final double sensacaoTermica;
  final String vento;
  final String exposicaoSolar;
  
  // Planejamento
  final String corUrina;
  final String vestimenta;
  final String equipamento;
  
  // Hidratação pré
  final bool estaComSede;
  final bool temSintomasPre;
  final String sintomasDescricao;
  final String historicoHidratacao;
  
  // Intra sessão
  final int duracaoRealSegundos;
  final int fluidosIngeridosMl;
  final String alimentosAgua;
  final int volumeUrinarioMl;
  
  // Pós sessão
  final double massaCorporalPosKg;
  final bool roupasEncharcadas;
  final bool trocaVestimenta;
  final String observacaoRoupas;
  final int escalaBorg;
  final bool teveSintomasGastro;
  final String sintomasGastroDescricao;
  final bool teveFadiga;
  final String fadigaDescricao;

  SessaoTreino({
    required this.id,
    required this.codigoAtleta,
    required this.data,
    required this.massaCorporalPreKg,
    required this.modalidade,
    required this.duracaoPrevistaMin,
    required this.temperatura,
    required this.umidade,
    required this.sensacaoTermica,
    required this.vento,
    required this.exposicaoSolar,
    required this.corUrina,
    required this.vestimenta,
    required this.equipamento,
    required this.estaComSede,
    required this.temSintomasPre,
    required this.sintomasDescricao,
    required this.historicoHidratacao,
    required this.duracaoRealSegundos,
    required this.fluidosIngeridosMl,
    required this.alimentosAgua,
    required this.volumeUrinarioMl,
    required this.massaCorporalPosKg,
    required this.roupasEncharcadas,
    required this.trocaVestimenta,
    required this.observacaoRoupas,
    required this.escalaBorg,
    required this.teveSintomasGastro,
    required this.sintomasGastroDescricao,
    required this.teveFadiga,
    required this.fadigaDescricao,
  });

  double get taxaSudorese {
    double perdaKg = massaCorporalPreKg - massaCorporalPosKg;
    double horas = duracaoRealSegundos / 3600.0;
    return horas > 0 ? (perdaKg / horas) : 0;
  }

  double get percentualPerdaMassa {
    if (massaCorporalPreKg <= 0) return 0;
    return ((massaCorporalPreKg - massaCorporalPosKg) / massaCorporalPreKg) * 100;
  }

  String get nivelHidratacao {
    if (fluidosIngeridosMl >= 1000) return "Bem hidratado";
    if (fluidosIngeridosMl >= 500) return "Hidratação moderada";
    return "Baixa ingestão";
  }

  String get dataFormatada {
    return "${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}";
  }
}