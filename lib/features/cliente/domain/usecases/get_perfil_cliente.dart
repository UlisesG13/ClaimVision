import '../entities/perfil_cliente.dart';
import '../repositories/cliente_repository.dart';

class GetPerfilCliente {
  const GetPerfilCliente(this._repository);

  final ClienteRepository _repository;

  Future<PerfilCliente> call() {
    return _repository.obtenerPerfil();
  }
}
