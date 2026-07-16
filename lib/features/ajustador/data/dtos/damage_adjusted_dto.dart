class DamageAdjustedDto {
  const DamageAdjustedDto({
    required this.zonaVehiculo,
    required this.tipo,
    required this.severidad,
    required this.costoRealReparacion,
    this.id,
    this.origenCambio = 'AJUSTADOR',
  });

  final String? id;
  final String zonaVehiculo;
  final String tipo;
  final String severidad;
  final double costoRealReparacion;
  final String origenCambio;

  Map<String, dynamic> toJson() => {
        'zona_vehiculo': zonaVehiculo,
        'tipo': tipo,
        'severidad': severidad,
        'costo_real_reparacion': costoRealReparacion,
        'origen_cambio': origenCambio,
      };

  factory DamageAdjustedDto.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
    return DamageAdjustedDto(
      id: json['id'] as String?,
      zonaVehiculo: (json['zona_vehiculo'] ?? '').toString(),
      tipo: (json['tipo'] ?? '').toString(),
      severidad: (json['severidad'] ?? '').toString(),
      costoRealReparacion: toDouble(json['costo_real_reparacion']),
      origenCambio: (json['origen_cambio'] ?? 'AJUSTADOR').toString(),
    );
  }
}
