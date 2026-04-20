// lib/modules/offline/views/offline_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/offline_controller.dart';

class OfflineView extends GetView<OfflineController> {
  const OfflineView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyMedium?.color;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Offline Materials"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Obx(() {
            final syncing = controller.syncService.isSyncing.value;
            return IconButton(
              tooltip: "Sync now",
              icon: syncing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync),
              onPressed: syncing ? null : controller.syncNow,
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            _syncBanner(cardColor, textColor),
            Expanded(
              child: controller.offlineMaterials.isEmpty
                  ? Center(
                      child: Text(
                        "No offline materials",
                        style: TextStyle(
                            color: textColor?.withValues(alpha: 0.7)),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.offlineMaterials.length,
                      itemBuilder: (context, index) {
                        final material = controller.offlineMaterials[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: [
                              const Icon(Icons.picture_as_pdf,
                                  color: Colors.redAccent, size: 30),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(material.title,
                                        style: TextStyle(
                                            color: textColor,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(material.description,
                                        style: TextStyle(
                                            color: textColor?.withValues(
                                                alpha: 0.7))),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => controller
                                    .removeOfflineMaterial(material.id),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }

  Widget _syncBanner(Color cardColor, Color? textColor) {
    return Obx(() {
      final online = controller.syncService.isOnline.value;
      final pending = controller.syncService.pendingCount.value;
      final lastSync = controller.syncService.lastSyncAt;
      final lastSyncStr = lastSync == null
          ? "never"
          : DateFormat('MMM d, HH:mm').format(lastSync);

      final bg = online
          ? Colors.green.withValues(alpha: 0.12)
          : Colors.orange.withValues(alpha: 0.12);
      final dot = online ? Colors.green : Colors.orange;
      final label = online ? "Online" : "Offline";

      return Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: dot.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "$label • $pending pending • last sync: $lastSyncStr",
                style: TextStyle(color: textColor, fontSize: 12),
              ),
            ),
          ],
        ),
      );
    });
  }
}
