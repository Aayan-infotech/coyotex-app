import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'add_photos.dart';
import '../../../core/utills/app_colors.dart';
import '../../../core/utills/branded_primary_button.dart';
import '../../../core/utills/branded_text_filed.dart';
import 'package:coyotex/feature/map/view_model/map_provider.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({Key? key}) : super(key: key);

  // Method to show a dialog for setting the time duration
  Future<void> _showDurationPicker(
      BuildContext context, MarkerId markerId, MapProvider provider) async {
    Duration? selectedDuration = await showModalBottomSheet<Duration>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController minuteController = TextEditingController();

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Set Duration",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: minuteController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Enter time in minutes",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (minuteController.text.isNotEmpty) {
                    int minutes = int.parse(minuteController.text);
                    Navigator.of(context).pop(Duration(minutes: minutes));
                  } else {
                    Navigator.of(context).pop(null); // No duration selected
                  }
                },
                child: const Text("Set"),
              ),
            ],
          ),
        );
      },
    );

    if (selectedDuration != null) {
      // Use the selected duration as needed
      // provider.setMarkerDuration(markerId, selectedDuration);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MapProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: provider.initialPosition,
                  zoom: 10,
                ),
                myLocationEnabled: true,
                mapType: MapType.hybrid,
                myLocationButtonEnabled: true,
                polylines: provider.polylines,
                markers: provider.markers,
                onTap: provider.onMapTapped,
                onMapCreated: (controller) {
                  provider.mapController = controller;
                },
              ),
              // ... (other widgets remain unchanged)
              if (provider.isSave)
                Positioned(
                  bottom: 20,
                  left: 10,
                  right: 10,
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Image.asset("assets/images/distance_icons.png"),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Distance",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                      "${provider.distance.toStringAsFixed(2)} KM"),
                                ],
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {},
                                child: const Text(
                                  "Set Time",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (provider.timeDurations != null) ...[
                            const Text(
                              "Duration:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text("${provider.timeDurations} minutes"),
                          ],
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 35,
                            child: BrandedPrimaryButton(
                              isEnabled: true,
                              name: "Let's Hunt",
                              onPressed: () {},
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 35,
                            child: BrandedPrimaryButton(
                              isEnabled: true,
                              isUnfocus: true,
                              name: "Save Trip",
                              onPressed: () {
                                provider.saveTrip();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
