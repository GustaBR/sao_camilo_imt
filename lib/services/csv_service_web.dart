import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import '../models/sessao_treino.dart';
import 'csv_service_base.dart';

class CsvService {
  static Future<void> gerarHistoricoCsv(List<SessaoTreino> treinos, String nomeAtleta) async {
    final bytes = utf8.encode(gerarTreinosCsv(treinos, nomeAtleta));
    final blob = html.Blob([bytes], 'text/csv;charset=utf-8');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final link = html.AnchorElement(href: url)
      ..download = nomeArquivoTreinosCsv(nomeAtleta)
      ..style.display = 'none';

    html.document.body?.children.add(link);
    link.click();
    link.remove();
    html.Url.revokeObjectUrl(url);
  }
}
