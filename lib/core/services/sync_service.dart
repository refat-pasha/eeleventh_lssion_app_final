import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../data/providers/local_storage_provider.dart';
import '../../data/providers/firebase_provider.dart';
import '../constants/storage_keys.dart';

/// SyncService (FR-4 REQ-5)
///
/// Queues offline actions in local storage and replays them against Firestore
/// when connectivity is restored. Uses a lightweight Firestore probe (with a
/// short timeout) to detect connectivity without adding extra packages.
///
/// Action shape stored in the queue:
///   { type: 'material_view' | 'quiz_attempt' | 'assignment_submission',
///     payload: {...}, createdAt: iso-string }
class SyncService extends GetxService {
  final LocalStorageProvider _storage = LocalStorageProvider();
  final FirebaseProvider _fb = FirebaseProvider();

  final RxBool isOnline = false.obs;
  final RxBool isSyncing = false.obs;
  final RxInt pendingCount = 0.obs;

  Timer? _poll;

  @override
  void onInit() {
    super.onInit();
    _refreshPendingCount();
    // Poll every 30s: check connectivity, flush queue if online.
    _poll = Timer.periodic(const Duration(seconds: 30), (_) => tryFlush());
    // First try immediately.
    tryFlush();
  }

  @override
  void onClose() {
    _poll?.cancel();
    super.onClose();
  }

  /// ============ QUEUE API ============
  Future<void> enqueue(String type, Map<String, dynamic> payload) async {
    final queue = _readQueue();
    queue.add({
      'type': type,
      'payload': payload,
      'createdAt': DateTime.now().toIso8601String(),
    });
    await _storage.write(StorageKeys.pendingSyncQueue, queue);
    pendingCount.value = queue.length;
  }

  List<Map<String, dynamic>> _readQueue() {
    final raw = _storage.read<List>(StorageKeys.pendingSyncQueue);
    if (raw == null) return <Map<String, dynamic>>[];
    return raw
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> _writeQueue(List<Map<String, dynamic>> q) async {
    await _storage.write(StorageKeys.pendingSyncQueue, q);
    pendingCount.value = q.length;
  }

  void _refreshPendingCount() {
    pendingCount.value = _readQueue().length;
  }

  /// ============ CONNECTIVITY ============
  Future<bool> checkOnline() async {
    try {
      // Lightweight probe: read a single doc with a short timeout.
      await _fb.firestore
          .collection('_health')
          .doc('probe')
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 4));
      isOnline.value = true;
      return true;
    } catch (_) {
      isOnline.value = false;
      return false;
    }
  }

  /// ============ FLUSH ============
  Future<void> tryFlush() async {
    if (isSyncing.value) return;
    final queue = _readQueue();
    if (queue.isEmpty) {
      pendingCount.value = 0;
      return;
    }
    final online = await checkOnline();
    if (!online) return;

    isSyncing.value = true;
    final remaining = <Map<String, dynamic>>[];

    for (final item in queue) {
      final success = await _replay(item);
      if (!success) remaining.add(item);
    }

    await _writeQueue(remaining);
    await _storage.write(
        StorageKeys.lastSyncAt, DateTime.now().toIso8601String());
    isSyncing.value = false;
  }

  Future<bool> _replay(Map<String, dynamic> item) async {
    try {
      final type = item['type']?.toString() ?? '';
      final payload = Map<String, dynamic>.from(item['payload'] ?? {});

      switch (type) {
        case 'material_view':
          await _fb.materialViews().add({
            ...payload,
            'viewedAt': FieldValue.serverTimestamp(),
            'syncedFromOffline': true,
          });
          return true;

        case 'quiz_attempt':
          await _fb.quizAttempts().add({
            ...payload,
            'submittedAt': FieldValue.serverTimestamp(),
            'syncedFromOffline': true,
          });
          return true;

        case 'assignment_submission':
          await _fb.assignmentSubmissions().add({
            ...payload,
            'submittedAt': FieldValue.serverTimestamp(),
            'syncedFromOffline': true,
          });
          return true;

        default:
          // Unknown type — drop it so the queue doesn't grow forever.
          return true;
      }
    } catch (_) {
      return false;
    }
  }

  DateTime? get lastSyncAt {
    final raw = _storage.read<String>(StorageKeys.lastSyncAt);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }
}
