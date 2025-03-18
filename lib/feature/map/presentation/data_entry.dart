import 'package:coyotex/core/services/server_calls/trip_apis.dart';
import 'package:coyotex/core/utills/branded_primary_button.dart';
import 'package:coyotex/core/utills/branded_text_filed.dart';
import 'package:coyotex/feature/map/view_model/map_provider.dart';
import 'package:coyotex/utils/app_dialogue_box.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DataPointsScreen extends StatefulWidget {
  String id;
  DataPointsScreen({required this.id, Key? key}) : super(key: key);

  @override
  State<DataPointsScreen> createState() => _DataPointsScreenState();
}

class _DataPointsScreenState extends State<DataPointsScreen> {
  TextEditingController _shwNumberController = TextEditingController();

  TextEditingController _numberOfKilledController = TextEditingController();
  bool isLoading = false;
  TripAPIs _tripAPIs = TripAPIs();

  Future<void> addAnimalSeenAndKilled() async {
    setState(() {
      isLoading = true;
    });

    // Map<String, dynamic> data = {
    //   "tripId": widget.id,
    //   "key": "animalsSeen", //animalKilled
    //   "value": _shwNumberController.text.isNotEmpty
    //       ? int.parse(_shwNumberController.text)
    //       : 0
    // };
    // var response = await _tripAPIs.addAnimalSeenAndKilled(data);
    // Map<String, dynamic> killedAnimalData = {
    //   "tripId": widget.id,
    //   "key": "animalKilled",
    //   "value": _shwNumberController.text.isNotEmpty
    //       ? int.parse(_shwNumberController.text)
    //       : 0
    // };
    // response = await _tripAPIs.addAnimalSeenAndKilled(killedAnimalData);
    // if (response.success) {
    //   AppDialog.showSuccessDialog(context, response.message, () {
    //     final mapProvider = Provider.of<MapProvider>(context, listen: false);
    //     mapProvider.submit(context);
    //   });
    // } else {
    //   AppDialog.showErrorDialog(context, response.message, () {
    //     final mapProvider = Provider.of<MapProvider>(context, listen: false);
    //     //  mapProvider.submit(context);
    //   });
    // }
    setState(() {
      isLoading = false;
    });
  }

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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
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
                    controller: _shwNumberController,
                    labelText: "Enter number",
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "How many Coyote You killed?",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  BrandedTextField(
                    controller: _numberOfKilledController,
                    labelText: "Enter number",
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  BrandedPrimaryButton(
                      isEnabled: true,
                      name: "Submit",
                      onPressed: () async {
                        final mapProvider =
                            Provider.of<MapProvider>(context, listen: false);
                        await addAnimalSeenAndKilled();
                      })
                ],
              ),
            ),
    );
  }
}
