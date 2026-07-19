class IaOcrResponseDto {
  const IaOcrResponseDto({
    required this.id,
    required this.filename,
    required this.text,
    required this.pageCount,
    required this.createdAt,
  });

  final String id;
  final String filename;
  final String text;
  final int pageCount;
  final String createdAt;

  factory IaOcrResponseDto.fromJson(Map<String, dynamic> json) {
    return IaOcrResponseDto(
      id: json['id'] as String,
      filename: json['filename'] as String,
      text: json['text'] as String,
      pageCount: json['page_count'] as int,
      createdAt: json['created_at'] as String,
    );
  }
}

class IaOcrHistoryItemDto {
  const IaOcrHistoryItemDto({
    required this.id,
    required this.filename,
    required this.pageCount,
    required this.createdAt,
  });

  final String id;
  final String filename;
  final int pageCount;
  final String createdAt;

  factory IaOcrHistoryItemDto.fromJson(Map<String, dynamic> json) {
    return IaOcrHistoryItemDto(
      id: json['id'] as String,
      filename: json['filename'] as String,
      pageCount: json['page_count'] as int,
      createdAt: json['created_at'] as String,
    );
  }
}

class IaPolizaExtractedDto {
  const IaPolizaExtractedDto({
    required this.id,
    required this.filename,
    required this.numeroPoliza,
    required this.aseguradora,
    required this.nombreAsegurado,
    required this.vehiculoMarca,
    required this.vehiculoModelo,
    required this.vehiculoAnio,
    required this.vehiculoPlacas,
    this.vehiculoVin,
    this.vehiculoColor,
    required this.vigenciaInicio,
    required this.vigenciaFin,
  });

  final String id;
  final String filename;
  final String numeroPoliza;
  final String aseguradora;
  final String nombreAsegurado;
  final String vehiculoMarca;
  final String vehiculoModelo;
  final int vehiculoAnio;
  final String vehiculoPlacas;
  final String? vehiculoVin;
  final String? vehiculoColor;
  final String vigenciaInicio;
  final String vigenciaFin;

  factory IaPolizaExtractedDto.fromJson(Map<String, dynamic> json) {
    return IaPolizaExtractedDto(
      id: json['id'] as String,
      filename: json['filename'] as String,
      numeroPoliza: json['numero_poliza'] as String,
      aseguradora: json['aseguradora'] as String,
      nombreAsegurado: json['nombre_asegurado'] as String,
      vehiculoMarca: json['vehiculo_marca'] as String,
      vehiculoModelo: json['vehiculo_modelo'] as String,
      vehiculoAnio: json['vehiculo_anio'] as int,
      vehiculoPlacas: json['vehiculo_placas'] as String,
      vehiculoVin: json['vehiculo_vin'] as String?,
      vehiculoColor: json['vehiculo_color'] as String?,
      vigenciaInicio: json['vigencia_inicio'] as String,
      vigenciaFin: json['vigencia_fin'] as String,
    );
  }
}

class IaIneExtractedDto {
  const IaIneExtractedDto({
    required this.id,
    required this.filename,
    required this.nombreCompleto,
    required this.curp,
    this.rfc,
    this.fechaNacimiento,
    this.sexo,
    this.domicilio,
    this.claveElector,
  });

  final String id;
  final String filename;
  final String nombreCompleto;
  final String curp;
  final String? rfc;
  final String? fechaNacimiento;
  final String? sexo;
  final String? domicilio;
  final String? claveElector;

  factory IaIneExtractedDto.fromJson(Map<String, dynamic> json) {
    return IaIneExtractedDto(
      id: json['id'] as String,
      filename: json['filename'] as String,
      nombreCompleto: json['nombre_completo'] as String,
      curp: json['curp'] as String,
      rfc: json['rfc'] as String?,
      fechaNacimiento: json['fecha_nacimiento'] as String?,
      sexo: json['sexo'] as String?,
      domicilio: json['domicilio'] as String?,
      claveElector: json['clave_elector'] as String?,
    );
  }
}

class IaValidationResultDto {
  const IaValidationResultDto({
    required this.polizaVsIneNombreMatch,
    required this.curpRfcConsistent,
    required this.detalles,
  });

  final bool polizaVsIneNombreMatch;
  final bool curpRfcConsistent;
  final List<String> detalles;

  factory IaValidationResultDto.fromJson(Map<String, dynamic> json) {
    return IaValidationResultDto(
      polizaVsIneNombreMatch: json['poliza_vs_ine_nombre_match'] as bool,
      curpRfcConsistent: json['curp_rfc_consistent'] as bool,
      detalles: (json['detalles'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }
}

class IaExtractAndValidateDto {
  const IaExtractAndValidateDto({
    required this.poliza,
    required this.ine,
    required this.validation,
  });

  final IaPolizaExtractedDto poliza;
  final IaIneExtractedDto ine;
  final IaValidationResultDto validation;

  factory IaExtractAndValidateDto.fromJson(Map<String, dynamic> json) {
    return IaExtractAndValidateDto(
      poliza: IaPolizaExtractedDto.fromJson(json['poliza'] as Map<String, dynamic>),
      ine: IaIneExtractedDto.fromJson(json['ine'] as Map<String, dynamic>),
      validation: IaValidationResultDto.fromJson(json['validation'] as Map<String, dynamic>),
    );
  }
}
