# Graph Report - claimvision  (2026-07-17)

## Corpus Check
- 210 files · ~71,140 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 2148 nodes · 3086 edges · 154 communities (147 shown, 7 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 18 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `813901d8`
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
- _ClientHomePageState
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
- biometric_repository_impl.dart
- biometric_repository.dart
- secure_storage_service.dart
- _ToastWidgetState
- vehiculo_response_dto.dart
- security_providers.dart
- dio_client.dart
- theme_notifier.dart
- api_error_mapper.dart
- biometric_service.dart
- auth_session.dart
- List
- bool get
- siniestro_repository.dart
- Cambios P0 — ClaimVision Backend
- OnboardingController
- security_status.dart
- device_inspector_service.dart
- siniestro_status.dart
- ../../../../core/di/providers.dart
- biometric_providers.dart
- auth_mapper.dart
- blocked_page.dart
- onboardingControllerProvider
- get_perfil_ajustador.dart
- biometric_auth_service.dart
- casos_asignados_controller.dart
- damage_severity.dart
- damage_type.dart
- change_password_request_dto.dart
- biometric_credentials.dart
- ajustador_routes.dart
- validation_indicator.dart
- _ClaimVisionAppState
- image_validator.dart
- ReportController
- app_theme.dart
- ChangeNotifier

## God Nodes (most connected - your core abstractions)
1. `Win32Window` - 22 edges
2. `reportControllerProvider` - 19 edges
3. `currentSessionProvider` - 13 edges
4. `authControllerProvider` - 13 edges
5. `_ClientHomePageState` - 13 edges
6. `MessageHandler` - 12 edges
7. `build` - 11 edges
8. `misSiniestrosControllerProvider` - 11 edges
9. `build` - 10 edges
10. `FlutterWindow` - 10 edges

## Surprising Connections (you probably didn't know these)
- `_FakeDeviceInspector` --implements--> `DeviceInspector`  [EXTRACTED]
  test/widget_test.dart → lib/core/security/domain/services/device_inspector.dart
- `_FakeSecureStorage` --inherits--> `SecureStorageService`  [EXTRACTED]
  test/widget_test.dart → lib/core/services/secure_storage_service.dart
- `wWinMain()` --calls--> `CreateAndAttachConsole()`  [INFERRED]
  windows/runner/main.cpp → windows/runner/utils.cpp
- `Win32Window::Win32Window()` --calls--> `Destroy`  [INFERRED]
  windows/runner/win32_window.cpp → windows/runner/win32_window.h
- `_desactivarBiometria` --references--> `biometricRepositoryProvider`  [EXTRACTED]
  lib/features/auth/presentation/pages/profile_page.dart → lib/core/biometric/presentation/providers/biometric_providers.dart

## Import Cycles
- None detected.

## Communities (154 total, 7 thin omitted)

### Community 0 - "Win32Window"
Cohesion: 0.06
Nodes (53): PluginRegistry, Point, RECT, Size, unique_ptr, RegisterPlugins(), DartProject, HWND (+45 more)

### Community 1 - "providers.dart"
Cohesion: 0.03
Nodes (65): ../../features/ajustador/data/datasources/remote/peritaje_remote_datasource.dart, ../../features/ajustador/data/repositories/peritaje_repository_impl.dart, ../../features/ajustador/domain/repositories/peritaje_repository.dart, ../../features/ajustador/domain/usecases/get_casos_asignados.dart, ../../features/ajustador/domain/usecases/get_detalle_ajustador.dart, ../../features/ajustador/domain/usecases/get_perfil_ajustador.dart, ../../features/ajustador/domain/usecases/registrar_peritaje.dart, ../../features/auth/data/datasources/local/auth_local_datasource.dart (+57 more)

### Community 2 - "app_toast.dart"
Cohesion: 0.09
Nodes (21): Animation, AnimationController, Duration, AppToast, build, _cerrar, _controller, createState (+13 more)

### Community 3 - "GeneratedPluginRegistrant.swift"
Cohesion: 0.05
Nodes (32): Any, Cocoa, file_selector_macos, Flutter, flutter_secure_storage_darwin, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate (+24 more)

### Community 4 - "auth_controller.dart"
Cohesion: 0.14
Nodes (17): AuthSession? get, getStoredSessionProvider, loginUserProvider, logoutUserProvider, registerUserProvider, verifySessionProvider, AuthSession, AuthController (+9 more)

### Community 5 - "report_controller.dart"
Cohesion: 0.05
Nodes (37): int get, anio, build, calidadValida, copyWith, danoInterno, error, errorMessage (+29 more)

### Community 6 - "onboarding_controller.dart"
Cohesion: 0.08
Nodes (25): avisoPrivacidad, biometria, build, canConfirm, cedula, completed, copyWith, curpRfc (+17 more)

### Community 7 - "package:flutter_riverpod/flutter_riverpod.dart"
Cohesion: 0.09
Nodes (20): app.dart, ../../../cliente/presentation/widgets/siniestro_card.dart, color, _NarracionCard, _Section, siniestroId, _Tag, text (+12 more)

### Community 8 - "client_home_page.dart"
Cohesion: 0.09
Nodes (22): ../../../auth/presentation/state/auth_controller.dart, ../../../auth/presentation/state/onboarding_controller.dart, activos, createState, _EmptyActivity, _Header, initState, label (+14 more)

### Community 9 - "app_router.dart"
Cohesion: 0.11
Nodes (17): ../../features/ajustador/presentation/routes/ajustador_routes.dart, ../../features/auth/domain/entities/auth_session.dart, ../../features/auth/domain/entities/user_role.dart, ../../features/auth/presentation/routes/auth_routes.dart, ../../features/auth/presentation/state/auth_controller.dart, ../../features/cliente/presentation/routes/cliente_routes.dart, GoRouter, build (+9 more)

### Community 10 - "onboarding_page.dart"
Cohesion: 0.07
Nodes (27): _ConsentRow, controller, createState, _curpController, _DetectedDataCard, dispose, _DocumentSlot, _Field (+19 more)

### Community 11 - "StatelessWidget"
Cohesion: 0.06
Nodes (39): avisoPrivacidad, biometria, _BiometricCard, _biometricDisponible, _biometricEnabled, children, _ConsentCard, _ConsentRow (+31 more)

### Community 12 - "dart:io"
Cohesion: 0.16
Nodes (13): ../entities/onboarding_data.dart, OnboardingRepositoryImpl, OnboardingRepository, call, ConfirmOnboarding, _repository, call, ExtractPolicyData (+5 more)

### Community 13 - "peritaje_editor_provider.dart"
Cohesion: 0.08
Nodes (27): double?, registrarPeritajeProvider, actualizarDano, agregarDano, build, copyWith, costoDefinitivo, costoOverride (+19 more)

### Community 14 - "validacion_peritaje_page.dart"
Cohesion: 0.07
Nodes (27): buf, _costo, _CostoCard, createState, dano, _DanoCard, definitivo, dispose (+19 more)

### Community 15 - "siniestro.dart"
Cohesion: 0.06
Nodes (29): anio, id, marca, modelo, placas, resumen, VehiculoCliente, vin (+21 more)

### Community 16 - "widget_test.dart"
Cohesion: 0.15
Nodes (12): package:claimvision/app.dart, package:claimvision/core/di/providers.dart, package:claimvision/core/security/domain/entities/security_status.dart, package:claimvision/core/security/domain/services/device_inspector.dart, package:claimvision/core/services/secure_storage_service.dart, package:flutter_test/flutter_test.dart, clearSession, delete (+4 more)

### Community 17 - "siniestro_update_dto.dart"
Cohesion: 0.09
Nodes (26): Exception, int?, AppException, CacheException, ConflictException, ForbiddenException, message, NotFoundException (+18 more)

### Community 18 - "package:claimvision/shared/domain/entities/siniestro.dart"
Cohesion: 0.18
Nodes (11): ../entities/damage_adjusted.dart, ../entities/peritaje.dart, PeritajeRepositoryImpl, getCasosAsignados, obtenerDetalleSiniestro, obtenerPerfil, PeritajeRepository, registrarPeritaje (+3 more)

### Community 19 - "route_paths.dart"
Cohesion: 0.07
Nodes (29): bloqueado, capturaDocumentos, casoDetalle, casoDetalleDe, casos, detalleSiniestro, detalleSiniestroDe, firmaPeritaje (+21 more)

### Community 20 - "my_application.cc"
Cohesion: 0.09
Nodes (22): FlPluginRegistry, FlView, GApplication, gboolean, gchar, GObject, GtkApplication, fl_register_plugins() (+14 more)

### Community 21 - "api_constants.dart"
Cohesion: 0.07
Nodes (27): ajustadorAsignaciones, ajustadorEditarPeritaje, ajustadorPerfil, ajustadorPeritajeDanos, ajustadorRegistrarPeritaje, ajustadorSiniestro, ApiConstants, baseUrl (+19 more)

### Community 22 - "auth_repository_impl.dart"
Cohesion: 0.09
Nodes (24): ../datasources/local/auth_local_datasource.dart, ../datasources/remote/auth_remote_datasource.dart, ../../domain/repositories/auth_repository.dart, ../dtos/change_password_request_dto.dart, ../dtos/login_request_dto.dart, ../dtos/register_request_dto.dart, AuthRemoteDataSource, AuthRemoteDataSourceImpl (+16 more)

### Community 23 - "siniestro_repository_impl.dart"
Cohesion: 0.14
Nodes (14): ../../dtos/imagen_siniestro_response_dto.dart, ../dtos/siniestro_inicializar_dto.dart, ../../dtos/vehiculo_response_dto.dart, crear, _dio, _ensureSuccess, listar, obtener (+6 more)

### Community 24 - "AuthRepository"
Cohesion: 0.09
Nodes (22): ../entities/auth_session.dart, AuthRepositoryImpl, AuthRepository, call, ChangePassword, _repository, call, GetStoredSession (+14 more)

### Community 25 - "notificaciones_provider.dart"
Cohesion: 0.07
Nodes (29): build, _construirSecciones, _Empty, _hora, notificacion, NotificacionesPage, _NotificacionTile, onTap (+21 more)

### Community 26 - "SiniestroRepository"
Cohesion: 0.15
Nodes (12): SiniestroRepositoryImpl, SiniestroRepository, call, GetSiniestroDetalle, _repository, call, GetSiniestrosCliente, _repository (+4 more)

### Community 27 - "siniestro_detail_page.dart"
Cohesion: 0.12
Nodes (15): _AdjusterCard, _CurrentStateCard, estado, estatus, _EstatusChip, esUltimo, _NarrationCard, _NotFound (+7 more)

### Community 28 - "app_colors.dart"
Cohesion: 0.05
Nodes (39): BuildContext, Color get, adapt, alert, amber, AppColors, background, blueprint (+31 more)

### Community 29 - "peritaje_repository_impl.dart"
Cohesion: 0.09
Nodes (21): ../datasources/remote/peritaje_remote_datasource.dart, ../../domain/entities/damage_adjusted.dart, ../../domain/entities/damage_severity.dart, ../../domain/entities/damage_type.dart, ../../domain/entities/perfil_ajustador.dart, ../../domain/entities/peritaje.dart, ../../domain/repositories/peritaje_repository.dart, ../dtos/damage_adjusted_dto.dart (+13 more)

### Community 30 - "onboarding_remote_datasource.dart"
Cohesion: 0.11
Nodes (19): ../datasources/remote/onboarding_remote_datasource.dart, ../../domain/entities/onboarding_data.dart, ../../domain/repositories/onboarding_repository.dart, ../dtos/confirm_data_request_dto.dart, ../dtos/consent_request_dto.dart, ../../dtos/ocr_response_dto.dart, confirmData, _dio (+11 more)

### Community 31 - "siniestro_response_dto.dart"
Cohesion: 0.10
Nodes (20): ajustadorId, aseguradoraId, clienteId, createdAt, estatus, fechaSiniestro, fromJson, id (+12 more)

### Community 32 - "caso_card.dart"
Cohesion: 0.08
Nodes (26): ../../core/theme/app_spacing.dart, _Empty, _Empty, siniestro, _VehiculoCard, build, onBack, pasoActual (+18 more)

### Community 33 - "signature_pad.dart"
Cohesion: 0.11
Nodes (18): CustomPainter, dart:ui, GlobalKey, appendPoint, boundaryKey, build, clear, controller (+10 more)

### Community 34 - "firma_peritaje_page.dart"
Cohesion: 0.12
Nodes (17): ajustador, buf, costo, createState, danos, dispose, _fila, _firma (+9 more)

### Community 35 - "VoidCallback"
Cohesion: 0.07
Nodes (28): Color, IconData?, build, CasoCard, color, icon, _Line, onValidar (+20 more)

### Community 36 - "../../../../core/theme/app_spacing.dart"
Cohesion: 0.10
Nodes (20): document_capture_page.dart, capture, _DocumentCard, _Header, onBack, onTap, _openCapture, type (+12 more)

### Community 37 - "api_error_mapper.dart"
Cohesion: 0.13
Nodes (13): ../errors/exceptions.dart, ApiErrorMapper, _byStatus, _defaultMessage, _extractDetail, fromDioException, fromResponse, Coordenada (+5 more)

### Community 38 - "reportControllerProvider"
Cohesion: 0.13
Nodes (16): imagePickerServiceProvider, ReportAnalysisPage, build, _capturar, ReportDamagePage, build, _continuar, initState (+8 more)

### Community 39 - "report_location_page.dart"
Cohesion: 0.08
Nodes (24): createState, _fecha, icon, label, lista, _locating, _MapCard, onTap (+16 more)

### Community 40 - "login_page.dart"
Cohesion: 0.10
Nodes (19): ../../../../core/biometric/presentation/providers/biometric_providers.dart, _autoIntentado, _biometricDisponible, _BotonBiometrico, createState, dispose, _emailController, _Footer (+11 more)

### Community 41 - "register_page.dart"
Cohesion: 0.11
Nodes (17): FormState, createState, dispose, _emailController, _formKey, _goToLogin, _Header, isLoading (+9 more)

### Community 42 - "auth_local_datasource.dart"
Cohesion: 0.15
Nodes (13): ../../../../core/constants/storage_keys.dart, ../../../../../core/services/secure_storage_service.dart, ../../domain/entities/auth_session.dart, ../../domain/entities/user_role.dart, ../dtos/auth_response_dto.dart, AuthLocalDataSource, AuthLocalDataSourceImpl, cacheSession (+5 more)

### Community 43 - "report_vehicle_page.dart"
Cohesion: 0.10
Nodes (20): Acciones del Frontend, Credencial INE (Instituto Nacional Electoral), Código de Respuesta HTTP, Ejemplo de Captura Correcta, Ejemplo de Captura Correcta, Errores Comunes que Rechazan el Documento, Errores Comunes que Rechazan la Imagen, Especificaciones Físicas (+12 more)

### Community 44 - "report_damage_page.dart"
Cohesion: 0.13
Nodes (14): _AddTile, _CaptureCard, color, error, evidencia, icon, onRemove, onTap (+6 more)

### Community 45 - "app_spacing.dart"
Cohesion: 0.14
Nodes (13): AppSpacing, lg, md, radiusLg, radiusMd, radiusSm, radiusXl, sm (+5 more)

### Community 46 - "build"
Cohesion: 0.16
Nodes (16): build, OnboardingPage, _OnboardingPageState, build, onboardingControllerProvider, build, build, build (+8 more)

### Community 47 - "report_analysis_page.dart"
Cohesion: 0.09
Nodes (20): ../../../../core/routes/route_paths.dart, ocrRoutes, authRoutes, _AdjusterNote, _AnalysisCard, danoInterno, fotosValidas, label (+12 more)

### Community 48 - "report_narration_page.dart"
Cohesion: 0.11
Nodes (17): dart:convert, _decrypt, deleteAll, disable, _encrypt, getDecryptedPassword, getEmail, _getOrCreateKey (+9 more)

### Community 49 - "../../../../core/theme/app_colors.dart"
Cohesion: 0.09
Nodes (21): createState, _EmptyState, _ErrorState, _filtrar, _Header, initState, mensaje, nombre (+13 more)

### Community 50 - "ConsumerState"
Cohesion: 0.19
Nodes (13): ConsumerState, ConsumerStatefulWidget, locationServiceProvider, CasosAsignadosPage, _CasosAsignadosPageState, ProfilePage, _ProfilePageState, RegisterPage (+5 more)

### Community 51 - "_ClientHomePageState"
Cohesion: 0.21
Nodes (14): biometricRepositoryProvider, biometricServiceProvider, changePasswordProvider, secureStorageProvider, _autenticarConBiometria, LoginPage, _LoginPageState, _revisarBiometria (+6 more)

### Community 52 - "peritaje_remote_datasource.dart"
Cohesion: 0.14
Nodes (14): ../../dtos/ajustador_response_dto.dart, ../dtos/peritaje_upsert_dto.dart, agregarDano, _dio, editarPeritaje, _ensureSuccess, getAsignados, obtenerDetalleSiniestro (+6 more)

### Community 53 - "wWinMain"
Cohesion: 0.24
Nodes (9): _In_, _In_opt_, vector, wWinMain(), string, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments() (+1 more)

### Community 54 - "ajustador_response_dto.dart"
Cohesion: 0.17
Nodes (11): activoParaServicio, AjustadorResponseDto, cedulaProfesional, createdAt, deletedAt, fromJson, geolocalizacionActual, id (+3 more)

### Community 55 - "peritaje.dart"
Cohesion: 0.18
Nodes (10): damage_adjusted.dart, ajustadorId, costoDefinitivoAjustador, createdAt, danos, id, observacionesCampo, Peritaje (+2 more)

### Community 56 - "peritaje_mapper.dart"
Cohesion: 0.10
Nodes (20): ocrRepositoryProvider, addCapture, build, captureFor, captures, copyWith, errorMessage, extraction (+12 more)

### Community 57 - "currentSessionProvider"
Cohesion: 0.22
Nodes (11): currentSessionProvider, build, _confirmar, build, PeritajeConfirmadoPage, build, ValidacionPeritajePage, peritajeEditorControllerProvider (+3 more)

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
Cohesion: 0.13
Nodes (14): fechaSiniestro, indicacionesDanoInterno, latitud, longitud, narracionAudioUrl, narracionTexto, SiniestroInicializarDto, toJson (+6 more)

### Community 63 - "siniestro_card.dart"
Cohesion: 0.12
Nodes (15): core/routes/app_router.dart, core/security/domain/entities/security_status.dart, core/security/presentation/pages/blocked_page.dart, core/security/presentation/providers/security_providers.dart, core/theme/app_theme.dart, ../../../../core/theme/theme_notifier.dart, _blockedApp, createState (+7 more)

### Community 64 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 65 - "ConsumerWidget"
Cohesion: 0.18
Nodes (14): ConsumerWidget, ocrControllerProvider, _confirm, build, DocumentTypePage, _submit, build, OcrResultPage (+6 more)

### Community 66 - "dano_ajustado.dart"
Cohesion: 0.12
Nodes (15): build, controller, createState, enabled, hintText, keyboardType, label, obscure (+7 more)

### Community 67 - "get_perfil_cliente.dart"
Cohesion: 0.22
Nodes (8): ../entities/perfil_cliente.dart, ClienteRepositoryImpl, ClienteRepository, obtenerPerfil, call, GetPerfilCliente, _repository, ../repositories/cliente_repository.dart

### Community 68 - "authControllerProvider"
Cohesion: 0.22
Nodes (9): create, build, _submit, _confirmarLogout, build, _submit, authControllerProvider, _confirmLogout (+1 more)

### Community 69 - "dano_ajustado_dto.dart"
Cohesion: 0.14
Nodes (12): ../../domain/repositories/security_repository.dart, ../../domain/services/device_inspector.dart, ../entities/security_status.dart, check, _inspector, SecurityRepositoryImpl, check, SecurityRepository (+4 more)

### Community 70 - "casosAsignadosProvider"
Cohesion: 0.31
Nodes (6): DeviceInspectorPlugin, FlutterEngine, register(), Boolean, Context, MethodChannel

### Community 71 - "onboarding_data.dart"
Cohesion: 0.20
Nodes (9): avisoPrivacidad, biometria, ConsentData, copyWith, curpRfc, numeroPoliza, OnboardingData, transferenciaTalleres (+1 more)

### Community 72 - "perfil_cliente.dart"
Cohesion: 0.20
Nodes (9): autorizaTransferenciaTalleres, consentimientoAvisoPrivacidad, consentimientoBiometria, fechaConsentimiento, id, numeroPoliza, PerfilCliente, usuarioId (+1 more)

### Community 73 - "package:flutter/material.dart"
Cohesion: 0.07
Nodes (28): ../../core/theme/app_colors.dart, AppTypography, AjustadorBottomNav, build, currentIndex, onTap, build, ClaimVisionBottomNav (+20 more)

### Community 74 - "cliente_remote_datasource.dart"
Cohesion: 0.25
Nodes (8): ../../../../../core/constants/api_constants.dart, ../../../../../core/network/api_error_mapper.dart, ../../dtos/cliente_response_dto.dart, ClienteRemoteDataSource, ClienteRemoteDataSourceImpl, _dio, _ensureSuccess, obtenerPerfil

### Community 75 - "List"
Cohesion: 0.25
Nodes (7): damage_adjusted_dto.dart, costoDefinitivoAjustador, danos, firmaDigitalAjustador, observacionesCampo, PeritajeUpsertDto, toJson

### Community 76 - "validators.dart"
Cohesion: 0.22
Nodes (8): email, _emailRegex, fullName, newPassword, password, requiredField, Validators, static final RegExp

### Community 77 - "DateTime"
Cohesion: 0.25
Nodes (7): DateTime, createdAt, esCalidadValida, id, ImagenSiniestro, imagenUrl, siniestroId

### Community 78 - "storage_keys.dart"
Cohesion: 0.15
Nodes (12): aseguradoraId, biometricEmail, biometricEnabled, biometricPassword, email, primerInicioPara, rol, StorageKeys (+4 more)

### Community 79 - "ReportController"
Cohesion: 0.10
Nodes (19): ../../../../core/errors/exceptions.dart, ../../../../core/errors/failures.dart, ../datasources/remote/cliente_remote_datasource.dart, ../datasources/remote/siniestro_remote_datasource.dart, ../../domain/entities/imagen_siniestro.dart, ../../domain/entities/perfil_cliente.dart, ../../domain/entities/vehiculo_cliente.dart, ../../domain/repositories/cliente_repository.dart (+11 more)

### Community 80 - "notificaciones_ajustador_provider.dart"
Cohesion: 0.22
Nodes (9): ThemeModeNotifier, build, marcarLeida, marcarLeidas, NotificacionesAjustadorController, NotificacionesController, Notifier, Set (+1 more)

### Community 81 - "auth_response_dto.dart"
Cohesion: 0.25
Nodes (7): aseguradoraId, AuthResponseDto, email, fromJson, rol, token, usuarioId

### Community 82 - "imagen_siniestro_response_dto.dart"
Cohesion: 0.25
Nodes (7): createdAt, esCalidadValida, fromJson, id, ImagenSiniestroResponseDto, imagenUrl, siniestroId

### Community 83 - "siniestro_repository.dart"
Cohesion: 0.40
Nodes (4): ../entities/imagen_siniestro.dart, call, _repository, SubirImagenSiniestro

### Community 84 - "app.dart"
Cohesion: 0.17
Nodes (11): clienteRoutes, ../pages/client_home_page.dart, ../pages/historial_page.dart, ../pages/notificaciones_page.dart, ../pages/report_analysis_page.dart, ../pages/report_damage_page.dart, ../pages/report_location_page.dart, ../pages/report_narration_page.dart (+3 more)

### Community 85 - "siniestro_mapper.dart"
Cohesion: 0.33
Nodes (5): ../../domain/entities/siniestro.dart, ../../domain/entities/siniestro_status.dart, ../dtos/siniestro_response_dto.dart, SiniestroMapper, toEntity

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
Cohesion: 0.29
Nodes (6): changePassword, getStoredSession, login, logout, register, verifySession

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
Cohesion: 0.20
Nodes (9): damage_severity.dart, damage_type.dart, copyWith, costoRealReparacion, DamageAdjusted, id, severidad, tipo (+1 more)

### Community 97 - "dano_tipo.dart"
Cohesion: 0.20
Nodes (9): costoRealReparacion, DamageAdjustedDto, fromJson, id, origenCambio, severidad, tipo, toJson (+1 more)

### Community 98 - "login_request_dto.dart"
Cohesion: 0.40
Nodes (4): email, LoginRequestDto, password, toJson

### Community 99 - "dependencies"
Cohesion: 0.22
Nodes (8): call, GetCasosAsignados, _repository, call, GetDetalleAjustador, _repository, package:claimvision/shared/domain/entities/siniestro.dart, ../repositories/peritaje_repository.dart

### Community 100 - "MainActivity"
Cohesion: 0.40
Nodes (3): FlutterEngine, MainActivity, FlutterActivity

### Community 101 - "ChangeNotifier"
Cohesion: 0.15
Nodes (14): File, imageValidatorProvider, build, createState, dispose, DocumentCapturePage, _DocumentCapturePageState, documentType (+6 more)

### Community 103 - "graphify.js"
Cohesion: 0.15
Nodes (14): vehiculosClienteProvider, build, _continuar, createState, _hayProgreso, initState, onTap, ReportVehiclePage (+6 more)

### Community 116 - "biometric_repository_impl.dart"
Cohesion: 0.09
Nodes (21): ../../data/datasources/biometric_local_datasource.dart, ../../data/repositories/biometric_repository_impl.dart, ../datasources/biometric_local_datasource.dart, ../../domain/entities/biometric_credentials.dart, ../../domain/repositories/biometric_repository.dart, ../entities/biometric_credentials.dart, BiometricLocalDataSource, BiometricRepositoryImpl (+13 more)

### Community 117 - "biometric_repository.dart"
Cohesion: 0.16
Nodes (12): ../../domain/document_type.dart, double get, brightnessMax, brightnessMin, DocumentType, DocumentTypeX, build, CaptureOverlay (+4 more)

### Community 118 - "secure_storage_service.dart"
Cohesion: 0.22
Nodes (8): FlutterSecureStorage, clearSession, delete, read, SecureStorageService, _storage, write, _FakeSecureStorage

### Community 119 - "_ToastWidgetState"
Cohesion: 0.28
Nodes (9): _DanoForm, _DanoFormState, AppTextField, _AppTextFieldState, _ToastWidget, _ToastWidgetState, SingleTickerProviderStateMixin, State (+1 more)

### Community 120 - "vehiculo_response_dto.dart"
Cohesion: 0.22
Nodes (8): anio, fromJson, id, marca, modelo, placas, VehiculoResponseDto, vin

### Community 121 - "security_providers.dart"
Cohesion: 0.32
Nodes (7): AsyncNotifier, ../../../di/providers.dart, ../../domain/entities/security_status.dart, securityRepositoryProvider, build, recheck, SecurityController

### Community 122 - "dio_client.dart"
Cohesion: 0.25
Nodes (7): ../constants/api_constants.dart, ../constants/storage_keys.dart, create, DioClient, _skipAuthBounce, ../services/secure_storage_service.dart, static const Set

### Community 123 - "theme_notifier.dart"
Cohesion: 0.25
Nodes (7): build, _fromString, _load, setThemeMode, _storage, _toString, package:flutter_secure_storage/flutter_secure_storage.dart

### Community 124 - "api_error_mapper.dart"
Cohesion: 0.13
Nodes (14): datasources/ocr_remote_datasource.dart, Dio, ../domain/ocr_extraction.dart, ../domain/ocr_repository.dart, _dio, extractOcr, OcrRemoteDataSource, _datasource (+6 more)

### Community 125 - "biometric_service.dart"
Cohesion: 0.25
Nodes (7): _auth, authenticate, BiometricService, canCheckBiometrics, getAvailableBiometrics, LocalAuthentication, package:local_auth/local_auth.dart

### Community 126 - "auth_session.dart"
Cohesion: 0.25
Nodes (7): aseguradoraId, copyWith, email, rol, token, usuarioId, user_role.dart

### Community 127 - "List"
Cohesion: 0.25
Nodes (7): data, fromJson, page, PageDto, pageSize, total, List

### Community 128 - "bool get"
Cohesion: 0.14
Nodes (12): bool get, apiValue, fromApi, isAjustador, isCliente, UserRole, apiValue, enProceso (+4 more)

### Community 129 - "siniestro_repository.dart"
Cohesion: 0.29
Nodes (6): ../entities/vehiculo_cliente.dart, crear, listar, obtener, obtenerVehiculos, subirImagen

### Community 130 - "Cambios P0 — ClaimVision Backend"
Cohesion: 0.29
Nodes (6): Archivos EXISTENTES modificados (11) — todos compatibles hacia atrás, Archivos NUEVOS creados (no tocan nada existente), Cambios P0 — ClaimVision Backend, Conflicto importante que resolví (no es ruptura, es corrección), Cómo verificar que nada se rompió, TL;DR — respuesta a las 3 preguntas

### Community 131 - "OnboardingController"
Cohesion: 0.33
Nodes (7): confirmOnboardingProvider, extractPolicyDataProvider, sendConsentProvider, confirm, OnboardingController, OnboardingState, runOcr

### Community 132 - "security_status.dart"
Cohesion: 0.43
Nodes (6): issues, SecurityCompromised, SecurityIssue, SecurityLoading, SecurityOk, SecurityStatus

### Community 133 - "device_inspector_service.dart"
Cohesion: 0.15
Nodes (11): BlockedPage, build, _iconoIssue, issues, _mensajeIssue, _channel, inspect, package:flutter/services.dart (+3 more)

### Community 134 - "siniestro_status.dart"
Cohesion: 0.20
Nodes (9): dart:math, _computeBrightness, _computeSharpness, _laplacian3x3, validate, ../ocr/domain/document_type.dart, ../ocr/domain/image_quality.dart, ../ocr/domain/image_validator.dart (+1 more)

### Community 135 - "../../../../core/di/providers.dart"
Cohesion: 0.40
Nodes (5): ../../../../core/di/providers.dart, getSiniestrosClienteProvider, build, MisSiniestrosController, refrescar

### Community 136 - "biometric_providers.dart"
Cohesion: 0.24
Nodes (10): build, CasoDetallePage, build, build, NotificacionesAjustadorPage, casosAsignadosControllerProvider, notificacionesAjustadorControllerProvider, RoutePaths.casoDetalleDe (+2 more)

### Community 137 - "auth_mapper.dart"
Cohesion: 0.22
Nodes (8): aspectRatio, brightness, checkErrors, height, ImageQuality, passesMinimum, sharpness, width

### Community 138 - "blocked_page.dart"
Cohesion: 0.25
Nodes (6): dart:io, extract, confirmOnboarding, extractPolicyData, sendConsent, ocr_extraction.dart

### Community 139 - "onboardingControllerProvider"
Cohesion: 0.25
Nodes (7): ImagePicker, fromCamera, fromGallery, ImagePickerService, _pick, _picker, package:image_picker/image_picker.dart

### Community 140 - "get_perfil_ajustador.dart"
Cohesion: 0.40
Nodes (4): ../entities/perfil_ajustador.dart, call, GetPerfilAjustador, _repository

### Community 141 - "biometric_auth_service.dart"
Cohesion: 0.40
Nodes (4): authenticate, BiometricAuthService, canCheckBiometrics, getAvailableBiometrics

### Community 142 - "casos_asignados_controller.dart"
Cohesion: 0.60
Nodes (4): getCasosAsignadosProvider, build, CasosAsignadosController, refrescar

### Community 143 - "damage_severity.dart"
Cohesion: 0.40
Nodes (4): apiValue, DamageSeverity, fromApi, label

### Community 144 - "damage_type.dart"
Cohesion: 0.40
Nodes (4): apiValue, DamageType, fromApi, label

### Community 145 - "change_password_request_dto.dart"
Cohesion: 0.40
Nodes (4): ChangePasswordRequestDto, newPassword, oldPassword, toJson

### Community 146 - "biometric_credentials.dart"
Cohesion: 0.50
Nodes (3): BiometricCredentials, email, encryptedPassword

### Community 147 - "ajustador_routes.dart"
Cohesion: 0.25
Nodes (7): ajustadorRoutes, ../pages/caso_detalle_page.dart, ../pages/casos_asignados_page.dart, ../pages/firma_peritaje_page.dart, ../pages/notificaciones_ajustador_page.dart, ../pages/peritaje_confirmado_page.dart, ../pages/validacion_peritaje_page.dart

### Community 148 - "validation_indicator.dart"
Cohesion: 0.29
Nodes (6): ../../domain/image_quality.dart, build, _line, quality, type, ValidationIndicator

### Community 149 - "_ClaimVisionAppState"
Cohesion: 0.33
Nodes (7): build, ClaimVisionApp, _ClaimVisionAppState, didChangeAppLifecycleState, securityControllerProvider, themeModeProvider, WidgetsBindingObserver

### Community 150 - "image_validator.dart"
Cohesion: 0.33
Nodes (5): document_type.dart, image_quality.dart, ImageValidator, validate, ImageQualityService

### Community 151 - "ReportController"
Cohesion: 0.33
Nodes (6): inicializarSiniestroProvider, subirImagenSiniestroProvider, crearSiniestro, ReportController, ReportState, subirEvidencia

### Community 152 - "app_theme.dart"
Cohesion: 0.40
Nodes (4): app_colors.dart, app_spacing.dart, app_typography.dart, AppTheme

### Community 153 - "ChangeNotifier"
Cohesion: 0.67
Nodes (3): ChangeNotifier, _AuthRefreshNotifier, SignatureController

## Knowledge Gaps
- **1125 isolated node(s):** `recordToolUse.sh script`, `flutter_export_environment.sh script`, `+registerWithRegistry`, `router`, `createState` (+1120 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **7 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `OcrExtraction` connect `siniestro_update_dto.dart` to `peritaje_mapper.dart`?**
  _High betweenness centrality (0.033) - this node is a cross-community bridge._
- **Why does `AuthRepository` connect `AuthRepository` to `providers.dart`, `auth_repository.dart`?**
  _High betweenness centrality (0.014) - this node is a cross-community bridge._
- **Why does `Siniestro` connect `caso_card.dart` to `VoidCallback`, `report_controller.dart`, `peritaje_editor_provider.dart`, `report_analysis_page.dart`, `siniestro.dart`, `../../../../core/theme/app_colors.dart`, `siniestro_detail_page.dart`?**
  _High betweenness centrality (0.011) - this node is a cross-community bridge._
- **What connects `recordToolUse.sh script`, `Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.`, `flutter_export_environment.sh script` to the rest of the system?**
  _1126 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Win32Window` be split into smaller, more focused modules?**
  _Cohesion score 0.0597567424643046 - nodes in this community are weakly interconnected._
- **Should `providers.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.030303030303030304 - nodes in this community are weakly interconnected._
- **Should `app_toast.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.09090909090909091 - nodes in this community are weakly interconnected._