class PerfilAjustador {
  const PerfilAjustador({
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
}
