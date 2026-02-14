import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/sky_screen_enchanced.dart'; // UPDATED: Use enhanced version
import '../screens/hydration_screen.dart';
import '../screens/air_screen.dart';
import '../screens/events_screen_enchanced.dart';
import '../earthquake_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    SkyScreenEnhanced(), // UPDATED: Use enhanced version with hamburger menu
    HydrationPage(),
    AirScreen(),
    EarthquakePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF395886),
          unselectedItemColor: Colors.black54,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.wb_sunny_outlined),
              activeIcon: Icon(Icons.wb_sunny),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.nights_stay_outlined),
              activeIcon: Icon(Icons.nights_stay),
              label: 'Sky',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                  Icons.water_drop_outlined), // CHANGED: public → water_drop
              activeIcon: Icon(Icons.water_drop),
              label: 'Water', // CHANGED: Earth → Water
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.air_outlined),
              activeIcon: Icon(Icons.air),
              label: 'Air',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_outlined),
              activeIcon: Icon(Icons.event),
              label: 'Disaster',
            ),
          ],
        ),
      ),
    );
  }
}
