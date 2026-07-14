
enum SiniestroEstatus {
  reportadoPreliminar('Reportado_Preliminar', 'Reportado'),
  asignadoAjustador('Asignado_A_Ajustador', 'Asignado a ajustador'),
  peritajeValidado('Peritaje_Validado', 'Peritaje validado'),
  asignadoTaller('Asignado_A_Taller', 'En taller'),
  trabajoConcluido('Trabajo_Concluido', 'Trabajo concluido'),
  listoParaEntrega('Listo_Para_Entrega', 'Listo para entrega'),
  entregado('Entregado', 'Entregado');

  const SiniestroEstatus(this.apiValue, this.label);

  final String apiValue;

  final String label;

  static SiniestroEstatus fromApi(String? value) {
    return SiniestroEstatus.values.firstWhere(
      (e) => e.apiValue == value,
      orElse: () => SiniestroEstatus.reportadoPreliminar,
    );
  }

  /// Indica si el siniestro sigue en proceso (no entregado).
  bool get enProceso => this != SiniestroEstatus.entregado;

  /// Categoría de color para los chips de estado (la UI traduce a color).
  SiniestroEstatusTono get tono {
    return switch (this) {
      SiniestroEstatus.reportadoPreliminar => SiniestroEstatusTono.neutro,
      SiniestroEstatus.asignadoAjustador ||
      SiniestroEstatus.asignadoTaller =>
        SiniestroEstatusTono.proceso,
      SiniestroEstatus.peritajeValidado ||
      SiniestroEstatus.trabajoConcluido =>
        SiniestroEstatusTono.info,
      SiniestroEstatus.listoParaEntrega ||
      SiniestroEstatus.entregado =>
        SiniestroEstatusTono.exito,
    };
  }
}

/// Tono visual del estado (la capa de presentación lo mapea a un color del tema).
enum SiniestroEstatusTono { neutro, proceso, info, exito }
