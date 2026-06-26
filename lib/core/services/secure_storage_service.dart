import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/storage_keys.dart';

/// Acceso centralizado al almacenamiento seguro del dispositivo.
///
/// Es el ÚNICO lugar autorizado para persistir el token JWT y los datos
/// sensibles de la sesión (regla de seguridad del proyecto). Las datasources
/// locales lo reciben por inyección desde `core/di/`.
class SecureStorageService {
  SecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> delete(String key) => _storage.delete(key: key);

  /// Borra toda la sesión almacenada (logout / expiración de token).
  Future<void> clearSession() async {
    await Future.wait([
      delete(StorageKeys.token),
      delete(StorageKeys.usuarioId),
      delete(StorageKeys.email),
      delete(StorageKeys.rol),
      delete(StorageKeys.aseguradoraId),
    ]);
  }
}
