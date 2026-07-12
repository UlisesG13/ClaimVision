class VehiculoResponseDto {
  const VehiculoResponseDto({
    required this.id,
    required this.marca,
    required this.modelo,
    required this.anio,
    required this.placas,
    this.vin,
  });

  final String id;
  final String marca;
  final String modelo;
  final int anio;
  final String placas;
  final String? vin;

  factory VehiculoResponseDto.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
    return VehiculoResponseDto(
      id: (json['id'] ?? '').toString(),
      marca: (json['marca'] ?? '').toString(),
      modelo: (json['modelo'] ?? '').toString(),
      anio: toInt(json['anio']),
      placas: (json['placas'] ?? '').toString(),
      vin: json['vin'] as String?,
    );
  }
}
