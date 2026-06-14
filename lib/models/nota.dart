class Nota {
  final String id;
  final String atletaCodigo;
  final String profissionalId;
  final String profissionalNome;
  final String profissionalTipo;
  final String titulo;
  final String conteudo;
  final DateTime data;

  Nota({
    required this.id,
    required this.atletaCodigo,
    required this.profissionalId,
    required this.profissionalNome,
    required this.profissionalTipo,
    required this.titulo,
    required this.conteudo,
    required this.data,
  });
}