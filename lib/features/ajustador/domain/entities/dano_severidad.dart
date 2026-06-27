/// Severidad del daño con los valores EXACTOS del backend
/// (`DanoAjustadoDTO.severidad`).
enum DanoSeveridad {
  bajo('Bajo', 'Bajo'),
  medio('Medio', 'Medio'),
  alto('Alto', 'Alto');

  const DanoSeveridad(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static DanoSeveridad fromApi(String? value) =>
      DanoSeveridad.values.firstWhere(
        (s) => s.apiValue == value,
        orElse: () => DanoSeveridad.medio,
      );
}
