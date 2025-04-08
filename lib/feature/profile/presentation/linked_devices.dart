import 'package:coyotex/core/utills/branded_primary_button.dart';
import 'package:flutter/material.dart';

class LinkedDevicesScreen extends StatelessWidget {
  const LinkedDevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
       
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
            const SizedBox(height: 16),
            const Text(
              'Select Device and connect',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Lorem ipsum dolor sit amet consectetur.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Lorem ipsum dolor sit amet consectetur.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Image.asset(
              'assets/images/devices.png', // Replace with your asset path
              height: 150,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildDeviceTile(Icons.phone_android, 'Lorem ipsum'),
                  const Divider(color: Colors.white24, thickness: 1),
                  _buildDeviceTile(Icons.desktop_mac, 'Lorem ipsum'),
                  const Divider(color: Colors.white24, thickness: 1),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: BrandedPrimaryButton(
                  isEnabled: true, name: "Save", onPressed: () {}),
            ),
            const SizedBox(height: 16),
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
