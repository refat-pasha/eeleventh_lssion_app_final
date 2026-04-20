import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/account_settings_controller.dart';

class AccountSettingsView extends GetView<AccountSettingsController> {
  const AccountSettingsView({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Account Settings")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(

          children: [

            TextField(
              controller: controller.nameController,
              decoration: const InputDecoration(
                labelText: "Name",
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: controller.ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Age",
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: controller.saveAccountSettings,
              child: const Text("Save"),
            )

          ],
        ),
      ),
    );
  }
}