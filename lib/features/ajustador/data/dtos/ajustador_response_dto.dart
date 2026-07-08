class AjustadorResponseDto {
  const AjustadorResponseDto({
    required this.id,
    required this.usuarioId,
    required this.cedulaProfesional,
    required this.activoParaServicio,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    this.geolocalizacionActual,
    this.deletedAt,
  });

  final String id;
  final String usuarioId;
  final String cedulaProfesional;
  final List<double>? geolocalizacionActual;
  final bool activoParaServicio;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  factory AjustadorResponseDto.fromJson(Map<String, dynamic> json) {
    DateTime toDate(dynamic v) =>
        DateTime.tryParse('$v')?.toLocal() ?? DateTime.now();
    DateTime? toNullableDate(dynamic v) =>
        v != null ? DateTime.tryParse('$v')?.toLocal() : null;

    return AjustadorResponseDto(
      id: (json['id'] ?? '').toString(),
      usuarioId: (json['usuario_id'] ?? '').toString(),
      cedulaProfesional: (json['cedula_profesional'] ?? '').toString(),
      geolocalizacionActual: json['geolocalizacion_actual'] != null
          ? (json['geolocalizacion_actual'] as List)
              .map((e) => (e as num).toDouble())
              .toList()
          : null,
      activoParaServicio: json['activo_para_servicio'] == true,
      version: (json['version'] as num?)?.toInt() ?? 0,
      createdAt: toDate(json['created_at']),
      updatedAt: toDate(json['updated_at']),
      deletedAt: toNullableDate(json['deleted_at']),
    );
  }
}
