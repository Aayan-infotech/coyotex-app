import 'package:coyotex/feature/homeScreen/screens/index_provider.dart';
import 'package:coyotex/feature/homeScreen/screens/pages/home_page.dart';
import 'package:coyotex/feature/map/data/trip_model.dart';
import 'package:coyotex/feature/map/presentation/map.dart';
import 'package:coyotex/feature/map/presentation/notofication_screen.dart';
import 'package:coyotex/feature/trip/presentation/trip_history.dart';
import 'package:coyotex/feature/profile/presentation/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final indexProvider = Provider.of<IndexProvider>(context);

    List<Widget> pages = [
      const HomePage(),
      MapScreen(key: indexProvider.mapKey),
      const TripsHistoryScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: IndexedStack(
        index: indexProvider.currentIndex,
        children: pages,
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
          currentIndex: indexProvider.currentIndex,
          onTap: (index) => indexProvider.updateIndex(index),
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
