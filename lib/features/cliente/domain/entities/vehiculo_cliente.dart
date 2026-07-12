class VehiculoCliente {
  const VehiculoCliente({
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

  String get resumen => '$marca $modelo $anio · $placas';
}
