import 'package:cached_network_image/cached_network_image.dart';
import 'package:coyotex/core/utills/branded_text_filed.dart';
import 'package:coyotex/core/utills/constant.dart';
import 'package:coyotex/feature/map/presentation/notofication_screen.dart';
import 'package:coyotex/feature/trip/presentation/trip_details.dart';
import 'package:coyotex/feature/trip/presentation/trip_history.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import '../../../../core/utills/notification.dart';
import '../../../map/view_model/map_provider.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      asyncInit();
    });

    super.initState();
  }

  asyncInit() async {
    final mapProvider = Provider.of<MapProvider>(context, listen: false);
    mapProvider.getCurrentLocation();
    mapProvider.getTrips();
    NotificationService.getDeviceToken();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scrollController.jumpTo(_scrollController.position.minScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MapProvider>(builder: (context, mapProvider, child) {
      print(mapProvider.weather);
      return Scaffold(
        backgroundColor: Colors.black,
        body: mapProvider.isLoading
            ? const Center(child: CircularProgressIndicator.adaptive())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo and Search Field
                      GestureDetector(
                        onTap: () {
                          NotificationService.getDeviceToken();
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 40.0), // Add top padding for spacing
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  width: 50,
                                  height: 50,
                                ),
                              ),
                              const Text(
                                'Welcome!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Spacer(),
                              GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
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
                          ),
                        ),
                      ),

                      SizedBox(height: 8),
                      const Text(
                        "Stay on top of your hunting adventures with our all-in-one tracking app!",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${mapProvider.weather.main.temp}°F (${capitalizeFirstLetter(mapProvider.weather.weather.first.description)})',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              DateFormat('MMM dd, yyyy').format(
                                  DateTime.now()), // Example: Dec 16, 2024
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${mapProvider.weather.name}, ${mapProvider.weather.sys.country}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                        'Humidity: ${mapProvider.weather.main.humidity}%'),
                                    Text(
                                        'Wind: ${mapProvider.weather.wind.speed}mph'),
                                    Text(
                                        'Barometric pressure: ${(mapProvider.weather.main.pressure * 0.02953).toStringAsFixed(2)} inHg')
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Trips Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Trips',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return TripsHistoryScreen();
                              }));
                            },
                            child: Text('See All',
                                style: TextStyle(color: Colors.orange)),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          reverse: false,
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          itemCount: mapProvider.trips.length,
                          itemBuilder: (context, index) {
                            final trip = mapProvider
                                .trips[mapProvider.trips.length - 1 - index];
                            return GestureDetector(
                              onTap: () {
                                final mapProvider = Provider.of<MapProvider>(
                                    context,
                                    listen: false);
                                mapProvider.selectedTripModel = trip;
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) {
                                  return TripDetailsScreen(
                                    tripModel: trip,
                                  );
                                }));
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Card(
                                  color: Colors.grey[900],
                                  child: Stack(
                                    // mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            10), // Adjust the radius as needed
                                        child: CachedNetworkImage(
                                          imageUrl: (trip.markers.isNotEmpty &&
                                                  trip.markers.first.media !=
                                                      null &&
                                                  trip.markers.first.media!
                                                      .isNotEmpty)
                                              ? trip.markers.first.media!
                                                  .firstWhere(
                                                  (media) =>
                                                      media.isNotEmpty &&
                                                      !checkIfVideo(media),
                                                  orElse: () =>
                                                      '', // Return an empty string if no valid image is found
                                                )
                                              : '',
                                          width: 200,
                                          height: 200,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Container(
                                            width: 150,
                                            height: 100,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: const Center(
                                              child: CircularProgressIndicator
                                                  .adaptive(),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                            width: 150,
                                            height: 100,
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                  255, 58, 55, 55),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: const Icon(Icons.image,
                                                color: Colors.red),
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, bottom: 30),
                                          child: SizedBox(
                                            width: 150,
                                            child: Text(
                                              trip.name,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, bottom: 10),
                                          child: Text(
                                            '${trip.markers.length} Locations',
                                            style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Recent Trips Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recent Trips',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return TripsHistoryScreen();
                              }));
                            },
                            child: const Text('See All',
                                style: TextStyle(color: Colors.orange)),
                          ),
                        ],
                      ),

                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: min(
                            mapProvider.trips.length, 6), // Show up to 6 items
                        itemBuilder: (context, index) {
                          final trip = mapProvider.trips[index];
                          return ListTile(
                            onTap: () {
                              final mapProvider = Provider.of<MapProvider>(
                                  context,
                                  listen: false);
                              mapProvider.selectedTripModel = trip;
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return TripDetailsScreen(
                                  tripModel: trip,
                                );
                              }));
                            },
                            leading:
                                Icon(Icons.location_pin, color: Colors.orange),
                            title: Text(trip.name,
                                style: TextStyle(color: Colors.white)),
                            subtitle: Text(trip.startLocation,
                                style: const TextStyle(color: Colors.white70)),
                            trailing: Text(
                                mapProvider.formatDistance(
                                    trip.totalDistance, context),
                                style: TextStyle(color: Colors.white)),
                          );
                        },
                      )
                    ],
                  ),
                ),
              ),
      );
    });
  }
}
