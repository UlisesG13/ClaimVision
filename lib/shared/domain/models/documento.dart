class DocumentoInfo {
  final String url;
  final String tipoArchivo;
  final DateTime subidoEn;

  const DocumentoInfo({
    required this.url,
    required this.tipoArchivo,
    required this.subidoEn,
  });

  factory DocumentoInfo.fromJson(Map<String, dynamic> json) => DocumentoInfo(
        url: json['url'] as String,
        tipoArchivo: json['tipo'] as String,
        subidoEn: DateTime.parse(json['subido_en'] as String),
      );

  bool get esPdf => tipoArchivo == 'pdf';
  bool get esImagen => tipoArchivo == 'image';
}

class DocumentosResponse {
  final DocumentoInfo? identificacion;
  final DocumentoInfo? poliza;
  final String? numeroPoliza;
  final String? vigencia;

  const DocumentosResponse({
    this.identificacion,
    this.poliza,
    this.numeroPoliza,
    this.vigencia,
  });

  bool get hayDocumentos =>
      identificacion != null || poliza != null;

  factory DocumentosResponse.fromJson(Map<String, dynamic> json) =>
      DocumentosResponse(
        identificacion: json['identificacion'] != null
            ? DocumentoInfo.fromJson(
                json['identificacion'] as Map<String, dynamic>)
            : null,
        poliza: json['poliza'] != null
            ? DocumentoInfo.fromJson(
                json['poliza'] as Map<String, dynamic>)
            : null,
        numeroPoliza: json['numero_poliza'] as String?,
        vigencia: json['vigencia'] as String?,
      );
}
