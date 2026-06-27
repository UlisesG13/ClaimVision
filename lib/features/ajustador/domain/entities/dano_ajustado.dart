import 'dano_severidad.dart';
import 'dano_tipo.dart';

/// Un daño registrado por el ajustador durante la validación del peritaje.
/// Entidad pura, modelada según `DanoAjustadoDTO`.
class DanoAjustado {
  const DanoAjustado({
    required this.zonaVehiculo,
    required this.tipo,
    required this.severidad,
    required this.costoRealReparacion,
    this.id,
  });

  /// Id del daño (solo presente cuando viene del backend).
  final String? id;
  final String zonaVehiculo;
  final DanoTipo tipo;
  final DanoSeveridad severidad;
  final double costoRealReparacion;

  DanoAjustado copyWith({
    String? zonaVehiculo,
    DanoTipo? tipo,
    DanoSeveridad? severidad,
    double? costoRealReparacion,
  }) {
    return DanoAjustado(
      id: id,
      zonaVehiculo: zonaVehiculo ?? this.zonaVehiculo,
      tipo: tipo ?? this.tipo,
      severidad: severidad ?? this.severidad,
      costoRealReparacion: costoRealReparacion ?? this.costoRealReparacion,
    );
  }
}
