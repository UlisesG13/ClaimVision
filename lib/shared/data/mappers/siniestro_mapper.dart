import '../../domain/entities/siniestro.dart';
import '../../domain/entities/siniestro_status.dart';
import '../dtos/siniestro_response_dto.dart';

class SiniestroMapper {
  SiniestroMapper._();

  static Siniestro toEntity(SiniestroResponseDto dto) {
    return Siniestro(
      id: dto.id,
      aseguradoraId: dto.aseguradoraId,
      clienteId: dto.clienteId,
      ajustadorId: dto.ajustadorId,
      tallerId: dto.tallerId,
      estatus: SiniestroStatus.fromApi(dto.estatus),
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
