import 'package:coyotex/feature/map/data/trip_model.dart';
import 'package:coyotex/feature/map/presentation/trip_details.dart';
import 'package:coyotex/feature/map/view_model/map_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class TripsHistoryScreen extends StatefulWidget {
  @override
  _TripsHistoryScreenState createState() => _TripsHistoryScreenState();
}

class _TripsHistoryScreenState extends State<TripsHistoryScreen> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<MapProvider>(
      builder: (context, mapProvider, child) {
        List<TripModel> trips = _filterTripsByDate(mapProvider.trips);

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text(
              'Trips History',
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
          ),
          body: Container(
            color: Colors.black,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 8),
                const Text(
                  'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                _buildTabBar(),
                SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 3 / 4,
                    ),
                    itemCount: trips.length,
                    itemBuilder: (context, index) {
                      final trip = trips[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return TripDetailsScreen();
                          }));
                        },
                        child: _buildTripCard(trip),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTab('Week', 0),
        _buildTab('Month', 1),
        _buildTab('Year', 2),
      ],
    );
  }

  Widget _buildTab(String label, int index) {
    bool isSelected = selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.black,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  List<TripModel> _filterTripsByDate(List<TripModel> trips) {
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    DateTime startOfYear = DateTime(now.year, 1, 1);

    return trips.where((trip) {
      if (selectedTab == 0) {
        return trip.createdAt
                .isAfter(startOfWeek.subtract(Duration(days: 1))) &&
            trip.createdAt.isBefore(now.add(Duration(days: 1)));
      } else if (selectedTab == 1) {
        return trip.createdAt
                .isAfter(startOfMonth.subtract(Duration(days: 1))) &&
            trip.createdAt.isBefore(now.add(Duration(days: 1)));
      } else if (selectedTab == 2) {
        return trip.createdAt
                .isAfter(startOfYear.subtract(Duration(days: 1))) &&
            trip.createdAt.isBefore(now.add(Duration(days: 1)));
      }
      return false;
    }).toList();
  }

  Widget _buildTripCard(TripModel trip) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[850],
        image: DecorationImage(
          image: NetworkImage(trip.images.isNotEmpty
              ? trip.images.first
              : 'assets/trip_placeholder.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.5),
            BlendMode.darken,
          ),
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 35, left: 5, right: 5),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                trip.name ?? 'Trip Name',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(height: 4),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 30,
              padding: EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Text(
                  'Trip ${trip.id}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
