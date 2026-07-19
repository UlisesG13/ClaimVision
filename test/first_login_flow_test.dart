import 'package:claimvision/app.dart';
import 'package:claimvision/core/biometric/domain/entities/biometric_credentials.dart';
import 'package:claimvision/core/biometric/domain/repositories/biometric_repository.dart';
import 'package:claimvision/core/biometric/presentation/providers/biometric_providers.dart';
import 'package:claimvision/core/di/providers.dart';
import 'package:claimvision/core/security/domain/entities/security_status.dart';
import 'package:claimvision/core/security/domain/services/device_inspector.dart';
import 'package:claimvision/core/services/biometric_service.dart';
import 'package:claimvision/core/services/secure_storage_service.dart';
import 'package:claimvision/features/auth/domain/entities/auth_session.dart';
import 'package:claimvision/features/auth/domain/entities/user_role.dart';
import 'package:claimvision/features/auth/domain/repositories/auth_repository.dart';
import 'package:claimvision/features/auth/domain/usecases/change_password.dart';
import 'package:claimvision/features/auth/presentation/state/onboarding_controller.dart';
import 'package:claimvision/features/cliente/presentation/state/mis_siniestros_controller.dart';
import 'package:claimvision/features/cliente/presentation/state/notificaciones_controller.dart';
import 'package:claimvision/features/cliente/presentation/state/report_controller.dart';
import 'package:claimvision/shared/domain/entities/siniestro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

final _session = AuthSession(
  token: 'test-token',
  usuarioId: 'test-user-123',
  email: 'test@cliente.com',
  rol: UserRole.cliente,
);

class _FakeSecureStorage extends SecureStorageService {
  _FakeSecureStorage() : super(const FlutterSecureStorage());

  @override
  Future<void> write(String key, String value) async {}

  @override
  Future<String?> read(String key) async => null;

  @override
  Future<void> delete(String key) async {}

  @override
  Future<void> clearSession() async {}
}

class _FakeDeviceInspector implements DeviceInspector {
  @override
  Future<SecurityStatus> inspect() async => const SecurityOk();
}

class _FakeBiometricService extends BiometricService {
  @override
  Future<bool> canCheckBiometrics() async => true;

  @override
  Future<bool> authenticate({String reason = ''}) async => true;
}

class _FakeBiometricRepository implements BiometricRepository {
  @override
  Future<bool> isEnabled() async => false;

  @override
  Future<void> enable({
    required String userId,
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> disable() async {}

  @override
  Future<BiometricCredentials?> getCredentials() async => null;

  @override
  Future<void> clearForUser(String userId) async {}
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<AuthSession?> getStoredSession() async => _session;

  @override
  Future<bool> verifySession() async => true;

  @override
  Future<void> logout() async {}

  @override
  Future<void> clearSession() async {}

  @override
  Future<void> saveSession(AuthSession session) async {}

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {}

  @override
  Future<void> deleteDeviceToken(String token) async {}

  @override
  Future<void> registerDeviceToken(String token) async {}

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) =>
      throw UnimplementedError();

  @override
  Future<AuthSession> register({
    required String nombre,
    required String email,
    required String password,
  }) =>
      throw UnimplementedError();
}

class _FakeMisSiniestrosController extends MisSiniestrosController {
  @override
  Future<List<Siniestro>> build() async => [];
}

class _FakeOnboardingController extends OnboardingController {
  @override
  OnboardingState build() => const OnboardingState();
}

class _FakeNotificacionesController extends NotificacionesController {
  @override
  Set<String> build() => {};
}

class _FakeReportController extends ReportController {
  @override
  ReportState build() => const ReportState();
}

Widget _buildTestApp() {
  return ProviderScope(
    overrides: [
      secureStorageProvider.overrideWithValue(_FakeSecureStorage()),
      deviceInspectorProvider.overrideWith((_) => _FakeDeviceInspector()),
      authRepositoryProvider.overrideWith((_) => _FakeAuthRepository()),
      misSiniestrosControllerProvider.overrideWith(
        () => _FakeMisSiniestrosController(),
      ),
      onboardingControllerProvider.overrideWith(
        () => _FakeOnboardingController(),
      ),
      notificacionesControllerProvider.overrideWith(
        () => _FakeNotificacionesController(),
      ),
      biometricServiceProvider.overrideWith((_) => _FakeBiometricService()),
      biometricRepositoryProvider.overrideWith((_) => _FakeBiometricRepository()),
      changePasswordProvider.overrideWith((_) =>
          ChangePassword(_FakeAuthRepository())),
      reportControllerProvider.overrideWith(() => _FakeReportController()),
    ],
    child: const ClaimVisionApp(),
  );
}

void main() {
  group('Flujo primer inicio (Omitir)', () {
    testWidgets('Omitir cambio de contraseña y biometrico "Ahora no"',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('Actualiza tu contraseña'), findsOneWidget);
      expect(find.text('Omitir'), findsOneWidget);

      await tester.tap(find.text('Omitir'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('¿Usar huella digital?'), findsOneWidget);
      expect(find.text('Ahora no'), findsOneWidget);

      await tester.tap(find.text('Ahora no'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'Omitir cambio de contraseña, activar huella y confirmar contraseña',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('Actualiza tu contraseña'), findsOneWidget);
      await tester.tap(find.text('Omitir'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('¿Usar huella digital?'), findsOneWidget);
      await tester.tap(find.text('Activar'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('Confirma tu contraseña'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Confirmar'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextField, 'Contraseña actual'),
        'mi-contrasena',
      );
      await tester.pump();

      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(tester.takeException(), isNull);
    });
  });
}
