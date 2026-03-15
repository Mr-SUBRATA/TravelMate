import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:travel_Mate/features/bookmark/bookmarkPage.dart';
import 'package:travel_Mate/features/home/homepage.dart';
import 'package:travel_Mate/features/planning/plannerPage.dart';
import 'package:travel_Mate/features/user/profilePage.dart';
import 'package:travel_Mate/theme/app_theme.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _idx = 0;

  final _screens = const [
    Homepage(),
    PlannerScreen(),
    SavedScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color.fromARGB(0, 255, 255, 255).withOpacity(0),
      body: IndexedStack(index: _idx, children: _screens),
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(left: 16, right: 16, bottom: 20),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: context.wCard,
          borderRadius: BorderRadius.circular(75),
          border: Border(top: BorderSide(color: context.wBorder, width: 1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SizedBox(
          height: 70,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: GNav(
              backgroundColor: Colors.transparent,
              color: context.wTextSub,
              activeColor: const Color.fromARGB(255, 255, 209, 4),
              tabBackgroundColor: TravelMateColors.teal,
              tabBorderRadius: 25,
              gap: 8,

              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              selectedIndex: _idx,
              onTabChange: (i) => setState(() => _idx = i),
              tabs: const [
                GButton(icon: Icons.home_rounded, text: 'Home', iconSize: 22),
                GButton(
                  icon: Icons.map_outlined,
                  text: 'Planner',
                  iconSize: 22,
                ),
                GButton(
                  icon: Icons.bookmark_border_rounded,
                  text: 'Saved',
                  iconSize: 22,
                ),
                GButton(
                  icon: Icons.person_outline_rounded,
                  text: 'Profile',
                  iconSize: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
