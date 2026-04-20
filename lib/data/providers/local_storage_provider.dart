// lib/data/providers/local_storage_provider.dart

import 'package:get_storage/get_storage.dart';

class LocalStorageProvider {
  final GetStorage _box = GetStorage();

  // ---------- WRITE ----------
  Future<void> write(String key, dynamic value) async {
    await _box.write(key, value);
  }

  // ---------- READ ----------
  T? read<T>(String key) {
    return _box.read<T>(key);
  }

  // ---------- REMOVE ----------
  Future<void> remove(String key) async {
    await _box.remove(key);
  }

  // ---------- CLEAR ALL ----------
  Future<void> clear() async {
    await _box.erase();
  }

  // ---------- CHECK KEY ----------
  bool hasKey(String key) {
    return _box.hasData(key);
  }

  // ---------- LIST KEYS ----------
  Iterable<String> getKeys() {
    return _box.getKeys();
  }
}