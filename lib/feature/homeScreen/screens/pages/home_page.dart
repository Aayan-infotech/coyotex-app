import 'package:cached_network_image/cached_network_image.dart';
import 'package:coyotex/core/utills/branded_text_filed.dart';
import 'package:coyotex/core/utills/constant.dart';
import 'package:coyotex/core/utills/weather_state.dart';
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
      if (mounted && _scrollController.hasClients) {
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
                controller: _scrollController,
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
                          color: Colors.grey
                              .shade900, // Darker background for better contrast
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: Colors.red.shade700, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.shade900.withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.location_on,
                                    color: Colors.red.shade500, size: 20),
                                SizedBox(width: 4),
                                Text(
                                  '${mapProvider.weather.name}, ${mapProvider.weather.sys.country}',
                                  style: TextStyle(
                                    color: Colors
                                        .white, // Brighter text for contrast
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.thermostat,
                                            color: Colors.red.shade500,
                                            size: 28),
                                        SizedBox(width: 8),
                                        Text(
                                          '${mapProvider.weather.main.temp}°F',
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: Colors
                                                .white, // Bright white for emphasis
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        capitalizeFirstLetter(mapProvider
                                            .weather.weather.first.description),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors
                                              .grey.shade400, // Softer contrast
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      DateFormat('MMM dd')
                                          .format(DateTime.now()),
                                      style: TextStyle(
                                        color: Colors.white, // Brighter date
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('yyyy').format(DateTime.now()),
                                      style: TextStyle(
                                        color:
                                            Colors.grey.shade400, // Subtle year
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Divider(color: Colors.red.shade800, height: 1),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                WeatherStat(
                                  icon: Icons.water_drop,
                                  value:
                                      '${mapProvider.weather.main.humidity}%',
                                  label: 'Humidity',
                                  color: Colors.red
                                      .shade500, 
                                ),
                                WeatherStat(
                                  icon: Icons.air,
                                  value: '${mapProvider.weather.wind.speed}mph',
                                  label: 'Wind',
                                  color: Colors.red.shade500,
                                ),
                                WeatherStat(
                                  icon: Icons.speed,
                                  value:
                                      '${(mapProvider.weather.main.pressure * 0.02953).toStringAsFixed(2)} inHg',
                                  label: 'Pressure',
                                  color: Colors.red.shade500,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

// Add this reusable widget class somewhere in your code
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
                            child: const Text('See All',
                                style: TextStyle(color: Colors.orange)),
                          ),
                        ],
                      ),
                      mapProvider.trips.isEmpty
                          ? SizedBox(
                              height: 270,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.grey[850]!,
                                      Colors.red[900]!, // Changed to deep red
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withOpacity(
                                          0.4), // Changed to red shadow
                                      blurRadius: 15,
                                      spreadRadius: 3,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                  // image: const DecorationImage(
                                  //   image: AssetImage(
                                  //       'assets/images/camouflage_pattern.jpeg'),
                                  //   fit: BoxFit.cover,
                                  //   opacity: 0.15,
                                  // ),
                                  border: Border.all(
                                    color: Colors.red[800]!, // Red border
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(
                                      Icons.track_changes_rounded,
                                      size: 40,
                                      color: Colors.amber[50]!,
                                    ),
                                    const Text(
                                      "Your Hunting Journey Awaits!",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        letterSpacing: 0.8,
                                        fontFamily: 'RobotoCondensed',
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      "Track your adventures, log trophies,\nand build your outdoor legacy",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w300,
                                        color: Colors.white70,
                                        height: 1.4,
                                      ),
                                    ),
                                    const Spacer(),
                                    // ElevatedButton.icon(
                                    //   icon: Icon(Icons.forest, size: 20),
                                    //   label: const Text("Start New Hunt"),
                                    //   style: ElevatedButton.styleFrom(
                                    //     backgroundColor:
                                    //         Colors.red[700], // Red button
                                    //     foregroundColor: Colors.amber[50],
                                    //     shape: RoundedRectangleBorder(
                                    //       borderRadius:
                                    //           BorderRadius.circular(12),
                                    //     ),
                                    //     padding: const EdgeInsets.symmetric(
                                    //         horizontal: 20, vertical: 12),
                                    //   ),
                                    //   onPressed: () {},
                                    // ),
                                  ],
                                ),
                              ),
                            )
                          : SizedBox(
                              height: 200,
                              child: ListView.builder(
                                reverse: false,
                                controller: _scrollController,
                                scrollDirection: Axis.horizontal,
                                itemCount: mapProvider.trips.length,
                                itemBuilder: (context, index) {
                                  final trip = mapProvider.trips[
                                      mapProvider.trips.length - 1 - index];
                                  return GestureDetector(
                                    onTap: () {
                                      final mapProvider =
                                          Provider.of<MapProvider>(context,
                                              listen: false);
                                      mapProvider.selectedTripModel = trip;
                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                          return TripDetailsScreen(
                                            tripModel: trip,
                                          );
                                        }),
                                      );
                                    },
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Card(
                                        color: Colors.grey[900],
                                        elevation: 5,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Trip Image
                                            ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(12),
                                                topRight: Radius.circular(12),
                                              ),
                                              child: CachedNetworkImage(
                                                imageUrl: (trip.markers
                                                            .isNotEmpty &&
                                                        trip.markers.first
                                                                .media !=
                                                            null &&
                                                        trip.markers.first
                                                            .media!.isNotEmpty)
                                                    ? trip.markers.first.media!
                                                        .firstWhere(
                                                        (media) =>
                                                            media.isNotEmpty &&
                                                            !checkIfVideo(
                                                                media),
                                                        orElse: () => '',
                                                      )
                                                    : '',
                                                width: 200,
                                                height: 130,
                                                fit: BoxFit.fitWidth,
                                                placeholder: (context, url) =>
                                                    Container(
                                                  width: 200,
                                                  height: 130,
                                                  color: Colors.grey[300],
                                                  child: const Center(
                                                    child:
                                                        CircularProgressIndicator
                                                            .adaptive(),
                                                  ),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Image.asset(
                                                  "assets/images/coyotex_place_holder.jpg",
                                                  width: 200,
                                                  height: 130,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                            // Trip Details Below Image
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Trip Name
                                                  SizedBox(
                                                    width: 180,
                                                    child: Text(
                                                      trip.name,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  // Locations Count
                                                  Text(
                                                    '${trip.markers.length} Locations',
                                                    style: const TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
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
                      if (mapProvider.trips.isNotEmpty)
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
