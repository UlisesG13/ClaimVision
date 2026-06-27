import 'dart:io';

import '../entities/imagen_siniestro.dart';
import 'package:claimvision/shared/domain/entities/siniestro.dart';

/// Contrato del reporte de siniestros del cliente. Lanza `Failure` ante error.
abstract interface class SiniestroRepository {
  /// Crea el siniestro preliminar (requiere vehículo + ubicación).
  Future<Siniestro> inicializar({
    required String vehiculoMarca,
    required String vehiculoModelo,
    required int vehiculoAnio,
    required String vehiculoPlacas,
    required double latitud,
    required double longitud,
    String? vehiculoVin,
    String? narracionTexto,
  });

  /// Actualiza campos del siniestro (narración, daño interno, etc.).
  Future<Siniestro> actualizar({
    required String id,
    String? narracionTexto,
    bool? indicacionesDanoInterno,
  });

  /// Sube una imagen del daño al siniestro.
  Future<ImagenSiniestro> subirImagen({
    required String id,
    required File imagen,
  });
}
