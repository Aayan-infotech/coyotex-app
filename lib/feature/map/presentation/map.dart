import 'package:coyotex/feature/map/view_model/map_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import 'add_photos.dart';
import '../../../core/utills/app_colors.dart';
import '../../../core/utills/branded_primary_button.dart';
import '../../../core/utills/branded_text_filed.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MapProvider(),
      child: Consumer<MapProvider>(
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
                Positioned(
                  top: 10,
                  left: 10,
                  right: 10,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Column(
                      children: [
                        _buildTextField(
                          provider.startController,
                          'My Location',
                          true,
                          provider,
                          const Icon(Icons.location_on, size: 20),
                          const Icon(Icons.person,
                              size: 20, color: Colors.grey),
                        ),
                        _buildSuggestionsBox(
                          provider.startSuggestions,
                          true,
                          provider,
                        ),
                        _buildTextField(
                          provider.destinationController,
                          'Trip 1',
                          false,
                          provider,
                          const Icon(Icons.check, size: 20, color: Colors.blue),
                          const Icon(Icons.drag_handle, size: 20),
                        ),
                        _buildSuggestionsBox(
                          provider.destinationSuggestions,
                          false,
                          provider,
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) {
                        return AddPhotoScreen();
                      }),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.27,
                      right: 10,
                    ),
                    child: const Align(
                      alignment: Alignment.topRight,
                      child: Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.red,
                        size: 30,
                      ),
                    ),
                  ),
                ),
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
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "${provider.distance.toStringAsFixed(2)} KM",
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                const Text("Next Stop"),
                              ],
                            ),
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Text(
                                          "22\u00B0",
                                          style: TextStyle(fontSize: 22),
                                        ),
                                        SizedBox(width: 5),
                                        Text("(Great Weather)"),
                                      ],
                                    ),
                                    Text(
                                      DateFormat('MMM d yyyy')
                                          .format(DateTime.now()),
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on_outlined,
                                          size: 13,
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          "Birds Hunting A",
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.23,
                                        ),
                                        const Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text("Humidity: 75%"),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
                                onPressed: () {},
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
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    bool isStartField,
    MapProvider provider,
    Icon prefixIcon,
    Icon suffixIcon,
  ) {
    return Row(
      children: [
        Expanded(
          child: BrandedTextField(
            height: 45,
            controller: controller,
            labelText: label,
            onChanged: (value) =>
                provider.getPlaceSuggestions(value, isStartField),
            prefix: prefixIcon,
          ),
        ),
        const SizedBox(width: 5),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: suffixIcon,
        ),
      ],
    );
  }

  Widget _buildSuggestionsBox(
    List<dynamic> suggestions,
    bool isStartField,
    MapProvider provider,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestions[index]['description']),
          onTap: () {
            // provider.selectSuggestion(suggestions[index], isStartField);
          },
        );
      },
    );
  }
}
