import 'dart:io';

import 'package:claimvision/shared/data/mappers/siniestro_mapper.dart';
import 'package:claimvision/shared/domain/entities/siniestro.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/imagen_siniestro.dart';
import '../../domain/repositories/siniestro_repository.dart';
import '../datasources/remote/siniestro_remote_datasource.dart';
import '../dtos/siniestro_inicializar_dto.dart';
import '../dtos/siniestro_update_dto.dart';

/// Implementación del reporte de siniestros: llama al backend, mapea DTO→Entity
/// y traduce las excepciones técnicas a `Failure`.
class SiniestroRepositoryImpl implements SiniestroRepository {
  SiniestroRepositoryImpl(this._remote);

  final SiniestroRemoteDataSource _remote;

  @override
  Future<Siniestro> inicializar({
    required String vehiculoMarca,
    required String vehiculoModelo,
    required int vehiculoAnio,
    required String vehiculoPlacas,
    required double latitud,
    required double longitud,
    String? vehiculoVin,
    String? narracionTexto,
  }) async {
    try {
      final dto = await _remote.inicializar(
        SiniestroInicializarDto(
          vehiculoMarca: vehiculoMarca,
          vehiculoModelo: vehiculoModelo,
          vehiculoAnio: vehiculoAnio,
          vehiculoPlacas: vehiculoPlacas,
          latitud: latitud,
          longitud: longitud,
          vehiculoVin: vehiculoVin,
          narracionTexto: narracionTexto,
        ),
      );
      return SiniestroMapper.toEntity(dto);
    } on AppException catch (e) {
      throw _toFailure(e);
    }
  }

  @override
  Future<Siniestro> actualizar({
    required String id,
    String? narracionTexto,
    bool? indicacionesDanoInterno,
  }) async {
    try {
      final dto = await _remote.actualizar(
        id,
        SiniestroUpdateDto(
          narracionTexto: narracionTexto,
          indicacionesDanoInterno: indicacionesDanoInterno,
        ),
      );
      return SiniestroMapper.toEntity(dto);
    } on AppException catch (e) {
      throw _toFailure(e);
    }
  }

  @override
  Future<ImagenSiniestro> subirImagen({
    required String id,
    required File imagen,
  }) async {
    try {
      final dto = await _remote.subirImagen(id, imagen);
      return ImagenSiniestro(
        id: dto.id,
        siniestroId: dto.siniestroId,
        imagenUrl: dto.imagenUrl,
        esCalidadValida: dto.esCalidadValida,
        createdAt: dto.createdAt,
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
