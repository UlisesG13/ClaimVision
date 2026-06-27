/// Tipo de daño con los valores EXACTOS que acepta el backend
/// (`DanoAjustadoDTO.tipo`).
enum DanoTipo {
  abolladura('Abolladura', 'Abolladura'),
  rayadura('Rayadura', 'Rayadura'),
  fractura('Fractura', 'Fractura'),
  roturaCristal('Rotura_Cristal', 'Rotura de cristal'),
  deformacion('Deformacion', 'Deformación');

  const DanoTipo(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static DanoTipo fromApi(String? value) => DanoTipo.values.firstWhere(
        (t) => t.apiValue == value,
        orElse: () => DanoTipo.abolladura,
      );
}
