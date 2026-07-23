import 'dart:io';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/domain/models/documento.dart';
import '../../domain/repositories/documento_repository.dart';
import '../datasources/remote/documento_remote_datasource.dart';

class DocumentoRepositoryImpl implements DocumentoRepository {
  DocumentoRepositoryImpl(this._remote);

  final DocumentoRemoteDataSource _remote;

  @override
  Future<DocumentosResponse> obtener() async {
    try {
      return await _remote.obtener();
    } on AppException catch (e) {
      throw _toFailure(e);
    }
  }

  @override
  Future<DocumentosResponse> subir({
    required File identificacion,
    File? identificacionReverso,
    required File poliza,
  }) async {
    try {
      return await _remote.subir(
        identificacion: identificacion,
        identificacionReverso: identificacionReverso,
        poliza: poliza,
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
