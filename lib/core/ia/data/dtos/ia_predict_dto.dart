class IaPredictResponseDto {
  const IaPredictResponseDto({
    required this.id,
    required this.filename,
    required this.tipoDano,
    required this.severidad,
    required this.confianza,
    required this.distanciaCentroide,
    required this.createdAt,
  });

  final String id;
  final String filename;
  final String tipoDano;
  final String severidad;
  final double confianza;
  final double distanciaCentroide;
  final String createdAt;

  factory IaPredictResponseDto.fromJson(Map<String, dynamic> json) {
    return IaPredictResponseDto(
      id: json['id'] as String,
      filename: json['filename'] as String,
      tipoDano: json['tipo_dano'] as String,
      severidad: json['severidad'] as String,
      confianza: (json['confianza'] as num).toDouble(),
      distanciaCentroide: (json['distancia_centroide'] as num).toDouble(),
      createdAt: json['created_at'] as String,
    );
  }
}

class IaHistoryItemDto {
  const IaHistoryItemDto({
    required this.id,
    required this.filename,
    required this.clusterId,
    required this.tipoDano,
    required this.severidad,
    required this.confianza,
    required this.distanciaCentroide,
    required this.createdAt,
  });

  final String id;
  final String filename;
  final int clusterId;
  final String tipoDano;
  final String severidad;
  final double confianza;
  final double distanciaCentroide;
  final String createdAt;

  factory IaHistoryItemDto.fromJson(Map<String, dynamic> json) {
    return IaHistoryItemDto(
      id: json['id'] as String,
      filename: json['filename'] as String,
      clusterId: json['cluster_id'] as int,
      tipoDano: json['tipo_dano'] as String,
      severidad: json['severidad'] as String,
      confianza: (json['confianza'] as num).toDouble(),
      distanciaCentroide: (json['distancia_centroide'] as num).toDouble(),
      createdAt: json['created_at'] as String,
    );
  }
}

class IaRetrainResponseDto {
  const IaRetrainResponseDto({
    required this.k,
    required this.silhouette,
    required this.daviesBouldin,
    required this.inertia,
    required this.mapping,
    required this.trainedAt,
  });

  final int k;
  final double silhouette;
  final double daviesBouldin;
  final double inertia;
  final List<Map<String, dynamic>> mapping;
  final String trainedAt;

  factory IaRetrainResponseDto.fromJson(Map<String, dynamic> json) {
    return IaRetrainResponseDto(
      k: json['k'] as int,
      silhouette: (json['silhouette'] as num).toDouble(),
      daviesBouldin: (json['davies_bouldin'] as num).toDouble(),
      inertia: (json['inertia'] as num).toDouble(),
      mapping: (json['mapping'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      trainedAt: json['trained_at'] as String,
    );
  }
}

class IaHealthResponseDto {
  const IaHealthResponseDto({
    required this.status,
    required this.modelLoaded,
    this.kValue,
  });

  final String status;
  final bool modelLoaded;
  final int? kValue;

  factory IaHealthResponseDto.fromJson(Map<String, dynamic> json) {
    return IaHealthResponseDto(
      status: json['status'] as String,
      modelLoaded: json['model_loaded'] as bool,
      kValue: json['k_value'] as int?,
    );
  }
}
