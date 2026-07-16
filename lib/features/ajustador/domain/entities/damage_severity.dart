enum DamageSeverity {
  bajo('Bajo', 'Bajo'),
  medio('Medio', 'Medio'),
  alto('Alto', 'Alto');

  const DamageSeverity(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static DamageSeverity fromApi(String? value) =>
      DamageSeverity.values.firstWhere(
        (s) => s.apiValue == value,
        orElse: () => DamageSeverity.medio,
      );
}
