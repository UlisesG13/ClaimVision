import '../../domain/entities/damage_adjusted.dart';
import '../../domain/entities/damage_severity.dart';
import '../../domain/entities/damage_type.dart';
import '../../domain/entities/peritaje.dart';
import '../dtos/damage_adjusted_dto.dart';
import '../dtos/peritaje_response_dto.dart';

/// Convierte DTOs del peritaje a entidades de dominio (y daños a DTO).
class PeritajeMapper {
  PeritajeMapper._();

  static Peritaje toEntity(PeritajeResponseDto dto) {
    return Peritaje(
      id: dto.id,
      siniestroId: dto.siniestroId,
      ajustadorId: dto.ajustadorId,
      costoDefinitivoAjustador: dto.costoDefinitivoAjustador,
      observacionesCampo: dto.observacionesCampo,
      danos: dto.danos.map(_danoToEntity).toList(),
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  static DamageAdjusted _danoToEntity(DamageAdjustedDto dto) {
    return DamageAdjusted(
      id: dto.id,
      zonaVehiculo: dto.zonaVehiculo,
      tipo: DamageType.fromApi(dto.tipo),
      severidad: DamageSeverity.fromApi(dto.severidad),
      costoRealReparacion: dto.costoRealReparacion,
    );
  }

  static DamageAdjustedDto danoToDto(DamageAdjusted dano) {
    return DamageAdjustedDto(
      id: dano.id,
      zonaVehiculo: dano.zonaVehiculo,
      tipo: dano.tipo.apiValue,
      severidad: dano.severidad.apiValue,
      costoRealReparacion: dano.costoRealReparacion,
    );
  }
}
