import 'dart:io';

import 'package:claimvision/shared/data/mappers/siniestro_mapper.dart';
import 'package:claimvision/shared/domain/entities/siniestro.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/imagen_siniestro.dart';
import '../../domain/repositories/siniestro_repository.dart';
import '../datasources/remote/siniestro_remote_datasource.dart';
import '../dtos/siniestro_inicializar_dto.dart';

class SiniestroRepositoryImpl implements SiniestroRepository {
  SiniestroRepositoryImpl(this._remote);

  final SiniestroRemoteDataSource _remote;

  @override
  Future<Siniestro> crear({
    required String vehiculoMarca,
    required String vehiculoModelo,
    required int vehiculoAnio,
    required String vehiculoPlacas,
    required double latitud,
    required double longitud,
    String? vehiculoVin,
    String? narracionTexto,
    String? narracionAudioUrl,
    bool? indicacionesDanoInterno,
    DateTime? fechaSiniestro,
  }) async {
    try {
      final dto = await _remote.crear(
        SiniestroInicializarDto(
          vehiculoMarca: vehiculoMarca,
          vehiculoModelo: vehiculoModelo,
          vehiculoAnio: vehiculoAnio,
          vehiculoPlacas: vehiculoPlacas,
          latitud: latitud,
          longitud: longitud,
          vehiculoVin: vehiculoVin,
          narracionTexto: narracionTexto,
          narracionAudioUrl: narracionAudioUrl,
          indicacionesDanoInterno: indicacionesDanoInterno,
          fechaSiniestro: fechaSiniestro,
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

  @override
  Future<List<Siniestro>> listar({int page = 1, int pageSize = 20, String? estatus}) async {
    try {
      final pageDto = await _remote.listar(page: page, pageSize: pageSize, estatus: estatus);
      return pageDto.data.map(SiniestroMapper.toEntity).toList();
    } on AppException catch (e) {
      throw _toFailure(e);
    }
  }

  @override
  Future<Siniestro> obtener(String id) async {
    try {
      final dto = await _remote.obtener(id);
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
