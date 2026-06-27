import 'package:claimvision/shared/data/mappers/siniestro_mapper.dart';
import 'package:claimvision/shared/domain/entities/siniestro.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/dano_ajustado.dart';
import '../../domain/entities/peritaje.dart';
import '../../domain/repositories/peritaje_repository.dart';
import '../datasources/remote/peritaje_remote_datasource.dart';
import '../dtos/peritaje_upsert_dto.dart';
import '../mappers/peritaje_mapper.dart';

/// Implementación del flujo del ajustador: llama al backend, mapea DTO→Entity y
/// traduce las excepciones técnicas a `Failure`.
class PeritajeRepositoryImpl implements PeritajeRepository {
  PeritajeRepositoryImpl(this._remote);

  final PeritajeRemoteDataSource _remote;

  @override
  Future<List<Siniestro>> getCasosAsignados() async {
    try {
      final dtos = await _remote.getAsignados();
      return dtos.map(SiniestroMapper.toEntity).toList();
    } on AppException catch (e) {
      throw _toFailure(e);
    }
  }

  @override
  Future<Peritaje> guardarPeritaje({
    required String siniestroId,
    required double costoDefinitivo,
    required String firmaDigitalBase64,
    required List<DanoAjustado> danos,
    String? observacionesCampo,
  }) async {
    try {
      final dto = await _remote.guardarPeritaje(
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
  Future<Siniestro> confirmarPeritaje(String siniestroId) async {
    try {
      final dto = await _remote.confirmar(siniestroId);
      return SiniestroMapper.toEntity(dto);
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
