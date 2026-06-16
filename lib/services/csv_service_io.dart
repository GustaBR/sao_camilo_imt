import 'dart:io';

import '../models/sessao_treino.dart';
import 'csv_service_base.dart';

class CsvService {
  static Future<void> gerarHistoricoCsv(List<SessaoTreino> treinos, String nomeAtleta) async {
    final arquivo = File('${Directory.systemTemp.path}${Platform.pathSeparator}${nomeArquivoTreinosCsv(nomeAtleta)}');
    await arquivo.writeAsString(gerarTreinosCsv(treinos, nomeAtleta));
  }
}
