import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../data/datasources/remote/peritaje_remote_datasource.dart';
import '../../data/repositories/peritaje_repository_impl.dart';
import '../../domain/repositories/peritaje_repository.dart';
import '../../domain/usecases/get_casos_asignados.dart';
import '../../domain/usecases/get_detalle_ajustador.dart';
import '../../domain/usecases/get_perfil_ajustador.dart';
import '../../domain/usecases/registrar_peritaje.dart';

// ── Peritaje (ajustador): datasource, repositorio y casos de uso ───────────
final peritajeRemoteDataSourceProvider =
    Provider<PeritajeRemoteDataSource>((ref) {
  return PeritajeRemoteDataSourceImpl(ref.watch(dioProvider));
});

final peritajeRepositoryProvider = Provider<PeritajeRepository>((ref) {
  return PeritajeRepositoryImpl(ref.watch(peritajeRemoteDataSourceProvider));
});

final getCasosAsignadosProvider = Provider<GetCasosAsignados>((ref) {
  return GetCasosAsignados(ref.watch(peritajeRepositoryProvider));
});

final registrarPeritajeProvider = Provider<RegistrarPeritaje>((ref) {
  return RegistrarPeritaje(ref.watch(peritajeRepositoryProvider));
});

final getDetalleAjustadorProvider = Provider<GetDetalleAjustador>((ref) {
  return GetDetalleAjustador(ref.watch(peritajeRepositoryProvider));
});

final getPerfilAjustadorProvider = Provider<GetPerfilAjustador>((ref) {
  return GetPerfilAjustador(ref.watch(peritajeRepositoryProvider));
});
