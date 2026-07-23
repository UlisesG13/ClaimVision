import 'dart:io';

import '../../../../shared/domain/models/documento.dart';

abstract interface class DocumentoRepository {
  Future<DocumentosResponse> obtener();
  Future<DocumentosResponse> subir({
    required File identificacion,
    File? identificacionReverso,
    required File poliza,
  });
}
