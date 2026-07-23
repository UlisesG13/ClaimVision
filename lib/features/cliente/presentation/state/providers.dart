import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../shared/domain/models/documento.dart';
import '../../data/datasources/remote/cliente_remote_datasource.dart';
import '../../data/datasources/remote/documento_remote_datasource.dart';
import '../../data/datasources/remote/siniestro_remote_datasource.dart';
import '../../data/repositories/cliente_repository_impl.dart';
import '../../data/repositories/documento_repository_impl.dart';
import '../../data/repositories/siniestro_repository_impl.dart';
import '../../domain/entities/vehiculo_cliente.dart';
import '../../domain/repositories/cliente_repository.dart';
import '../../domain/repositories/documento_repository.dart';
import '../../domain/repositories/siniestro_repository.dart';
import '../../domain/usecases/get_perfil_cliente.dart';
import '../../domain/usecases/get_siniestro_detalle.dart';
import '../../domain/usecases/get_siniestros_cliente.dart';
import '../../domain/usecases/inicializar_siniestro.dart';
import '../../domain/usecases/subir_imagen_siniestro.dart';

// ── Siniestros (cliente): datasource, repositorio y casos de uso ───────────
final siniestroRemoteDataSourceProvider =
    Provider<SiniestroRemoteDataSource>((ref) {
  return SiniestroRemoteDataSourceImpl(ref.watch(dioProvider));
});

final siniestroRepositoryProvider = Provider<SiniestroRepository>((ref) {
  return SiniestroRepositoryImpl(ref.watch(siniestroRemoteDataSourceProvider));
});

final inicializarSiniestroProvider = Provider<InicializarSiniestro>((ref) {
  return InicializarSiniestro(ref.watch(siniestroRepositoryProvider));
});

final subirImagenSiniestroProvider = Provider<SubirImagenSiniestro>((ref) {
  return SubirImagenSiniestro(ref.watch(siniestroRepositoryProvider));
});

// ── Cliente v1: perfil ─────────────────────────────────────────────────────
final clienteRemoteDataSourceProvider = Provider<ClienteRemoteDataSource>((ref) {
  return ClienteRemoteDataSourceImpl(ref.watch(dioProvider));
});

final clienteRepositoryProvider = Provider<ClienteRepository>((ref) {
  return ClienteRepositoryImpl(ref.watch(clienteRemoteDataSourceProvider));
});

final getPerfilClienteProvider = Provider<GetPerfilCliente>((ref) {
  return GetPerfilCliente(ref.watch(clienteRepositoryProvider));
});

// ── Cliente v1: listar / detalle siniestros ────────────────────────────────
final getSiniestrosClienteProvider = Provider<GetSiniestrosCliente>((ref) {
  return GetSiniestrosCliente(ref.watch(siniestroRepositoryProvider));
});

final getSiniestroDetalleProvider = Provider<GetSiniestroDetalle>((ref) {
  return GetSiniestroDetalle(ref.watch(siniestroRepositoryProvider));
});

// ── Cliente v1: vehículos ────────────────────────────────────────────────────
final vehiculosClienteProvider = FutureProvider.autoDispose<List<VehiculoCliente>>((ref) {
  ref.watch(currentSessionProvider);
  return ref.watch(siniestroRepositoryProvider).obtenerVehiculos();
});

// ── Documentos (INE + Póliza) ─────────────────────────────────────────────────
final documentoRemoteDataSourceProvider = Provider<DocumentoRemoteDataSource>((ref) {
  return DocumentoRemoteDataSourceImpl(ref.watch(dioProvider));
});

final documentoRepositoryProvider = Provider<DocumentoRepository>((ref) {
  return DocumentoRepositoryImpl(ref.watch(documentoRemoteDataSourceProvider));
});

final documentosProvider = FutureProvider.autoDispose<DocumentosResponse>((ref) {
  ref.watch(currentSessionProvider);
  return ref.watch(documentoRepositoryProvider).obtener();
});
