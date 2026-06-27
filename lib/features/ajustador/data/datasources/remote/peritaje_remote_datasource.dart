import 'package:claimvision/shared/data/dtos/siniestro_response_dto.dart';
import 'package:dio/dio.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/network/api_error_mapper.dart';
import '../../dtos/peritaje_response_dto.dart';
import '../../dtos/peritaje_upsert_dto.dart';

/// Llamadas REST del flujo del ajustador (tag Peritaje). El token Bearer lo
/// añade el interceptor del Dio. Lanza [AppException] tipadas ante error.
abstract interface class PeritajeRemoteDataSource {
  Future<List<SiniestroResponseDto>> getAsignados();
  Future<PeritajeResponseDto> guardarPeritaje(String id, PeritajeUpsertDto body);
  Future<SiniestroResponseDto> confirmar(String id);
}

class PeritajeRemoteDataSourceImpl implements PeritajeRemoteDataSource {
  PeritajeRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<SiniestroResponseDto>> getAsignados() async {
    try {
      final response = await _dio.get(ApiConstants.siniestrosAsignados);
      _ensureSuccess(response);
      final data = (response.data as List?) ?? const [];
      return data
          .map((e) => SiniestroResponseDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDioException(e);
    }
  }

  @override
  Future<PeritajeResponseDto> guardarPeritaje(
      String id, PeritajeUpsertDto body) async {
    try {
      final response = await _dio.put(
        ApiConstants.siniestroPeritaje(id),
        data: body.toJson(),
      );
      _ensureSuccess(response);
      return PeritajeResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDioException(e);
    }
  }

  @override
  Future<SiniestroResponseDto> confirmar(String id) async {
    try {
      final response = await _dio.post(ApiConstants.siniestroConfirmar(id));
      _ensureSuccess(response);
      return SiniestroResponseDto.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDioException(e);
    }
  }

  void _ensureSuccess(Response response) {
    final status = response.statusCode ?? 500;
    if (status >= 400) {
      throw ApiErrorMapper.fromResponse(response);
    }
  }
}
