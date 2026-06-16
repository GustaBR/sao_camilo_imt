import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/sessao_treino.dart';

class PdfService {
  static Future<void> gerarHistoricoPdf(List<SessaoTreino> treinos, String nomeAtleta) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          final List<pw.Widget> children = [
            pw.Header(
              level: 0,
              child: pw.Text('Historico de Treinos - $nomeAtleta',
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 20),
          ];
          
          for (var treino in treinos) {
            children.add(_buildTreinoPdf(treino));
            children.add(pw.SizedBox(height: 10));
          }
          
          return children;
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'historico_${nomeAtleta.replaceAll(' ', '_')}.pdf',
    );
  }

  static Future<void> gerarTreinoIndividualPdf(SessaoTreino treino, String nomeAtleta) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return _buildTreinoPdf(treino);
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'treino_${treino.dataFormatada}_${nomeAtleta.replaceAll(' ', '_')}.pdf',
    );
  }

  static pw.Widget _buildTreinoPdf(SessaoTreino treino) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Data: ${treino.dataFormatada}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
          pw.SizedBox(height: 10),
          pw.Text('Modalidade: ${treino.modalidade}'),
          pw.Text('Duracao: ${treino.duracaoMinutos} minutos'),
          pw.Text('Duracao real: ${treino.duracaoRealSegundos ~/ 60} minutos'),
          pw.Text('Temperatura: ${treino.temperatura}°C'),
          pw.Text('Umidade: ${treino.umidade}%'),
          pw.Text('Sensacao termica: ${treino.sensacaoTermica}°C'),
          pw.Text('Vento: ${treino.vento}'),
          pw.Text('Exposicao solar: ${treino.exposicaoSolar}'),
          pw.Divider(),
          pw.Text('Fluidos ingeridos: ${treino.fluidosMl} mL'),
          pw.Text('Alimentos com agua: ${treino.alimentosAgua}'),
          pw.Text('Volume urinario: ${treino.volumeUrinarioMl} mL'),
          pw.Divider(),
          pw.Text('Massa pre: ${treino.massaCorporalPreKg} kg'),
          pw.Text('Massa pos: ${treino.massaCorporalPosKg} kg'),
          pw.Text('Perda de massa: ${treino.percentualPerdaMassa.toStringAsFixed(1)}%'),
          pw.Text('Cor da urina: ${treino.corUrina}'),
          pw.Text('Vestimenta: ${treino.vestimenta}'),
          pw.Text('Equipamento: ${treino.equipamento}'),
          pw.Divider(),
          pw.Text('Escala de Borg: ${treino.escalaBorg}/20'),
          pw.Text('Estava com sede: ${treino.estaComSede ? 'Sim' : 'Nao'}'),
          pw.Text('Sintomas pre-treino: ${treino.sintomasPreDescricao.isNotEmpty ? treino.sintomasPreDescricao : 'Nenhum'}'),
          pw.Text('Historico de hidratacao: ${treino.historicoHidratacao}'),
          pw.Divider(),
          pw.Text('Roupas encharcadas: ${treino.roupasEncharcadas ? 'Sim' : 'Nao'}'),
          pw.Text('Troca de vestimenta: ${treino.trocaVestimenta ? 'Sim' : 'Nao'}'),
          if (treino.observacaoRoupas.isNotEmpty) pw.Text('Observacao roupas: ${treino.observacaoRoupas}'),
          pw.Divider(),
          pw.Text('Sintomas gastrointestinais: ${treino.teveSintomasGastro ? 'Sim' : 'Nao'}'),
          if (treino.sintomasDescricao.isNotEmpty) pw.Text('Descricao sintomas: ${treino.sintomasDescricao}'),
          pw.Text('Fadiga: ${treino.teveFadiga ? 'Sim' : 'Nao'}'),
          if (treino.fadigaDescricao.isNotEmpty) pw.Text('Descricao fadiga: ${treino.fadigaDescricao}'),
        ],
      ),
    );
  }
}