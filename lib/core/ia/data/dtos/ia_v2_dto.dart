class IaV2PredictResponseDto {
  const IaV2PredictResponseDto({
    required this.id,
    required this.filename,
    required this.classId,
    required this.tipoDano,
    required this.severidad,
    required this.confianza,
    required this.probDist,
    required this.createdAt,
  });

  final String id;
  final String filename;
  final int classId;
  final String tipoDano;
  final String severidad;
  final double confianza;
  final List<double> probDist;
  final String createdAt;

  factory IaV2PredictResponseDto.fromJson(Map<String, dynamic> json) {
    return IaV2PredictResponseDto(
      id: json['id'] as String,
      filename: json['filename'] as String,
      classId: json['class_id'] as int,
      tipoDano: json['tipo_dano'] as String,
      severidad: json['severidad'] as String,
      confianza: (json['confianza'] as num).toDouble(),
      probDist: (json['prob_dist'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      createdAt: json['created_at'] as String,
    );
  }
}

class IaV2HealthResponseDto {
  const IaV2HealthResponseDto({
    required this.status,
    required this.modelLoaded,
    required this.device,
    required this.numClasses,
    required this.classNames,
  });

  final String status;
  final bool modelLoaded;
  final String device;
  final int numClasses;
  final List<String> classNames;

  factory IaV2HealthResponseDto.fromJson(Map<String, dynamic> json) {
    return IaV2HealthResponseDto(
      status: json['status'] as String,
      modelLoaded: json['model_loaded'] as bool,
      device: json['device'] as String,
      numClasses: json['num_classes'] as int,
      classNames: (json['class_names'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }
}

class IaV2HistoryItemDto {
  const IaV2HistoryItemDto({
    required this.id,
    required this.filename,
    required this.classId,
    required this.tipoDano,
    required this.severidad,
    required this.confianza,
    required this.probDist,
    required this.createdAt,
  });

  final String id;
  final String filename;
  final int classId;
  final String tipoDano;
  final String severidad;
  final double confianza;
  final List<double> probDist;
  final String createdAt;

  factory IaV2HistoryItemDto.fromJson(Map<String, dynamic> json) {
    return IaV2HistoryItemDto(
      id: json['id'] as String,
      filename: json['filename'] as String,
      classId: json['class_id'] as int,
      tipoDano: json['tipo_dano'] as String,
      severidad: json['severidad'] as String,
      confianza: (json['confianza'] as num).toDouble(),
      probDist: (json['prob_dist'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      createdAt: json['created_at'] as String,
    );
  }
}

class IaV2RetrainResponseDto {
  const IaV2RetrainResponseDto({
    required this.jobId,
    required this.status,
  });

  final String jobId;
  final String status;

  factory IaV2RetrainResponseDto.fromJson(Map<String, dynamic> json) {
    return IaV2RetrainResponseDto(
      jobId: json['job_id'] as String,
      status: json['status'] as String,
    );
  }
}

class IaV2RetrainStatusResponseDto {
  const IaV2RetrainStatusResponseDto({
    required this.jobId,
    required this.status,
    required this.totalEpochs,
    required this.currentEpoch,
    required this.bestAccuracy,
    required this.lossHistory,
    required this.createdAt,
    this.error,
    this.completedAt,
  });

  final String jobId;
  final String status;
  final int totalEpochs;
  final int currentEpoch;
  final double bestAccuracy;
  final List<double> lossHistory;
  final String? error;
  final String createdAt;
  final String? completedAt;

  factory IaV2RetrainStatusResponseDto.fromJson(Map<String, dynamic> json) {
    return IaV2RetrainStatusResponseDto(
      jobId: json['job_id'] as String,
      status: json['status'] as String,
      totalEpochs: json['total_epochs'] as int,
      currentEpoch: json['current_epoch'] as int,
      bestAccuracy: (json['best_accuracy'] as num).toDouble(),
      lossHistory: (json['loss_history'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      error: json['error'] as String?,
      createdAt: json['created_at'] as String,
      completedAt: json['completed_at'] as String?,
    );
  }
}
