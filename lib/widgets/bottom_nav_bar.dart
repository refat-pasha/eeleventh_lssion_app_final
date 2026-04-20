import 'package:flutter/material.dart';
import '../app/theme/colors.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AppColors.cardDark,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.white70,
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,

      /// 🔥 IMPORTANT: NOW 6 ITEMS (MATCH PAGES)
      items: const [

        /// 0
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),

        /// 1
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: "Progress",
        ),

        /// 2 🔥 NEW
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment),
          label: "Assignments",
        ),

        /// 3
        BottomNavigationBarItem(
          icon: Icon(Icons.upload),
          label: "Upload",
        ),

        /// 4
        BottomNavigationBarItem(
          icon: Icon(Icons.explore),
          label: "Discover",
        ),

        /// 5
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Profile",
        ),
      ],
    );
  }
}