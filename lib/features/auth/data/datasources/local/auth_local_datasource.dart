import '../../../../../core/constants/storage_keys.dart';
import '../../../../../core/services/secure_storage_service.dart';
import '../../../domain/entities/auth_session.dart';
import '../../../domain/entities/user_role.dart';

/// Persistencia local de la sesión en almacenamiento seguro.
/// Es la única vía para guardar el token JWT en el dispositivo.
abstract interface class AuthLocalDataSource {
  Future<void> cacheSession(AuthSession session);
  Future<AuthSession?> readSession();
  Future<void> clearSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl(this._storage);

  final SecureStorageService _storage;

  @override
  Future<void> cacheSession(AuthSession session) async {
    await Future.wait([
      _storage.write(StorageKeys.token, session.token),
      _storage.write(StorageKeys.usuarioId, session.usuarioId),
      _storage.write(StorageKeys.email, session.email),
      _storage.write(StorageKeys.rol, session.rol.apiValue),
      if (session.aseguradoraId != null)
        _storage.write(StorageKeys.aseguradoraId, session.aseguradoraId!)
      else
        _storage.delete(StorageKeys.aseguradoraId),
    ]);
  }

  @override
  Future<AuthSession?> readSession() async {
    final token = await _storage.read(StorageKeys.token);
    if (token == null || token.isEmpty) return null;

    final usuarioId = await _storage.read(StorageKeys.usuarioId);
    final email = await _storage.read(StorageKeys.email);
    final rol = await _storage.read(StorageKeys.rol);
    if (usuarioId == null || email == null || rol == null) return null;

    return AuthSession(
      token: token,
      usuarioId: usuarioId,
      email: email,
      rol: UserRole.fromApi(rol),
      aseguradoraId: await _storage.read(StorageKeys.aseguradoraId),
    );
  }

  @override
  Future<void> clearSession() => _storage.clearSession();
}
