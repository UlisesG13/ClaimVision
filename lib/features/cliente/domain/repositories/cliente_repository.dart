import '../entities/perfil_cliente.dart';

abstract interface class ClienteRepository {
  Future<PerfilCliente> obtenerPerfil();
}
