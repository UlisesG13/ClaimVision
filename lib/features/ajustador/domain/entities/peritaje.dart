import 'damage_adjusted.dart';

/// Peritaje validado por el ajustador. Entidad pura, modelada según
/// `PeritajeResponseDTO`.
class Peritaje {
  const Peritaje({
    required this.id,
    required this.siniestroId,
    required this.ajustadorId,
    required this.costoDefinitivoAjustador,
    required this.danos,
    required this.createdAt,
    required this.updatedAt,
    this.observacionesCampo,
  });

  final String id;
  final String siniestroId;
  final String ajustadorId;
  final double costoDefinitivoAjustador;
  final String? observacionesCampo;
  final List<DamageAdjusted> danos;
  final DateTime createdAt;
  final DateTime updatedAt;
}
