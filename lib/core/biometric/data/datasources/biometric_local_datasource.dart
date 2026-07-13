import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt_lib;

import '../../../services/secure_storage_service.dart';

class BiometricLocalDataSource {
  final SecureStorageService _storage;

  BiometricLocalDataSource(this._storage);

  static const _keyEnabled = 'cv_biometric_enabled';
  static const _keyEmail = 'cv_biometric_email';
  static const _keyEncryptedPwd = 'cv_biometric_password';
  static const _keyAesKey = 'cv_biometric_aes_key';
  static const _keyAesIv = 'cv_biometric_aes_iv';

  Future<bool> isEnabled() async {
    final v = await _storage.read(_keyEnabled);
    return v == 'true';
  }

  Future<void> save({
    required String email,
    required String password,
  }) async {
    final key = await _getOrCreateKey();
    final encrypted = _encrypt(password, key);
    await _storage.write(_keyEnabled, 'true');
    await _storage.write(_keyEmail, email);
    await _storage.write(_keyEncryptedPwd, encrypted);
  }

  Future<String?> getEmail() async {
    return _storage.read(_keyEmail);
  }

  Future<String?> getDecryptedPassword() async {
    final raw = await _storage.read(_keyEncryptedPwd);
    if (raw == null) return null;
    final key = await _getOrCreateKey();
    return _decrypt(raw, key);
  }

  Future<void> deleteAll() async {
    await _storage.delete(_keyEnabled);
    await _storage.delete(_keyEmail);
    await _storage.delete(_keyEncryptedPwd);
    await _storage.delete(_keyAesKey);
    await _storage.delete(_keyAesIv);
  }

  Future<void> disable() async {
    await _storage.delete(_keyEnabled);
    await _storage.delete(_keyEmail);
    await _storage.delete(_keyEncryptedPwd);
  }

  Future<encrypt_lib.Key> _getOrCreateKey() async {
    final rawKey = await _storage.read(_keyAesKey);
    final rawIv = await _storage.read(_keyAesIv);

    if (rawKey == null || rawIv == null) {
      final newKey = encrypt_lib.Key.fromSecureRandom(32);
      final newIv = encrypt_lib.IV.fromSecureRandom(16);
      await _storage.write(_keyAesKey, newKey.base64);
      await _storage.write(_keyAesIv, newIv.base64);
      return newKey;
    }

    return encrypt_lib.Key.fromBase64(rawKey);
  }

  String _encrypt(String plaintext, encrypt_lib.Key key) {
    final iv = encrypt_lib.IV.fromSecureRandom(16);
    final encrypter = encrypt_lib.Encrypter(encrypt_lib.AES(key, mode: encrypt_lib.AESMode.cbc));
    final encrypted = encrypter.encrypt(plaintext, iv: iv);
    final combined = utf8.encode(iv.base64) + [0] + utf8.encode(encrypted.base64);
    return base64Encode(combined);
  }

  String? _decrypt(String ciphertext, encrypt_lib.Key key) {
    try {
      final combined = base64Decode(ciphertext);
      final separator = combined.indexOf(0);
      if (separator == -1) return null;
      final ivB64 = utf8.decode(combined.sublist(0, separator));
      final dataB64 = utf8.decode(combined.sublist(separator + 1));
      final iv = encrypt_lib.IV.fromBase64(ivB64);
      final encrypter = encrypt_lib.Encrypter(encrypt_lib.AES(key, mode: encrypt_lib.AESMode.cbc));
      return encrypter.decrypt64(dataB64, iv: iv);
    } catch (_) {
      return null;
    }
  }
}
