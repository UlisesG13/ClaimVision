import 'dart:io';

import '../entities/imagen_siniestro.dart';
import 'package:claimvision/shared/domain/entities/siniestro.dart';

abstract interface class SiniestroRepository {
  Future<Siniestro> crear({
    required String vehiculoMarca,
    required String vehiculoModelo,
    required int vehiculoAnio,
    required String vehiculoPlacas,
    required double latitud,
    required double longitud,
    String? vehiculoVin,
    String? narracionTexto,
    String? narracionAudioUrl,
    bool? indicacionesDanoInterno,
    DateTime? fechaSiniestro,
  });

  Future<ImagenSiniestro> subirImagen({
    required String id,
    required File imagen,
  });

  Future<List<Siniestro>> listar({int page = 1, int pageSize = 20, String? estatus});

  Future<Siniestro> obtener(String id);
}
