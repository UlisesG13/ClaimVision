
enum SiniestroStatus {
  reportadoPreliminar('Reportado_Preliminar', 'Reportado'),
  asignadoAjustador('Asignado_A_Ajustador', 'Asignado a ajustador'),
  peritajeValidado('Peritaje_Validado', 'Peritaje validado'),
  asignadoTaller('Asignado_A_Taller', 'En taller'),
  trabajoConcluido('Trabajo_Concluido', 'Trabajo concluido'),
  listoParaEntrega('Listo_Para_Entrega', 'Listo para entrega'),
  entregado('Entregado', 'Entregado');

  const SiniestroStatus(this.apiValue, this.label);

  final String apiValue;

  final String label;

  static SiniestroStatus fromApi(String? value) {
    return SiniestroStatus.values.firstWhere(
      (e) => e.apiValue == value,
      orElse: () => SiniestroStatus.reportadoPreliminar,
    );
  }

  bool get enProceso => this != SiniestroStatus.entregado;

  SiniestroStatusTono get tono {
    return switch (this) {
      SiniestroStatus.reportadoPreliminar => SiniestroStatusTono.neutro,
      SiniestroStatus.asignadoAjustador ||
      SiniestroStatus.asignadoTaller =>
        SiniestroStatusTono.proceso,
      SiniestroStatus.peritajeValidado ||
      SiniestroStatus.trabajoConcluido =>
        SiniestroStatusTono.info,
      SiniestroStatus.listoParaEntrega ||
      SiniestroStatus.entregado =>
        SiniestroStatusTono.exito,
    };
  }
}

enum SiniestroStatusTono { neutro, proceso, info, exito }
