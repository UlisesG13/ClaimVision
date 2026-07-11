# Graph Report - .  (2026-07-11)

## Corpus Check
- cluster-only mode — file stats not available

## Summary
- 1733 nodes · 2483 edges · 115 communities (106 shown, 9 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 18 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `724f9479`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Win32Window
- providers.dart
- app_toast.dart
- GeneratedPluginRegistrant.swift
- auth_controller.dart
- report_controller.dart
- onboarding_controller.dart
- package:flutter_riverpod/flutter_riverpod.dart
- client_home_page.dart
- app_router.dart
- onboarding_page.dart
- StatelessWidget
- dart:io
- peritaje_editor_provider.dart
- validacion_peritaje_page.dart
- siniestro.dart
- widget_test.dart
- siniestro_update_dto.dart
- package:claimvision/shared/domain/entities/siniestro.dart
- route_paths.dart
- my_application.cc
- api_constants.dart
- auth_repository_impl.dart
- siniestro_repository_impl.dart
- AuthRepository
- notificaciones_provider.dart
- SiniestroRepository
- siniestro_detail_page.dart
- app_colors.dart
- peritaje_repository_impl.dart
- onboarding_remote_datasource.dart
- siniestro_response_dto.dart
- caso_card.dart
- signature_pad.dart
- firma_peritaje_page.dart
- VoidCallback
- ../../../../core/theme/app_spacing.dart
- api_error_mapper.dart
- reportControllerProvider
- report_location_page.dart
- login_page.dart
- register_page.dart
- auth_local_datasource.dart
- report_vehicle_page.dart
- report_damage_page.dart
- app_spacing.dart
- build
- report_analysis_page.dart
- report_narration_page.dart
- ../../../../core/theme/app_colors.dart
- ConsumerState
- peritaje_remote_datasource.dart
- wWinMain
- ajustador_response_dto.dart
- peritaje.dart
- peritaje_mapper.dart
- currentSessionProvider
- failures.dart
- peritaje_response_dto.dart
- perfil_ajustador.dart
- cliente_response_dto.dart
- siniestro_inicializar_dto.dart
- siniestro_card.dart
- manifest.json
- ConsumerWidget
- dano_ajustado.dart
- get_perfil_cliente.dart
- authControllerProvider
- dano_ajustado_dto.dart
- casosAsignadosProvider
- onboarding_data.dart
- perfil_cliente.dart
- package:flutter/material.dart
- cliente_remote_datasource.dart
- List
- validators.dart
- DateTime
- storage_keys.dart
- ReportController
- notificaciones_ajustador_provider.dart
- auth_response_dto.dart
- imagen_siniestro_response_dto.dart
- siniestro_repository.dart
- app.dart
- siniestro_mapper.dart
- handle_new_rx_page
- GeneratedPluginRegistrant
- confirm_data_request_dto.dart
- consent_request_dto.dart
- ocr_response_dto.dart
- register_request_dto.dart
- auth_repository.dart
- date_format.dart
- GeneratedPluginRegistrant.java
- gradlew
- dano_severidad.dart
- dano_tipo.dart
- login_request_dto.dart
- dependencies
- MainActivity
- ChangeNotifier
- PackageDescription
- graphify.js
- recordToolUse.sh script
- flutter_export_environment.sh
- flutter_export_environment.sh
- @correo
- bool?
- String?

## God Nodes (most connected - your core abstractions)
1. `Win32Window` - 22 edges
2. `reportControllerProvider` - 20 edges
3. `authControllerProvider` - 12 edges
4. `misSiniestrosProvider` - 12 edges
5. `MessageHandler` - 12 edges
6. `currentSessionProvider` - 11 edges
7. `build` - 11 edges
8. `FlutterWindow` - 10 edges
9. `Create` - 10 edges
10. `WndProc` - 10 edges

## Surprising Connections (you probably didn't know these)
- `_FakeSecureStorage` --inherits--> `SecureStorageService`  [EXTRACTED]
  test/widget_test.dart → lib/core/services/secure_storage_service.dart
- `wWinMain()` --calls--> `CreateAndAttachConsole()`  [INFERRED]
  windows/runner/main.cpp → windows/runner/utils.cpp
- `Win32Window::Win32Window()` --calls--> `Destroy`  [INFERRED]
  windows/runner/win32_window.cpp → windows/runner/win32_window.h
- `_OnboardingPageState` --references--> `imagePickerServiceProvider`  [EXTRACTED]
  lib/features/auth/presentation/pages/onboarding_page.dart → lib/core/di/providers.dart
- `AuthController` --references--> `loginUserProvider`  [EXTRACTED]
  lib/features/auth/presentation/state/auth_controller.dart → lib/core/di/providers.dart

## Import Cycles
- None detected.

## Communities (115 total, 9 thin omitted)

### Community 0 - "Win32Window"
Cohesion: 0.06
Nodes (53): PluginRegistry, Point, RECT, Size, unique_ptr, RegisterPlugins(), DartProject, HWND (+45 more)

### Community 1 - "providers.dart"
Cohesion: 0.04
Nodes (54): ../../features/ajustador/data/datasources/remote/peritaje_remote_datasource.dart, ../../features/ajustador/data/repositories/peritaje_repository_impl.dart, ../../features/ajustador/domain/repositories/peritaje_repository.dart, ../../features/ajustador/domain/usecases/confirmar_peritaje.dart, ../../features/ajustador/domain/usecases/get_casos_asignados.dart, ../../features/ajustador/domain/usecases/get_perfil_ajustador.dart, ../../features/ajustador/domain/usecases/guardar_peritaje.dart, ../../features/auth/data/datasources/local/auth_local_datasource.dart (+46 more)

### Community 2 - "app_toast.dart"
Cohesion: 0.05
Nodes (45): Animation, AnimationController, Duration, _DanoForm, _DanoFormState, AppTextField, _AppTextFieldState, build (+37 more)

### Community 3 - "GeneratedPluginRegistrant.swift"
Cohesion: 0.05
Nodes (31): Any, Cocoa, file_selector_macos, Flutter, flutter_secure_storage_darwin, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate (+23 more)

### Community 4 - "auth_controller.dart"
Cohesion: 0.05
Nodes (40): AsyncNotifier, AuthSession? get, bool get, ../../../../core/di/providers.dart, getCasosAsignadosProvider, getSiniestrosClienteProvider, getStoredSessionProvider, loginUserProvider (+32 more)

### Community 5 - "report_controller.dart"
Cohesion: 0.06
Nodes (34): int get, anio, build, calidadValida, copyWith, danoInterno, error, errorMessage (+26 more)

### Community 6 - "onboarding_controller.dart"
Cohesion: 0.07
Nodes (33): File?, confirmOnboardingProvider, extractPolicyDataProvider, sendConsentProvider, avisoPrivacidad, biometria, build, canConfirm (+25 more)

### Community 7 - "package:flutter_riverpod/flutter_riverpod.dart"
Cohesion: 0.07
Nodes (28): app.dart, ../../../../core/routes/route_paths.dart, color, _NarracionCard, _Section, siniestroId, _Tag, text (+20 more)

### Community 8 - "client_home_page.dart"
Cohesion: 0.07
Nodes (29): ../../../auth/presentation/state/auth_controller.dart, ../../../auth/presentation/state/onboarding_controller.dart, activos, _EmptyActivity, _Header, label, noLeidas, nombre (+21 more)

### Community 9 - "app_router.dart"
Cohesion: 0.06
Nodes (31): ../../features/ajustador/presentation/pages/caso_detalle_page.dart, ../../features/ajustador/presentation/pages/casos_asignados_page.dart, ../../features/ajustador/presentation/pages/firma_peritaje_page.dart, ../../features/ajustador/presentation/pages/notificaciones_ajustador_page.dart, ../../features/ajustador/presentation/pages/peritaje_confirmado_page.dart, ../../features/ajustador/presentation/pages/validacion_peritaje_page.dart, ../../features/auth/domain/entities/auth_session.dart, ../../features/auth/domain/entities/user_role.dart (+23 more)

### Community 10 - "onboarding_page.dart"
Cohesion: 0.07
Nodes (30): _ConsentRow, controller, createState, _curpController, _DetectedDataCard, dispose, _DocumentSlot, _Field (+22 more)

### Community 11 - "StatelessWidget"
Cohesion: 0.08
Nodes (30): avisoPrivacidad, biometria, children, _ConsentCard, _ConsentRow, curpRfc, email, _Header (+22 more)

### Community 12 - "dart:io"
Cohesion: 0.08
Nodes (24): dart:io, ../entities/onboarding_data.dart, ImagePicker, fromCamera, fromGallery, ImagePickerService, _pick, _picker (+16 more)

### Community 13 - "peritaje_editor_provider.dart"
Cohesion: 0.08
Nodes (28): double get, confirmarPeritajeProvider, guardarPeritajeProvider, actualizarDano, agregarDano, build, copyWith, costoDefinitivo (+20 more)

### Community 14 - "validacion_peritaje_page.dart"
Cohesion: 0.07
Nodes (28): buf, _costo, _CostoCard, createState, dano, _DanoCard, definitivo, dispose (+20 more)

### Community 15 - "siniestro.dart"
Cohesion: 0.07
Nodes (27): ajustadorId, aseguradoraId, clienteId, createdAt, estatus, apiValue, enProceso, fromApi (+19 more)

### Community 16 - "widget_test.dart"
Cohesion: 0.07
Nodes (25): ../constants/api_constants.dart, ../constants/storage_keys.dart, FlutterSecureStorage, create, DioClient, _skipAuthBounce, clearSession, delete (+17 more)

### Community 17 - "siniestro_update_dto.dart"
Cohesion: 0.09
Nodes (26): double?, Exception, int?, AppException, CacheException, ConflictException, ForbiddenException, message (+18 more)

### Community 18 - "package:claimvision/shared/domain/entities/siniestro.dart"
Cohesion: 0.09
Nodes (23): ../entities/dano_ajustado.dart, ../entities/perfil_ajustador.dart, ../entities/peritaje.dart, PeritajeRepositoryImpl, confirmarPeritaje, getCasosAsignados, guardarPeritaje, obtenerPerfil (+15 more)

### Community 19 - "route_paths.dart"
Cohesion: 0.07
Nodes (27): casoDetalle, casoDetalleDe, casos, detalleSiniestro, detalleSiniestroDe, firmaPeritaje, firmaPeritajeDe, historial (+19 more)

### Community 20 - "my_application.cc"
Cohesion: 0.09
Nodes (22): FlPluginRegistry, FlView, GApplication, gboolean, gchar, GObject, GtkApplication, fl_register_plugins() (+14 more)

### Community 21 - "api_constants.dart"
Cohesion: 0.08
Nodes (24): ajustadorAsignaciones, ajustadorConfirmar, ajustadorPerfil, ajustadorPeritaje, ApiConstants, baseUrl, clientePerfil, clienteSiniestro (+16 more)

### Community 22 - "auth_repository_impl.dart"
Cohesion: 0.10
Nodes (21): ../datasources/local/auth_local_datasource.dart, ../datasources/remote/auth_remote_datasource.dart, ../../domain/repositories/auth_repository.dart, ../../dtos/login_request_dto.dart, ../../dtos/register_request_dto.dart, AuthRemoteDataSource, AuthRemoteDataSourceImpl, _dio (+13 more)

### Community 23 - "siniestro_repository_impl.dart"
Cohesion: 0.09
Nodes (22): ../datasources/remote/siniestro_remote_datasource.dart, ../../domain/entities/imagen_siniestro.dart, ../../domain/repositories/siniestro_repository.dart, ../../dtos/imagen_siniestro_response_dto.dart, ../../dtos/siniestro_inicializar_dto.dart, ../../dtos/siniestro_update_dto.dart, actualizar, _dio (+14 more)

### Community 24 - "AuthRepository"
Cohesion: 0.11
Nodes (19): ../entities/auth_session.dart, AuthRepositoryImpl, AuthRepository, call, GetStoredSession, _repository, call, LoginUser (+11 more)

### Community 25 - "notificaciones_provider.dart"
Cohesion: 0.09
Nodes (23): build, _construirSecciones, NotificacionesPage, build, cuerpo, fecha, id, leida (+15 more)

### Community 26 - "SiniestroRepository"
Cohesion: 0.12
Nodes (15): SiniestroRepositoryImpl, SiniestroRepository, ActualizarSiniestro, call, _repository, call, GetSiniestroDetalle, _repository (+7 more)

### Community 27 - "siniestro_detail_page.dart"
Cohesion: 0.10
Nodes (20): _AdjusterCard, _CurrentStateCard, estado, estatus, _EstatusChip, esUltimo, _NarrationCard, _NotFound (+12 more)

### Community 28 - "app_colors.dart"
Cohesion: 0.10
Nodes (20): Color get, alert, amber, AppColors, background, blueprint, borderLight, ColorSeverity (+12 more)

### Community 29 - "peritaje_repository_impl.dart"
Cohesion: 0.10
Nodes (19): ../../../../core/errors/exceptions.dart, ../../../../core/errors/failures.dart, ../datasources/remote/cliente_remote_datasource.dart, ../datasources/remote/peritaje_remote_datasource.dart, ../../domain/entities/perfil_ajustador.dart, ../../domain/entities/perfil_cliente.dart, ../../domain/repositories/cliente_repository.dart, ../../domain/repositories/peritaje_repository.dart (+11 more)

### Community 30 - "onboarding_remote_datasource.dart"
Cohesion: 0.10
Nodes (20): ../../../../../core/constants/api_constants.dart, ../datasources/remote/onboarding_remote_datasource.dart, ../../domain/entities/onboarding_data.dart, ../../domain/repositories/onboarding_repository.dart, ../../dtos/confirm_data_request_dto.dart, ../../dtos/consent_request_dto.dart, ../../dtos/ocr_response_dto.dart, confirmData (+12 more)

### Community 31 - "siniestro_response_dto.dart"
Cohesion: 0.10
Nodes (20): ajustadorId, aseguradoraId, clienteId, createdAt, estatus, fechaSiniestro, fromJson, id (+12 more)

### Community 32 - "caso_card.dart"
Cohesion: 0.11
Nodes (18): ../../../cliente/presentation/widgets/siniestro_card.dart, Color, IconData, build, CasoCard, color, icon, _Line (+10 more)

### Community 33 - "signature_pad.dart"
Cohesion: 0.10
Nodes (19): CustomPainter, dart:convert, dart:ui, GlobalKey, appendPoint, boundaryKey, build, clear (+11 more)

### Community 34 - "firma_peritaje_page.dart"
Cohesion: 0.11
Nodes (18): ajustador, buf, costo, createState, danos, dispose, _fila, _firma (+10 more)

### Community 35 - "VoidCallback"
Cohesion: 0.11
Nodes (17): build, onBack, pasoActual, ReportStepHeader, subtitulo, totalPasos, build, _color (+9 more)

### Community 36 - "../../../../core/theme/app_spacing.dart"
Cohesion: 0.11
Nodes (16): ../../../../core/theme/app_spacing.dart, AppDialog, confirm, hideLoading, info, permission, retry, showLoading (+8 more)

### Community 37 - "api_error_mapper.dart"
Cohesion: 0.12
Nodes (14): ../errors/exceptions.dart, ApiErrorMapper, _byStatus, _defaultMessage, _extractDetail, fromDioException, fromResponse, Coordenada (+6 more)

### Community 38 - "reportControllerProvider"
Cohesion: 0.13
Nodes (16): imagePickerServiceProvider, build, _capturar, ReportDamagePage, build, _continuar, initState, build (+8 more)

### Community 39 - "report_location_page.dart"
Cohesion: 0.14
Nodes (15): locationServiceProvider, createState, _fecha, icon, label, lista, _locating, _MapCard (+7 more)

### Community 40 - "login_page.dart"
Cohesion: 0.12
Nodes (15): _comingSoon, createState, dispose, _emailController, _Footer, _formKey, _Header, isLoading (+7 more)

### Community 41 - "register_page.dart"
Cohesion: 0.12
Nodes (15): createState, dispose, _emailController, _formKey, _goToLogin, _Header, isLoading, _nombreController (+7 more)

### Community 42 - "auth_local_datasource.dart"
Cohesion: 0.15
Nodes (13): ../../../../../core/constants/storage_keys.dart, ../../../../../core/services/secure_storage_service.dart, ../../../domain/entities/auth_session.dart, ../../../domain/entities/user_role.dart, ../../dtos/auth_response_dto.dart, AuthLocalDataSource, AuthLocalDataSourceImpl, cacheSession (+5 more)

### Community 43 - "report_vehicle_page.dart"
Cohesion: 0.13
Nodes (14): FormState, _anio, _anioValidator, build, createState, dispose, _formKey, _hayProgreso (+6 more)

### Community 44 - "report_damage_page.dart"
Cohesion: 0.13
Nodes (14): _AddTile, _CaptureCard, color, error, evidencia, icon, onRemove, onTap (+6 more)

### Community 45 - "app_spacing.dart"
Cohesion: 0.14
Nodes (13): AppSpacing, lg, md, radiusLg, radiusMd, radiusSm, radiusXl, sm (+5 more)

### Community 46 - "build"
Cohesion: 0.19
Nodes (14): build, build, ProfilePage, onboardingControllerProvider, build, build, build, RoutePaths.detalleSiniestroDe (+6 more)

### Community 47 - "report_analysis_page.dart"
Cohesion: 0.14
Nodes (13): _AdjusterNote, _AnalysisCard, danoInterno, fotosValidas, label, _Row, _SentHero, siniestro (+5 more)

### Community 48 - "report_narration_page.dart"
Cohesion: 0.14
Nodes (13): _continuar, createState, _DanoInternoTile, dispose, _narracion, onChanged, onTap, _snack (+5 more)

### Community 49 - "../../../../core/theme/app_colors.dart"
Cohesion: 0.09
Nodes (22): ../../../../core/theme/app_colors.dart, createState, _EmptyState, _ErrorState, _filtrar, _Header, mensaje, nombre (+14 more)

### Community 50 - "ConsumerState"
Cohesion: 0.23
Nodes (12): ConsumerState, ConsumerStatefulWidget, CasosAsignadosPage, _CasosAsignadosPageState, LoginPage, _LoginPageState, RegisterPage, _RegisterPageState (+4 more)

### Community 52 - "peritaje_remote_datasource.dart"
Cohesion: 0.18
Nodes (11): ../../dtos/ajustador_response_dto.dart, ../../dtos/peritaje_upsert_dto.dart, confirmar, _dio, _ensureSuccess, getAsignados, guardarPeritaje, obtenerPerfil (+3 more)

### Community 53 - "wWinMain"
Cohesion: 0.24
Nodes (9): _In_, _In_opt_, vector, wWinMain(), string, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments() (+1 more)

### Community 54 - "ajustador_response_dto.dart"
Cohesion: 0.17
Nodes (11): activoParaServicio, AjustadorResponseDto, cedulaProfesional, createdAt, deletedAt, fromJson, geolocalizacionActual, id (+3 more)

### Community 55 - "peritaje.dart"
Cohesion: 0.18
Nodes (10): dano_ajustado.dart, ajustadorId, costoDefinitivoAjustador, createdAt, danos, id, observacionesCampo, Peritaje (+2 more)

### Community 56 - "peritaje_mapper.dart"
Cohesion: 0.18
Nodes (10): ../../domain/entities/dano_ajustado.dart, ../../domain/entities/dano_severidad.dart, ../../domain/entities/dano_tipo.dart, ../../domain/entities/peritaje.dart, ../dtos/dano_ajustado_dto.dart, ../../dtos/peritaje_response_dto.dart, danoToDto, _danoToEntity (+2 more)

### Community 57 - "currentSessionProvider"
Cohesion: 0.22
Nodes (11): currentSessionProvider, build, _confirmar, build, PeritajeConfirmadoPage, build, ValidacionPeritajePage, peritajeEditorProvider (+3 more)

### Community 58 - "failures.dart"
Cohesion: 0.31
Nodes (10): AuthFailure, CacheFailure, ConflictFailure, Failure, ForbiddenFailure, message, NotFoundFailure, ServerFailure (+2 more)

### Community 59 - "peritaje_response_dto.dart"
Cohesion: 0.18
Nodes (10): ajustadorId, costoDefinitivoAjustador, createdAt, danos, fromJson, id, observacionesCampo, PeritajeResponseDto (+2 more)

### Community 60 - "perfil_ajustador.dart"
Cohesion: 0.18
Nodes (10): activoParaServicio, cedulaProfesional, createdAt, deletedAt, geolocalizacionActual, id, PerfilAjustador, updatedAt (+2 more)

### Community 61 - "cliente_response_dto.dart"
Cohesion: 0.18
Nodes (10): autorizaTransferenciaTalleres, ClienteResponseDto, consentimientoAvisoPrivacidad, consentimientoBiometria, fechaConsentimiento, fromJson, id, numeroPoliza (+2 more)

### Community 62 - "siniestro_inicializar_dto.dart"
Cohesion: 0.18
Nodes (10): latitud, longitud, narracionTexto, SiniestroInicializarDto, toJson, vehiculoAnio, vehiculoMarca, vehiculoModelo (+2 more)

### Community 63 - "siniestro_card.dart"
Cohesion: 0.18
Nodes (10): build, estatus, icon, _IconLine, onTap, siniestro, SiniestroCard, SiniestroEstatusChip (+2 more)

### Community 64 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 65 - "ConsumerWidget"
Cohesion: 0.27
Nodes (10): ConsumerWidget, ClientHomePage, HistorialPage, ReportAnalysisPage, build, SiniestroDetailPage, build, VehiculosPage (+2 more)

### Community 66 - "dano_ajustado.dart"
Cohesion: 0.20
Nodes (9): dano_severidad.dart, dano_tipo.dart, copyWith, costoRealReparacion, DanoAjustado, id, severidad, tipo (+1 more)

### Community 67 - "get_perfil_cliente.dart"
Cohesion: 0.22
Nodes (8): ../entities/perfil_cliente.dart, ClienteRepositoryImpl, ClienteRepository, obtenerPerfil, call, GetPerfilCliente, _repository, ../repositories/cliente_repository.dart

### Community 68 - "authControllerProvider"
Cohesion: 0.20
Nodes (10): create, build, _submit, _confirmarLogout, build, _submit, authControllerProvider, _confirmLogout (+2 more)

### Community 69 - "dano_ajustado_dto.dart"
Cohesion: 0.20
Nodes (9): costoRealReparacion, DanoAjustadoDto, fromJson, id, origenCambio, severidad, tipo, toJson (+1 more)

### Community 70 - "casosAsignadosProvider"
Cohesion: 0.24
Nodes (10): build, CasoDetallePage, build, build, NotificacionesAjustadorPage, casosAsignadosProvider, notificacionesAjustadorLeidasProvider, RoutePaths.casoDetalleDe (+2 more)

### Community 71 - "onboarding_data.dart"
Cohesion: 0.20
Nodes (9): avisoPrivacidad, biometria, ConsentData, copyWith, curpRfc, numeroPoliza, OnboardingData, transferenciaTalleres (+1 more)

### Community 72 - "perfil_cliente.dart"
Cohesion: 0.20
Nodes (9): autorizaTransferenciaTalleres, consentimientoAvisoPrivacidad, consentimientoBiometria, fechaConsentimiento, id, numeroPoliza, PerfilCliente, usuarioId (+1 more)

### Community 73 - "package:flutter/material.dart"
Cohesion: 0.22
Nodes (7): app_colors.dart, app_spacing.dart, app_typography.dart, AppTheme, AppTypography, package:flutter/material.dart, package:google_fonts/google_fonts.dart

### Community 74 - "cliente_remote_datasource.dart"
Cohesion: 0.25
Nodes (8): ../../../../../core/network/api_error_mapper.dart, Dio, ../../dtos/cliente_response_dto.dart, ClienteRemoteDataSource, ClienteRemoteDataSourceImpl, _dio, _ensureSuccess, obtenerPerfil

### Community 75 - "List"
Cohesion: 0.22
Nodes (8): dano_ajustado_dto.dart, costoDefinitivoAjustador, danos, firmaDigitalAjustador, observacionesCampo, PeritajeUpsertDto, toJson, List

### Community 76 - "validators.dart"
Cohesion: 0.22
Nodes (8): email, _emailRegex, fullName, newPassword, password, requiredField, Validators, static final RegExp

### Community 77 - "DateTime"
Cohesion: 0.25
Nodes (7): DateTime, createdAt, esCalidadValida, id, ImagenSiniestro, imagenUrl, siniestroId

### Community 78 - "storage_keys.dart"
Cohesion: 0.25
Nodes (7): aseguradoraId, email, rol, StorageKeys, token, usuarioId, static const String

### Community 79 - "ReportController"
Cohesion: 0.25
Nodes (8): actualizarSiniestroProvider, inicializarSiniestroProvider, subirImagenSiniestroProvider, crearSiniestro, guardarNarracion, ReportController, ReportState, subirEvidencia

### Community 80 - "notificaciones_ajustador_provider.dart"
Cohesion: 0.29
Nodes (7): build, marcarLeida, marcarLeidas, NotificacionesAjustadorLeidas, NotificacionesLeidas, Notifier, Set

### Community 81 - "auth_response_dto.dart"
Cohesion: 0.25
Nodes (7): aseguradoraId, AuthResponseDto, email, fromJson, rol, token, usuarioId

### Community 82 - "imagen_siniestro_response_dto.dart"
Cohesion: 0.25
Nodes (7): createdAt, esCalidadValida, fromJson, id, ImagenSiniestroResponseDto, imagenUrl, siniestroId

### Community 83 - "siniestro_repository.dart"
Cohesion: 0.18
Nodes (9): ../entities/imagen_siniestro.dart, actualizar, inicializar, listar, obtener, subirImagen, call, _repository (+1 more)

### Community 84 - "app.dart"
Cohesion: 0.40
Nodes (5): core/routes/app_router.dart, core/theme/app_theme.dart, build, ClaimVisionApp, routerProvider

### Community 85 - "siniestro_mapper.dart"
Cohesion: 0.33
Nodes (5): ../../domain/entities/siniestro.dart, ../../domain/entities/siniestro_estatus.dart, ../dtos/siniestro_response_dto.dart, SiniestroMapper, toEntity

### Community 86 - "handle_new_rx_page"
Cohesion: 0.33
Nodes (5): handle_new_rx_page(), __lldb_init_module(), Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages., SBDebugger, SBFrame

### Community 87 - "GeneratedPluginRegistrant"
Cohesion: 0.40
Nodes (3): GeneratedPluginRegistrant, +registerWithRegistry, NSObject

### Community 88 - "confirm_data_request_dto.dart"
Cohesion: 0.33
Nodes (5): ConfirmDataRequestDto, curpRfc, numeroPoliza, toJson, vigenciaPoliza

### Community 89 - "consent_request_dto.dart"
Cohesion: 0.33
Nodes (5): avisoPrivacidad, biometria, ConsentRequestDto, toJson, transferenciaTalleres

### Community 90 - "ocr_response_dto.dart"
Cohesion: 0.33
Nodes (5): curpRfc, fromJson, numeroPoliza, OcrResponseDto, vigenciaPoliza

### Community 91 - "register_request_dto.dart"
Cohesion: 0.33
Nodes (5): email, nombre, password, RegisterRequestDto, toJson

### Community 92 - "auth_repository.dart"
Cohesion: 0.33
Nodes (5): getStoredSession, login, logout, register, verifySession

### Community 93 - "date_format.dart"
Cohesion: 0.33
Nodes (5): DateFormatEs, fecha, fechaHora, _meses, static const List

### Community 94 - "GeneratedPluginRegistrant.java"
Cohesion: 0.60
Nodes (3): GeneratedPluginRegistrant, FlutterEngine, Keep

### Community 95 - "gradlew"
Cohesion: 0.60
Nodes (3): gradlew script, die(), warn()

### Community 96 - "dano_severidad.dart"
Cohesion: 0.40
Nodes (4): apiValue, DanoSeveridad, fromApi, label

### Community 97 - "dano_tipo.dart"
Cohesion: 0.40
Nodes (4): apiValue, DanoTipo, fromApi, label

### Community 98 - "login_request_dto.dart"
Cohesion: 0.40
Nodes (4): email, LoginRequestDto, password, toJson

### Community 99 - "dependencies"
Cohesion: 0.50
Nodes (3): @opencode-ai/plugin, dependencies, @opencode-ai/plugin

### Community 101 - "ChangeNotifier"
Cohesion: 0.67
Nodes (3): ChangeNotifier, _AuthRefreshNotifier, SignatureController

## Knowledge Gaps
- **900 isolated node(s):** `recordToolUse.sh script`, `@opencode-ai/plugin`, `flutter_export_environment.sh script`, `+registerWithRegistry`, `ApiConstants` (+895 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **9 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Siniestro` connect `siniestro_detail_page.dart` to `caso_card.dart`, `report_controller.dart`, `package:flutter_riverpod/flutter_riverpod.dart`, `peritaje_editor_provider.dart`, `report_analysis_page.dart`, `siniestro.dart`, `siniestro_card.dart`?**
  _High betweenness centrality (0.016) - this node is a cross-community bridge._
- **Why does `AuthRepository` connect `AuthRepository` to `providers.dart`, `auth_repository.dart`?**
  _High betweenness centrality (0.015) - this node is a cross-community bridge._
- **Why does `DanoSeveridad` connect `dano_severidad.dart` to `dano_ajustado.dart`, `validacion_peritaje_page.dart`?**
  _High betweenness centrality (0.013) - this node is a cross-community bridge._
- **What connects `recordToolUse.sh script`, `@opencode-ai/plugin`, `IMPORTANT: keep the reminder string free of backticks and $(...) constructs.` to the rest of the system?**
  _902 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Win32Window` be split into smaller, more focused modules?**
  _Cohesion score 0.0597567424643046 - nodes in this community are weakly interconnected._
- **Should `providers.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.03636363636363636 - nodes in this community are weakly interconnected._
- **Should `app_toast.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.04625346901017576 - nodes in this community are weakly interconnected._