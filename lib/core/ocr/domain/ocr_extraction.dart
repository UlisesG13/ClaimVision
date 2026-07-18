class OcrExtraction {
  const OcrExtraction({
    this.numeroPoliza,
    this.aseguradora,
    this.vigenciaInicio,
    this.vigenciaFin,
    this.marca,
    this.modelo,
    this.anio,
    this.placas,
    this.nombre,
    this.curp,
  });

  factory OcrExtraction.fromJson(Map<String, dynamic> json) {
    return OcrExtraction(
      numeroPoliza: json['numero_poliza'] as String?,
      aseguradora: json['aseguradora'] as String?,
      vigenciaInicio: json['vigencia_inicio'] as String?,
      vigenciaFin: json['vigencia_fin'] as String?,
      marca: json['marca'] as String?,
      modelo: json['modelo'] as String?,
      anio: json['anio'] as int?,
      placas: json['placas'] as String?,
      nombre: json['nombre'] as String?,
      curp: json['curp'] as String?,
    );
  }

  final String? numeroPoliza;
  final String? aseguradora;
  final String? vigenciaInicio;
  final String? vigenciaFin;
  final String? marca;
  final String? modelo;
  final int? anio;
  final String? placas;
  final String? nombre;
  final String? curp;

  Map<String, dynamic> toJson() => {
        if (numeroPoliza != null) 'numero_poliza': numeroPoliza,
        if (aseguradora != null) 'aseguradora': aseguradora,
        if (vigenciaInicio != null) 'vigencia_inicio': vigenciaInicio,
        if (vigenciaFin != null) 'vigencia_fin': vigenciaFin,
        if (marca != null) 'marca': marca,
        if (modelo != null) 'modelo': modelo,
        if (anio != null) 'anio': anio,
        if (placas != null) 'placas': placas,
        if (nombre != null) 'nombre': nombre,
        if (curp != null) 'curp': curp,
      };
}
