/// Imagen subida a un siniestro. Modelada según `ImagenSiniestroResponseDTO`.
class ImagenSiniestro {
  const ImagenSiniestro({
    required this.id,
    required this.siniestroId,
    required this.imagenUrl,
    required this.esCalidadValida,
    required this.createdAt,
  });

  final String id;
  final String siniestroId;
  final String imagenUrl;

  /// Si la imagen pasó la validación de calidad del backend.
  final bool esCalidadValida;
  final DateTime createdAt;
}
