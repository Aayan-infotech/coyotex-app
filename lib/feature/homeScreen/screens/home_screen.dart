import 'package:coyotex/feature/homeScreen/screens/pages/home_page.dart';
import 'package:coyotex/feature/map/data/trip_model.dart';
import 'package:coyotex/feature/map/presentation/map.dart';
import 'package:coyotex/feature/map/presentation/notofication_screen.dart';
import 'package:coyotex/feature/trip/presentation/trip_history.dart';
import 'package:coyotex/feature/profile/presentation/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late Key _mapKey; // Key to force rebuild MapScreen

  @override
  void initState() {
    super.initState();
    _mapKey = UniqueKey(); // Initialize key
  }

  List<Widget> get _pages => [
        HomePage(),
        MapScreen(key: _mapKey), // Use the key here
        TripsHistoryScreen(),
        ProfileScreen(),
      ];

  void _onItemTapped(int index) {
    if (index == 1) {
      // Check if Map tab is selected
      setState(() {
        _mapKey = UniqueKey(); // Generate new key to rebuild MapScreen
      });
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(0.0),
            topRight: Radius.circular(0.0),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
