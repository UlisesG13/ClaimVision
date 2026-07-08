import 'package:dio/dio.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/network/api_error_mapper.dart';
import '../../dtos/cliente_response_dto.dart';

abstract interface class ClienteRemoteDataSource {
  Future<ClienteResponseDto> obtenerPerfil();
}

class ClienteRemoteDataSourceImpl implements ClienteRemoteDataSource {
  ClienteRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<ClienteResponseDto> obtenerPerfil() async {
    try {
      final response = await _dio.get(ApiConstants.clientePerfil);
      _ensureSuccess(response);
      return ClienteResponseDto.fromJson(
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
