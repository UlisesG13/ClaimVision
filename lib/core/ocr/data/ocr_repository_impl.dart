import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/errors/failures.dart';
import '../domain/ocr_extraction.dart';
import '../domain/ocr_repository.dart';
import 'datasources/ocr_remote_datasource.dart';

class OcrRepositoryImpl implements OcrRepository {
  OcrRepositoryImpl(this._datasource);

  final OcrRemoteDataSource _datasource;

  @override
  Future<OcrExtraction> extract({
    required File ineFront,
    File? ineBack,
    required File policy,
  }) async {
    try {
      final json = await _datasource.extractOcr(
        ineFront: ineFront,
        ineBack: ineBack,
        policy: policy,
      );
      return OcrExtraction.fromJson(json);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Failure _mapError(DioException e) {
    return switch (e.response?.statusCode) {
      400 || 422 => ValidationFailure(_mensajeValidacion(e)),
      502 => const ServerFailure(
          'El servicio de OCR no está disponible en este momento.'),
      _ => const ServerFailure(),
    };
  }

  String _mensajeValidacion(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final details = data['details'];
      if (details is List) {
        return details.join('\n');
      }
      return data['error'] as String? ??
          'La imagen no cumple con los estándares requeridos.';
    }
    return 'Revisa las imágenes e inténtalo de nuevo.';
  }
}
