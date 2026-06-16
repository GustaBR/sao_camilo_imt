import '../models/sessao_treino.dart';

String gerarTreinosCsv(List<SessaoTreino> treinos, String nomeAtleta) {
  final linhas = <List<Object?>>[
    [
      'id_treino',
      'atleta_id',
      'atleta_nome',
      'data',
      'modalidade',
      'duracao_min',
      'duracao_prevista_min',
      'duracao_real_segundos',
      'temperatura_c',
      'umidade_percentual',
      'sensacao_termica_c',
      'vento',
      'exposicao_solar',
      'fluidos_ml',
      'alimentos_agua',
      'volume_urinario_ml',
      'massa_pre_kg',
      'massa_pos_kg',
      'perda_massa_percentual',
      'cor_urina',
      'vestimenta',
      'equipamento',
      'escala_borg',
      'esta_com_sede',
      'sintomas_pre',
      'historico_hidratacao',
      'roupas_encharcadas',
      'troca_vestimenta',
      'observacao_roupas',
      'sintomas_gastro',
      'descricao_sintomas_gastro',
      'fadiga',
      'descricao_fadiga',
    ],
    ...treinos.map((treino) {
      final atletaNome = treino.atletaNome.isNotEmpty ? treino.atletaNome : nomeAtleta;

      return [
        treino.id,
        treino.atletaId,
        atletaNome,
        _dataIso(treino.data),
        treino.modalidade,
        treino.duracaoMinutos,
        treino.duracaoPrevistaMin,
        treino.duracaoRealSegundos,
        treino.temperatura,
        treino.umidade,
        _formatarDouble(treino.sensacaoTermica),
        treino.vento,
        treino.exposicaoSolar,
        treino.fluidosMl,
        treino.alimentosAgua,
        treino.volumeUrinarioMl,
        _formatarDouble(treino.massaCorporalPreKg),
        _formatarDouble(treino.massaCorporalPosKg),
        _formatarDouble(treino.percentualPerdaMassa),
        treino.corUrina,
        treino.vestimenta,
        treino.equipamento,
        treino.escalaBorg,
        _simNao(treino.estaComSede),
        treino.sintomasPreDescricao,
        treino.historicoHidratacao,
        _simNao(treino.roupasEncharcadas),
        _simNao(treino.trocaVestimenta),
        treino.observacaoRoupas,
        _simNao(treino.teveSintomasGastro),
        treino.sintomasDescricao,
        _simNao(treino.teveFadiga),
        treino.fadigaDescricao,
      ];
    }),
  ];

  return '\uFEFF${linhas.map(_linhaCsv).join('\n')}\n';
}

String nomeArquivoTreinosCsv(String nomeAtleta) {
  final nomeNormalizado = nomeAtleta
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
  final sufixo = nomeNormalizado.isEmpty ? 'atleta' : nomeNormalizado;
  return 'historico_treinos_$sufixo.csv';
}

String _linhaCsv(List<Object?> valores) {
  return valores.map(_campoCsv).join(',');
}

String _campoCsv(Object? valor) {
  final texto = valor?.toString() ?? '';
  final escapado = texto.replaceAll('"', '""');
  final precisaAspas = escapado.contains(',') || escapado.contains('"') || escapado.contains('\n') || escapado.contains('\r');
  return precisaAspas ? '"$escapado"' : escapado;
}

String _dataIso(DateTime data) {
  final ano = data.year.toString().padLeft(4, '0');
  final mes = data.month.toString().padLeft(2, '0');
  final dia = data.day.toString().padLeft(2, '0');
  return '$ano-$mes-$dia';
}

String _formatarDouble(double valor) => valor.toStringAsFixed(2);

String _simNao(bool valor) => valor ? 'Sim' : 'Nao';
