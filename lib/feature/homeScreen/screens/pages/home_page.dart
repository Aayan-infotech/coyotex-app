import 'package:coyotex/core/utills/branded_text_filed.dart';
import 'package:coyotex/feature/map/presentation/trip_history.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/utills/notification.dart';
import '../../../map/view_model/map_provider.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    final mapProvider = Provider.of<MapProvider>(context, listen: false);

    mapProvider.getCurrentLocation();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MapProvider>(builder: (context, mapProvider, child) {
      print(mapProvider.weather);
      return Scaffold(
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo and Search Field
                Padding(
                  padding: const EdgeInsets.only(
                      top: 40.0), // Add top padding for spacing
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 50, // Set a width for the logo
                          height: 50, // Set a height for the logo
                        ),
                      ),
                      Expanded(
                        child: BrandedTextField(
                          height: 40,
                          controller: _searchController,
                          labelText: '',
                          prefix: Icon(Icons.search),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Welcome Text
                Text(
                  'Welcome!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 16),

                // Weather Information
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.all(4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${mapProvider.weather.main.temp}° (Great Weather)',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        DateFormat('MMM dd, yyyy')
                            .format(DateTime.now()), // Example: Dec 16, 2024
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 8),
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
                                  'Wind: ${mapProvider.weather.wind.speed}km/h'),
                              Text(
                                  'Barometric pressure: ${mapProvider.weather.main.pressure} mb'),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Trips Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
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
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        color: Colors.grey[900],
                        child: Column(
                          children: [
                            Image.asset('assets/images/trip1.png',
                                fit: BoxFit.cover), // Replace with image asset
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Trip 1',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              '720 Locations',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Card(
                        color: Colors.grey[900],
                        child: Column(
                          children: [
                            Image.asset('assets/images/trip2.png',
                                fit: BoxFit.cover), // Replace with image asset
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Trip 2',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const Text(
                              '120 Locations',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Recent Trips Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Trips',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text('See All',
                          style: TextStyle(color: Colors.orange)),
                    ),
                  ],
                ),
                ListTile(
                  leading: Icon(Icons.location_pin, color: Colors.orange),
                  title: Text('Trip 1', style: TextStyle(color: Colors.white)),
                  subtitle: Text(
                    'Lorem Ipsum is simply dummy',
                    style: TextStyle(color: Colors.white70),
                  ),
                  trailing:
                      Text('12 Miles', style: TextStyle(color: Colors.white)),
                ),
                ListTile(
                  leading: Icon(Icons.location_pin, color: Colors.orange),
                  title: Text('Trip 2', style: TextStyle(color: Colors.white)),
                  subtitle: Text(
                    'Lorem Ipsum is simply dummy',
                    style: TextStyle(color: Colors.white70),
                  ),
                  trailing:
                      Text('3 Miles', style: TextStyle(color: Colors.white)),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      );
    });
  }
}
