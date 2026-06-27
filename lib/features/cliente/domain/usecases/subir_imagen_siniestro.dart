import 'dart:io';

import '../entities/imagen_siniestro.dart';
import '../repositories/siniestro_repository.dart';

/// Caso de uso: subir una imagen del daño al siniestro.
class SubirImagenSiniestro {
  const SubirImagenSiniestro(this._repository);

  final SiniestroRepository _repository;

  Future<ImagenSiniestro> call({required String id, required File imagen}) {
    return _repository.subirImagen(id: id, imagen: imagen);
  }
}
