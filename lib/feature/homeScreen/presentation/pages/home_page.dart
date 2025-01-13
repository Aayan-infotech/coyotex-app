import 'package:coyotex/core/utills/branded_text_filed.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
                      '22° (Great Weather)',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Dec 16, 2024',
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
                          'New Jersey, US',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Humidity: 75%'),
                            Text('Wind: 5 km/h'),
                            Text('Barometric pressure: 1024 mb'),
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
                    onPressed: () {},
                    child:
                        Text('See All', style: TextStyle(color: Colors.orange)),
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
                            style:
                                TextStyle(color: Colors.white70, fontSize: 12),
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
                            style:
                                TextStyle(color: Colors.white70, fontSize: 12),
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
                    child:
                        Text('See All', style: TextStyle(color: Colors.orange)),
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
  }
}
