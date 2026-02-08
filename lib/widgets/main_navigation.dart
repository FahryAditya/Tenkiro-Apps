import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/sky_screen.dart';
import '../screens/earth_screen.dart';
import '../screens/air_screen.dart';
import '../screens/events_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    SkyScreen(),
    EarthScreen(),
    AirScreen(),
    EventsScreen(),
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
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
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
                  icon: Icon(Icons.public_outlined),
                  activeIcon: Icon(Icons.public),
                  label: 'Earth',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.air_outlined),
                  activeIcon: Icon(Icons.air),
                  label: 'Air',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.event_outlined),
                  activeIcon: Icon(Icons.event),
                  label: 'Events',
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 4.0),
              child: Text(
                'Haruxa Fahry Aditya',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*
 * © 2026 Haruxa. All rights reserved.
 * Author: Haruxa
 * Description: File ini bagian dari proyek aplikasi cuaca & astronomi.
 */
