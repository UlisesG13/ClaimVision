import '../../domain/entities/imagen_siniestro.dart';
import '../../domain/entities/siniestro.dart';
import '../../domain/entities/siniestro_estatus.dart';
import '../dtos/imagen_siniestro_response_dto.dart';
import '../dtos/siniestro_response_dto.dart';

/// Convierte los DTOs de siniestro a entidades de dominio. Funciones puras.
class SiniestroMapper {
  SiniestroMapper._();

  static Siniestro toEntity(SiniestroResponseDto dto) {
    return Siniestro(
      id: dto.id,
      aseguradoraId: dto.aseguradoraId,
      clienteId: dto.clienteId,
      ajustadorId: dto.ajustadorId,
      tallerId: dto.tallerId,
      estatus: SiniestroEstatus.fromApi(dto.estatus),
      vehiculoMarca: dto.vehiculoMarca,
      vehiculoModelo: dto.vehiculoModelo,
      vehiculoAnio: dto.vehiculoAnio,
      vehiculoPlacas: dto.vehiculoPlacas,
      vehiculoVin: dto.vehiculoVin,
      latitud: dto.latitud,
      longitud: dto.longitud,
      narracionTexto: dto.narracionTexto,
      narracionAudioUrl: dto.narracionAudioUrl,
      indicacionesDanoInterno: dto.indicacionesDanoInterno,
      fechaSiniestro: dto.fechaSiniestro,
      createdAt: dto.createdAt,
    );
  }

  static ImagenSiniestro toImagenEntity(ImagenSiniestroResponseDto dto) {
    return ImagenSiniestro(
      id: dto.id,
      siniestroId: dto.siniestroId,
      imagenUrl: dto.imagenUrl,
      esCalidadValida: dto.esCalidadValida,
      createdAt: dto.createdAt,
    );
  }
}
