import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../constants/storage_keys.dart';
import '../services/secure_storage_service.dart';

/// Construye la instancia de [Dio] usada por toda la app.
///
/// Incluye un interceptor global que:
///  - Inyecta el token Bearer en cada request protegida.
///  - Ante un 401, limpia la sesión local (el token JWT es stateless y no hay
///    refresh; al expirar, el usuario debe volver a iniciar sesión).
///
/// El mapeo de [DioException] a `Failure` se hace en la capa `data`
/// (repositorios), no aquí: este cliente solo transporta.
class DioClient {
  DioClient._();

  /// Rutas donde un 401 es esperado/manejado por la propia pantalla y NO debe
  /// disparar el cierre de sesión global (login fallido, validación de sesión
  /// en el arranque).
  static const Set<String> _skipAuthBounce = {
    ApiConstants.login,
    ApiConstants.me,
  };

  static Dio create(
    SecureStorageService storage, {
    void Function()? onUnauthorized,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        contentType: Headers.jsonContentType,
        // No lanzar por códigos < 500: dejamos que el repositorio decida
        // según el status code para construir el Failure adecuado.
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.read(StorageKeys.token);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onResponse: (response, handler) async {
          if (response.statusCode == 401) {
            // Token ausente/expirado: descartamos la sesión local.
            await storage.clearSession();
            final path = response.requestOptions.path;
            if (!_skipAuthBounce.contains(path)) {
              // Llamada protegida con sesión inválida → volver al login.
              onUnauthorized?.call();
            }
          }
          handler.next(response);
        },
      ),
    );

    return dio;
  }
}
