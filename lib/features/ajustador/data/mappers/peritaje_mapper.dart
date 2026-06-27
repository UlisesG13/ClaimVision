import '../../domain/entities/dano_ajustado.dart';
import '../../domain/entities/dano_severidad.dart';
import '../../domain/entities/dano_tipo.dart';
import '../../domain/entities/peritaje.dart';
import '../dtos/dano_ajustado_dto.dart';
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

  static DanoAjustado _danoToEntity(DanoAjustadoDto dto) {
    return DanoAjustado(
      id: dto.id,
      zonaVehiculo: dto.zonaVehiculo,
      tipo: DanoTipo.fromApi(dto.tipo),
      severidad: DanoSeveridad.fromApi(dto.severidad),
      costoRealReparacion: dto.costoRealReparacion,
    );
  }

  static DanoAjustadoDto danoToDto(DanoAjustado dano) {
    return DanoAjustadoDto(
      id: dano.id,
      zonaVehiculo: dano.zonaVehiculo,
      tipo: dano.tipo.apiValue,
      severidad: dano.severidad.apiValue,
      costoRealReparacion: dano.costoRealReparacion,
    );
  }
}
