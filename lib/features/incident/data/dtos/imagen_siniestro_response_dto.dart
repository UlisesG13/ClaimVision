/// Respuesta de `POST /api/siniestros/{id}/imagenes`
/// (`ImagenSiniestroResponseDTO`). Campos verbatim.
class ImagenSiniestroResponseDto {
  const ImagenSiniestroResponseDto({
    required this.id,
    required this.siniestroId,
    required this.imagenUrl,
    required this.esCalidadValida,
    required this.createdAt,
  });

  final String id;
  final String siniestroId;
  final String imagenUrl;
  final bool esCalidadValida;
  final DateTime createdAt;

  factory ImagenSiniestroResponseDto.fromJson(Map<String, dynamic> json) {
    return ImagenSiniestroResponseDto(
      id: json['id'].toString(),
      siniestroId: (json['siniestro_id'] ?? '').toString(),
      imagenUrl: (json['imagen_url'] ?? '').toString(),
      esCalidadValida: json['es_calidad_valida'] == true,
      createdAt: DateTime.tryParse('${json['created_at']}')?.toLocal() ??
          DateTime.now(),
    );
  }
}
