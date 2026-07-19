class IaDamageEntityDto {
  const IaDamageEntityDto({
    required this.tipoDano,
    required this.severidad,
    required this.parteAfectada,
    required this.sintoma,
    required this.confianza,
  });

  final String tipoDano;
  final String severidad;
  final String parteAfectada;
  final String sintoma;
  final double confianza;

  factory IaDamageEntityDto.fromJson(Map<String, dynamic> json) {
    return IaDamageEntityDto(
      tipoDano: json['tipo_dano'] as String,
      severidad: json['severidad'] as String,
      parteAfectada: json['parte_afectada'] as String,
      sintoma: json['sintoma'] as String,
      confianza: (json['confianza'] as num).toDouble(),
    );
  }
}

class IaTranscribirJobResponseDto {
  const IaTranscribirJobResponseDto({
    required this.jobId,
    required this.status,
    required this.progress,
  });

  final String jobId;
  final String status;
  final int progress;

  factory IaTranscribirJobResponseDto.fromJson(Map<String, dynamic> json) {
    return IaTranscribirJobResponseDto(
      jobId: json['job_id'] as String,
      status: json['status'] as String,
      progress: json['progress'] as int,
    );
  }
}

class IaTranscribirResponseDto {
  const IaTranscribirResponseDto({
    required this.id,
    required this.filename,
    required this.texto,
    required this.duracionSeg,
    required this.entidades,
    required this.createdAt,
  });

  final String id;
  final String filename;
  final String texto;
  final double duracionSeg;
  final List<IaDamageEntityDto> entidades;
  final String createdAt;

  factory IaTranscribirResponseDto.fromJson(Map<String, dynamic> json) {
    return IaTranscribirResponseDto(
      id: json['id'] as String,
      filename: json['filename'] as String,
      texto: json['texto'] as String,
      duracionSeg: (json['duracion_seg'] as num).toDouble(),
      entidades: (json['entidades'] as List<dynamic>)
          .map((e) => IaDamageEntityDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] as String,
    );
  }
}

class IaTranscribirJobStatusResponseDto {
  const IaTranscribirJobStatusResponseDto({
    required this.jobId,
    required this.status,
    required this.progress,
    this.result,
    this.error,
  });

  final String jobId;
  final String status;
  final int progress;
  final IaTranscribirResponseDto? result;
  final String? error;

  factory IaTranscribirJobStatusResponseDto.fromJson(Map<String, dynamic> json) {
    return IaTranscribirJobStatusResponseDto(
      jobId: json['job_id'] as String,
      status: json['status'] as String,
      progress: json['progress'] as int,
      result: json['result'] != null
          ? IaTranscribirResponseDto.fromJson(json['result'] as Map<String, dynamic>)
          : null,
      error: json['error'] as String?,
    );
  }
}

class IaAnalizarRequestDto {
  const IaAnalizarRequestDto({required this.texto});

  final String texto;

  Map<String, dynamic> toJson() => {'texto': texto};
}

class IaAnalizarResponseDto {
  const IaAnalizarResponseDto({required this.entidades});

  final List<IaDamageEntityDto> entidades;

  factory IaAnalizarResponseDto.fromJson(Map<String, dynamic> json) {
    return IaAnalizarResponseDto(
      entidades: (json['entidades'] as List<dynamic>)
          .map((e) => IaDamageEntityDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class IaNlpHistoryItemDto {
  const IaNlpHistoryItemDto({
    required this.id,
    required this.filename,
    required this.texto,
    required this.duracionSeg,
    required this.entidades,
    required this.createdAt,
  });

  final String id;
  final String filename;
  final String texto;
  final double duracionSeg;
  final List<IaDamageEntityDto> entidades;
  final String createdAt;

  factory IaNlpHistoryItemDto.fromJson(Map<String, dynamic> json) {
    return IaNlpHistoryItemDto(
      id: json['id'] as String,
      filename: json['filename'] as String,
      texto: json['texto'] as String,
      duracionSeg: (json['duracion_seg'] as num).toDouble(),
      entidades: (json['entidades'] as List<dynamic>)
          .map((e) => IaDamageEntityDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] as String,
    );
  }
}
