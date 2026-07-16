enum DamageType {
  abolladura('Abolladura', 'Abolladura'),
  rayadura('Rayadura', 'Rayadura'),
  fractura('Fractura', 'Fractura'),
  roturaCristal('Rotura_Cristal', 'Rotura de cristal'),
  deformacion('Deformacion', 'Deformación');

  const DamageType(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static DamageType fromApi(String? value) => DamageType.values.firstWhere(
        (t) => t.apiValue == value,
        orElse: () => DamageType.abolladura,
      );
}
