import '../../domain/entities/siniestro.dart';
import '../../domain/entities/siniestro_estatus.dart';
import '../dtos/siniestro_response_dto.dart';

/// Convierte `SiniestroResponseDTO` a la entidad de dominio. Función pura.
/// Compartido entre cliente y ajustador.
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
}
