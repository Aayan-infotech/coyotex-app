import 'package:coyotex/core/utills/branded_primary_button.dart';
import 'package:coyotex/core/utills/branded_text_filed.dart';
import 'package:flutter/material.dart';

class DataPointsScreen extends StatelessWidget {
  DataPointsScreen({Key? key}) : super(key: key);
  TextEditingController _shwNumberController = TextEditingController();
  TextEditingController _numberOfKilledController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                "assets/images/logo.png", // Replace with your logo asset path
                height: 100,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Data points analytics tracking.",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "We'd like to ask you some questions",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: 0.5, // Update this based on progress
                          color: Colors.red,
                          backgroundColor: Colors.red[100],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "1/2",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "How many Coyote You saw?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            BrandedTextField(
                controller: _shwNumberController, labelText: "Enter number"),
            const SizedBox(height: 20),
            const Text(
              "How many Coyote You killed?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            BrandedTextField(
                controller: _numberOfKilledController,
                labelText: "Enter number"),
            const Spacer(),
            BrandedPrimaryButton(
                isEnabled: true, name: "Submit", onPressed: () {})
          ],
        ),
      ),
    );
  }
}
