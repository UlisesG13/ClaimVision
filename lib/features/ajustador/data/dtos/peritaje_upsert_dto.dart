import 'damage_adjusted_dto.dart';

/// Cuerpo de `POST /api/v1/ajustador/siniestros/{id}/peritaje` (`PeritajeUpsertRequestDTO`).
/// Campos verbatim del backend.
class PeritajeUpsertDto {
  const PeritajeUpsertDto({
    required this.costoDefinitivoAjustador,
    required this.firmaDigitalAjustador,
    required this.danos,
    this.observacionesCampo,
  });

  final double costoDefinitivoAjustador;
  final String firmaDigitalAjustador;
  final String? observacionesCampo;
  final List<DamageAdjustedDto> danos;

  Map<String, dynamic> toJson() => {
        'costo_definitivo_ajustador': costoDefinitivoAjustador,
        'firma_digital_ajustador': firmaDigitalAjustador,
        if (observacionesCampo != null && observacionesCampo!.isNotEmpty)
          'observaciones_campo': observacionesCampo,
        'danos': danos.map((d) => d.toJson()).toList(),
      };
}
