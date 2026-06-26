import 'package:claimvision/app.dart';
import 'package:claimvision/core/di/providers.dart';
import 'package:claimvision/core/services/secure_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

/// Almacenamiento falso (sin plugins nativos): siempre devuelve "sin sesión".
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

void main() {
  testWidgets('Sin sesión guardada, la app muestra el inicio de sesión',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          secureStorageProvider.overrideWithValue(_FakeSecureStorage()),
        ],
        child: const ClaimVisionApp(),
      ),
    );

    // Restaura sesión (null) → el router redirige al login.
    await tester.pumpAndSettle();

    expect(find.text('Iniciar Sesión'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
