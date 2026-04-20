import 'package:flutter/material.dart';

import '../../dashboard/views/dashboard_view.dart';
import '../../progress/views/progress_view.dart';
import '../../publication/views/upload_material_view.dart';
import '../../collaborative/views/study_groups_view.dart';
import '../../profile/views/profile_view.dart';
import '../../assignment/views/assignment_view.dart'; // 🔥 ADD THIS

import '../../../widgets/bottom_nav_bar.dart';
class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  int currentIndex = 0;

  /// 🔥 UPDATED PAGES LIST
  final List<Widget> pages = const [
    DashboardView(),
    ProgressView(),
    AssignmentView(),        // 🔥 NEW
    UploadMaterialView(),
    StudyGroupsView(),
    ProfileView(),
  ];

  void changePage(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,
        onTap: changePage,
      ),
    );
  }
}