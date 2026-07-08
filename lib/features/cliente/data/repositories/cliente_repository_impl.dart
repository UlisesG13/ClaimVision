import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/perfil_cliente.dart';
import '../../domain/repositories/cliente_repository.dart';
import '../datasources/remote/cliente_remote_datasource.dart';

class ClienteRepositoryImpl implements ClienteRepository {
  ClienteRepositoryImpl(this._remote);

  final ClienteRemoteDataSource _remote;

  @override
  Future<PerfilCliente> obtenerPerfil() async {
    try {
      final dto = await _remote.obtenerPerfil();
      return PerfilCliente(
        id: dto.id,
        usuarioId: dto.usuarioId,
        numeroPoliza: dto.numeroPoliza,
        vigenciaPoliza: dto.vigenciaPoliza,
        consentimientoAvisoPrivacidad: dto.consentimientoAvisoPrivacidad,
        consentimientoBiometria: dto.consentimientoBiometria,
        autorizaTransferenciaTalleres: dto.autorizaTransferenciaTalleres,
        fechaConsentimiento: dto.fechaConsentimiento,
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
