import 'dano_ajustado_dto.dart';

/// Respuesta de `PUT /api/siniestros/{id}/peritaje` (`PeritajeResponseDTO`).
class PeritajeResponseDto {
  const PeritajeResponseDto({
    required this.id,
    required this.siniestroId,
    required this.ajustadorId,
    required this.costoDefinitivoAjustador,
    required this.danos,
    required this.createdAt,
    required this.updatedAt,
    this.observacionesCampo,
  });

  final String id;
  final String siniestroId;
  final String ajustadorId;
  final double costoDefinitivoAjustador;
  final String? observacionesCampo;
  final List<DanoAjustadoDto> danos;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory PeritajeResponseDto.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
    DateTime toDate(dynamic v) =>
        DateTime.tryParse('$v')?.toLocal() ?? DateTime.now();
    final danosJson = (json['danos'] as List?) ?? const [];

    return PeritajeResponseDto(
      id: json['id'].toString(),
      siniestroId: (json['siniestro_id'] ?? '').toString(),
      ajustadorId: (json['ajustador_id'] ?? '').toString(),
      costoDefinitivoAjustador: toDouble(json['costo_definitivo_ajustador']),
      observacionesCampo: json['observaciones_campo'] as String?,
      danos: danosJson
          .map((d) => DanoAjustadoDto.fromJson(d as Map<String, dynamic>))
          .toList(),
      createdAt: toDate(json['created_at']),
      updatedAt: toDate(json['updated_at']),
    );
  }
}
