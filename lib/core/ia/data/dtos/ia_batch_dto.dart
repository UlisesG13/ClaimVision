class IaPredictAllItemDto {
  const IaPredictAllItemDto({
    required this.filename,
    required this.phash,
    required this.tipoDano,
    required this.severidad,
    required this.confianza,
    this.duplicadoDe,
  });

  final String filename;
  final String phash;
  final String tipoDano;
  final String severidad;
  final double confianza;
  final String? duplicadoDe;

  factory IaPredictAllItemDto.fromJson(Map<String, dynamic> json) {
    return IaPredictAllItemDto(
      filename: json['filename'] as String,
      phash: json['phash'] as String,
      tipoDano: json['tipo_dano'] as String,
      severidad: json['severidad'] as String,
      confianza: (json['confianza'] as num).toDouble(),
      duplicadoDe: json['duplicado_de'] as String?,
    );
  }
}

class IaPredictAllSummaryDto {
  const IaPredictAllSummaryDto({
    required this.totalImagenes,
    required this.imagenesUnicas,
    required this.duplicadosDetectados,
  });

  final int totalImagenes;
  final int imagenesUnicas;
  final int duplicadosDetectados;

  factory IaPredictAllSummaryDto.fromJson(Map<String, dynamic> json) {
    return IaPredictAllSummaryDto(
      totalImagenes: json['total_imagenes'] as int,
      imagenesUnicas: json['imagenes_unicas'] as int,
      duplicadosDetectados: json['duplicados_detectados'] as int,
    );
  }
}

class IaPredictAllResponseDto {
  const IaPredictAllResponseDto({
    required this.predicciones,
    required this.resumen,
  });

  final List<IaPredictAllItemDto> predicciones;
  final IaPredictAllSummaryDto resumen;

  factory IaPredictAllResponseDto.fromJson(Map<String, dynamic> json) {
    return IaPredictAllResponseDto(
      predicciones: (json['predicciones'] as List<dynamic>)
          .map((e) => IaPredictAllItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      resumen: IaPredictAllSummaryDto.fromJson(json['resumen'] as Map<String, dynamic>),
    );
  }
}

class IaResumenDanoDto {
  const IaResumenDanoDto({
    required this.tipo,
    required this.severidad,
    required this.costoReparacion,
  });

  final String tipo;
  final String severidad;
  final double costoReparacion;

  factory IaResumenDanoDto.fromJson(Map<String, dynamic> json) {
    return IaResumenDanoDto(
      tipo: json['tipo'] as String,
      severidad: json['severidad'] as String,
      costoReparacion: (json['costo_reparacion'] as num).toDouble(),
    );
  }
}

class IaResumenResponseDto {
  const IaResumenResponseDto({
    required this.precioTotal,
    required this.danos,
    required this.moneda,
  });

  final double precioTotal;
  final List<IaResumenDanoDto> danos;
  final String moneda;

  factory IaResumenResponseDto.fromJson(Map<String, dynamic> json) {
    return IaResumenResponseDto(
      precioTotal: (json['precio_total'] as num).toDouble(),
      danos: (json['danos'] as List<dynamic>)
          .map((e) => IaResumenDanoDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      moneda: json['moneda'] as String,
    );
  }
}

class IaResumenRequestDto {
  const IaResumenRequestDto(this.danos);

  final List<({String tipo, String severidad})> danos;

  Map<String, dynamic> toJson() => {
        'danos': danos
            .map((d) => {'tipo': d.tipo, 'severidad': d.severidad})
            .toList(),
      };
}
