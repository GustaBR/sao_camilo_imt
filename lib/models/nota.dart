class Nota {
  static final DateTime _dataIndisponivel = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  final String id;
  final String atletaCodigo;
  final String profissionalId;
  final String profissionalNome;
  final String profissionalTipo;
  final String titulo;
  final String conteudo;
  final DateTime data;

  Nota({
    String? id,
    required this.atletaCodigo,
    required this.profissionalId,
    required this.profissionalNome,
    required this.profissionalTipo,
    required this.titulo,
    required this.conteudo,
    DateTime? data,
  })  : id = id ?? '',
        data = data ?? _dataIndisponivel;

  factory Nota.fromJson(Map<String, dynamic> json) {
    final dataTexto = json['data']?.toString();
    final data = dataTexto == null ? null : DateTime.tryParse(dataTexto)?.toLocal();

    return Nota(
      id: json['id']?.toString() ?? '',
      atletaCodigo: json['atletaCodigo']?.toString() ?? '',
      profissionalId: json['profissionalId']?.toString() ?? '',
      profissionalNome: json['profissionalNome']?.toString() ?? '',
      profissionalTipo: json['profissionalTipo']?.toString() ?? '',
      titulo: json['titulo']?.toString() ?? '',
      conteudo: json['conteudo']?.toString() ?? '',
      data: data,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profissionalId': int.tryParse(profissionalId) ?? profissionalId,
      'profissionalTipo': profissionalTipo,
      'titulo': titulo,
      'conteudo': conteudo,
    };
  }
}
