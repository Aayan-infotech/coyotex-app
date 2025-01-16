import 'package:coyotex/core/utills/branded_primary_button.dart';
import 'package:flutter/material.dart';

class LinkedDevicesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Linked Devices',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 16),
            const Text(
              'Select Device and connect',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 40),
            const Text(
              'Lorem ipsum dolor sit amet consectetur.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            const Text(
              'Lorem ipsum dolor sit amet consectetur.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Image.asset(
              'assets/images/devices.png', // Replace with your asset path
              height: 150,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildDeviceTile(Icons.phone_android, 'Lorem ipsum'),
                  Divider(color: Colors.white24, thickness: 1),
                  _buildDeviceTile(Icons.desktop_mac, 'Lorem ipsum'),
                  Divider(color: Colors.white24, thickness: 1),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: BrandedPrimaryButton(
                  isEnabled: true, name: "Save", onPressed: () {}),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceTile(IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}
