import '../entities/perfil_ajustador.dart';
import '../repositories/peritaje_repository.dart';

class GetPerfilAjustador {
  const GetPerfilAjustador(this._repository);

  final PeritajeRepository _repository;

  Future<PerfilAjustador> call() {
    return _repository.obtenerPerfil();
  }
}
