import 'damage_severity.dart';
import 'damage_type.dart';

class DamageAdjusted {
  const DamageAdjusted({
    required this.zonaVehiculo,
    required this.tipo,
    required this.severidad,
    required this.costoRealReparacion,
    this.id,
  });

  final String? id;
  final String zonaVehiculo;
  final DamageType tipo;
  final DamageSeverity severidad;
  final double costoRealReparacion;

  DamageAdjusted copyWith({
    String? zonaVehiculo,
    DamageType? tipo,
    DamageSeverity? severidad,
    double? costoRealReparacion,
  }) {
    return DamageAdjusted(
      id: id,
      zonaVehiculo: zonaVehiculo ?? this.zonaVehiculo,
      tipo: tipo ?? this.tipo,
      severidad: severidad ?? this.severidad,
      costoRealReparacion: costoRealReparacion ?? this.costoRealReparacion,
    );
  }
}
