// lib/modules/offline/controllers/offline_controller.dart

import 'package:get/get.dart';

import '../../../data/models/material_model.dart';
import '../../../data/providers/local_storage_provider.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/services/sync_service.dart';

class OfflineController extends GetxController {
  final LocalStorageProvider _storage = LocalStorageProvider();
  final SyncService syncService = Get.find<SyncService>();

  final RxList<MaterialModel> offlineMaterials = <MaterialModel>[].obs;
  final RxBool isLoading = false.obs;

  /// Triggers an immediate flush of the pending offline queue.
  Future<void> syncNow() async {
    await syncService.tryFlush();
  }

  /// Record a material view while offline; syncs when connection returns.
  Future<void> queueMaterialView({
    required String userId,
    required String courseId,
    required String materialId,
  }) async {
    await syncService.enqueue('material_view', {
      'userId': userId,
      'courseId': courseId,
      'materialId': materialId,
    });
  }

  @override
  void onInit() {
    loadOfflineMaterials();
    super.onInit();
  }

  void loadOfflineMaterials() {
    try {
      isLoading.value = true;

      final storedData = _storage.read<List>(StorageKeys.offlineMaterials);

      if (storedData != null) {
        final materials = storedData.map((item) {
          return MaterialModel.fromMap(
            Map<String, dynamic>.from(item),
            item['id'] ?? '',
          );
        }).toList();

        offlineMaterials.assignAll(materials);
      }
    } catch (e) {
      Get.snackbar("Offline Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveMaterialOffline(MaterialModel material) async {
    try {
      offlineMaterials.add(material);

      final data = offlineMaterials.map((m) {
        final map = m.toMap();
        map['id'] = m.id;
        return map;
      }).toList();

      await _storage.write(StorageKeys.offlineMaterials, data);
    } catch (e) {
      Get.snackbar("Save Failed", e.toString());
    }
  }

  Future<void> removeOfflineMaterial(String materialId) async {
    try {
      offlineMaterials.removeWhere((m) => m.id == materialId);

      final data = offlineMaterials.map((m) {
        final map = m.toMap();
        map['id'] = m.id;
        return map;
      }).toList();

      await _storage.write(StorageKeys.offlineMaterials, data);
    } catch (e) {
      Get.snackbar("Remove Failed", e.toString());
    }
  }
}