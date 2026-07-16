import 'package:claimvision/shared/data/mappers/siniestro_mapper.dart';
import 'package:claimvision/shared/domain/entities/siniestro.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/damage_adjusted.dart';
import '../../domain/entities/perfil_ajustador.dart';
import '../../domain/entities/peritaje.dart';
import '../../domain/repositories/peritaje_repository.dart';
import '../datasources/remote/peritaje_remote_datasource.dart';
import '../dtos/peritaje_upsert_dto.dart';
import '../mappers/peritaje_mapper.dart';

class PeritajeRepositoryImpl implements PeritajeRepository {
  PeritajeRepositoryImpl(this._remote);

  final PeritajeRemoteDataSource _remote;

  @override
  Future<List<Siniestro>> getCasosAsignados({int page = 1, int pageSize = 20, String? estatus}) async {
    try {
      final pageDto = await _remote.getAsignados(page: page, pageSize: pageSize, estatus: estatus);
      return pageDto.data.map(SiniestroMapper.toEntity).toList();
    } on AppException catch (e) {
      throw _toFailure(e);
    }
  }

  @override
  Future<Peritaje> registrarPeritaje({
    required String siniestroId,
    required double costoDefinitivo,
    required String firmaDigitalBase64,
    required List<DamageAdjusted> danos,
    String? observacionesCampo,
  }) async {
    try {
      final dto = await _remote.registrarPeritaje(
        siniestroId,
        PeritajeUpsertDto(
          costoDefinitivoAjustador: costoDefinitivo,
          firmaDigitalAjustador: firmaDigitalBase64,
          observacionesCampo: observacionesCampo,
          danos: danos.map(PeritajeMapper.danoToDto).toList(),
        ),
      );
      return PeritajeMapper.toEntity(dto);
    } on AppException catch (e) {
      throw _toFailure(e);
    }
  }

  @override
  Future<Siniestro> obtenerDetalleSiniestro(String id) async {
    try {
      final dto = await _remote.obtenerDetalleSiniestro(id);
      return SiniestroMapper.toEntity(dto);
    } on AppException catch (e) {
      throw _toFailure(e);
    }
  }

  @override
  Future<PerfilAjustador> obtenerPerfil() async {
    try {
      final dto = await _remote.obtenerPerfil();
      return PerfilAjustador(
        id: dto.id,
        usuarioId: dto.usuarioId,
        cedulaProfesional: dto.cedulaProfesional,
        geolocalizacionActual: dto.geolocalizacionActual,
        activoParaServicio: dto.activoParaServicio,
        version: dto.version,
        createdAt: dto.createdAt,
        updatedAt: dto.updatedAt,
        deletedAt: dto.deletedAt,
      );
    } on AppException catch (e) {
      throw _toFailure(e);
    }
  }

  Failure _toFailure(AppException e) {
    return switch (e) {
      UnauthorizedException() => AuthFailure(e.message),
      ForbiddenException() => ForbiddenFailure(e.message),
      NotFoundException() => NotFoundFailure(e.message),
      ConflictException() => ConflictFailure(e.message),
      ValidationException() => ValidationFailure(e.message),
      _ => ServerFailure(e.message),
    };
  }
}
