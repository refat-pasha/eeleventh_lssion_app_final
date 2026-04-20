// placeholder
// lib/core/services/storage_service.dart

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StorageService extends GetxService {
  late GetStorage _box;

  Future<StorageService> init() async {
    await GetStorage.init();
    _box = GetStorage();
    return this;
  }

  // Write data
  Future<void> write(String key, dynamic value) async {
    await _box.write(key, value);
  }

  // Read data
  T? read<T>(String key) {
    return _box.read<T>(key);
  }

  // Remove specific key
  Future<void> remove(String key) async {
    await _box.remove(key);
  }

  // Clear all storage
  Future<void> clear() async {
    await _box.erase();
  }

  // Check if key exists
  bool hasKey(String key) {
    return _box.hasData(key);
  }
}