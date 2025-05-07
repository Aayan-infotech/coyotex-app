import 'package:cached_network_image/cached_network_image.dart';
import 'package:coyotex/core/utills/constant.dart';
import 'package:coyotex/feature/map/data/trip_model.dart';
import 'package:coyotex/feature/map/presentation/notofication_screen.dart';
import 'package:coyotex/feature/trip/presentation/trip_details.dart';
import 'package:coyotex/feature/map/view_model/map_provider.dart';
import 'package:coyotex/feature/trip/view_model/trip_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class TripsHistoryScreen extends StatefulWidget {
  const TripsHistoryScreen({super.key});

  @override
  _TripsHistoryScreenState createState() => _TripsHistoryScreenState();
}

class _TripsHistoryScreenState extends State<TripsHistoryScreen> {
  int selectedTab = 0;
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  List<TripModel> trips = [];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<MapProvider, TripViewModel>(
      // Listen to both MapProvider and TripViewModel
      builder: (context, mapProvider, tripViewModel, child) {
        // Call the search method when the search query changes
        if (searchQuery.isNotEmpty) {
          _searchTrips(tripViewModel, searchQuery);
        } else {
          trips = _filterTripsByDate(mapProvider.trips);
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              'Your Trips',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
            centerTitle: true,
            actions: [
              GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return const NotificationScreen();
                    }));
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Icon(
                      Icons.notifications,
                      color: Colors.red,
                      size: 25,
                    ),
                  )),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search trips...',
                    hintStyle: const TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white70),
                      onPressed: () {
                        setState(() {
                          searchController.clear();
                          searchQuery = "";
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.grey[850],
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
              ),
            ),
          ),
          body: Container(
            color: Colors.black,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Stay on top of your hunting adventures with our all-in-one tracking app!',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                _buildTabBar(),
                const SizedBox(height: 16),
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
                      final trip = trips[trips.length - 1 - index];
                      return GestureDetector(
                        onTap: () {
                          mapProvider.selectedTripModel = trip;
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return TripDetailsScreen(tripModel: trip);
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

  // This method will fetch the trips from the server based on the search query.
  Future<void> _searchTrips(TripViewModel tripViewModel, String query) async {
    try {
      var response = await tripViewModel.searchTrip(
          query, 1, 20); // Example with page 1 and limit 20
      if (response.success && response.data["trips"] is List) {
        var tripList = response.data["trips"] as List; // Explicit casting
        trips = tripList
            .map((e) => TripModel.fromJson(e as Map<String, dynamic>))
            .toList();
        // print(trips);
        setState(() {});
      } else {
        setState(() {
          trips = [];
        });
      }
    } catch (e) {
      setState(() {
        trips = [];
      });
    }
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
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                .isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
            trip.createdAt.isBefore(now.add(const Duration(days: 1)));
      } else if (selectedTab == 1) {
        return trip.createdAt
                .isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
            trip.createdAt.isBefore(now.add(const Duration(days: 1)));
      } else if (selectedTab == 2) {
        return trip.createdAt
                .isAfter(startOfYear.subtract(const Duration(days: 1))) &&
            trip.createdAt.isBefore(now.add(const Duration(days: 1)));
      }
      return false;
    }).toList();
  }

  Widget _buildTripCard(TripModel trip) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[850],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                  //imageUrl: trip.images.isNotEmpty ? trip.images.first : '',
                  imageUrl: (trip.markers.isNotEmpty &&
                          trip.markers.first.media != null &&
                          trip.markers.first.media!.isNotEmpty)
                      ? trip.markers.first.media!.firstWhere(
                          (media) => media.isNotEmpty && !checkIfVideo(media),
                          orElse: () =>
                              '', // Return an empty string if no valid image is found
                        )
                      : '',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator.adaptive(
                        backgroundColor: Colors.white,
                      )),
                  errorWidget: (context, url, error) => ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          "assets/images/coyotex_place_holder.jpg",
                          width: 50,
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                      )),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: const BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Text(
                  trip.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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
