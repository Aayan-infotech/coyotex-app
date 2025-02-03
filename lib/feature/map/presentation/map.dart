import 'package:coyotex/feature/map/presentation/data_entry.dart';
import 'package:coyotex/feature/map/presentation/search_location_screen.dart';
import 'package:coyotex/feature/map/view_model/map_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import 'add_photos.dart';
import '../../../core/utills/app_colors.dart';
import '../../../core/utills/branded_primary_button.dart';
import '../../../core/utills/branded_text_filed.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Future<void> _showDurationPicker(
      BuildContext context, MarkerId markerId, MapProvider provider) async {
    TextEditingController minuteController = TextEditingController();

    Duration? selectedDuration = await showDialog<Duration>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: const Text(
            "Set Duration",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: minuteController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Enter time in minutes",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null); // No duration selected
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (minuteController.text.isNotEmpty) {
                  int minutes = int.parse(minuteController.text);
                  await provider.setTimeDuration(
                      provider.markerId, Duration(minutes: minutes));
                  Navigator.of(context).pop(null);

                  //  Navigator.of(context).pop(Duration(minutes: minutes));
                } else {
                  Navigator.of(context).pop(null); // No duration selected
                }
              },
              child: const Text("Set"),
            ),
          ],
        );
      },
    );

    if (selectedDuration != null) {
      // Use the selected duration as needed
      // provider.setMarkerDuration(markerId, selectedDuration);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    final mapProvider = Provider.of<MapProvider>(context, listen: false);
    mapProvider.loadCustomLiveLocationIcon();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MapProvider>(
      builder: (context, provider, child) {
        return provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Scaffold(
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
                      buildingsEnabled: true,
                      mapToolbarEnabled: true,
                      fortyFiveDegreeImageryEnabled: true,
                      polylines: provider.polylines,
                      markers: provider.markers,
                      onTap: provider.onMapTapped,
                      zoomGesturesEnabled: true,
                      onMapCreated: (controller) {
                        provider.mapController = controller;
                      },
                    ),
                    Positioned(
                      top: -45,
                      left: 10,
                      right: 10,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 80),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: BrandedTextField(
                                    height: 40,
                                    controller: provider.startController,
                                    labelText: "Search here",
                                    onTap: () {
                                      provider.resetFields();
                                      Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) {
                                        return SearchLocationScreen(
                                          controller: provider.startController,
                                          isStart: true,
                                        );
                                      })).then((value) {
                                        setState(() {});
                                      });
                                    },
                                    prefix: Icon(Icons.location_on),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                GestureDetector(
                                  onTap: () async {},
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (provider.startController.text.isNotEmpty &&
                                provider.trips.isEmpty)
                              const SizedBox(
                                height: 10,
                              ),
                            if (provider.startController.text.isNotEmpty)
                              Container(
                                height: (provider.destinationCount + 1) *
                                    (40 + 10), // Item height + spacing
                                padding: const EdgeInsets.all(0),
                                child: ListView.builder(
                                  padding: EdgeInsets.all(0),
                                  itemCount: provider.destinationCount,
                                  itemBuilder: (context, index) {
                                    TextEditingController controller = provider
                                            .destinationControllers.isNotEmpty
                                        ? provider.destinationControllers[index]
                                        : TextEditingController();

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: BrandedTextField(
                                              height: 40,
                                              controller: controller,
                                              labelText: "Destination",
                                              onTap: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) {
                                                      return SearchLocationScreen(
                                                        controller: controller,
                                                        isStart: false,
                                                      );
                                                    },
                                                  ),
                                                ).then((value) {
                                                  // provider.destinationControllers.add(controller);
                                                });
                                              },
                                              prefix: Icon(Icons.location_on),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          if (index ==
                                              provider.destinationCount - 1)
                                            GestureDetector(
                                              onTap: () {
                                                provider.increaseCount();
                                              },
                                              child: Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  border: Border.all(
                                                      color: Colors.white,
                                                      width: 2),
                                                ),
                                                child: const Icon(
                                                  Icons.add,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            )
                                          else
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                    color: Colors.white,
                                                    width: 2),
                                              ),
                                              child: const Icon(
                                                Icons.drag_handle,
                                                color: Colors.red,
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            if (provider.trips.isNotEmpty &&
                                provider.startController.text.isEmpty)
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                                child: ListView.builder(
                                    padding: EdgeInsets.all(0),
                                    itemCount: provider.trips.length,
                                    itemBuilder: (context, item) {
                                      return GestureDetector(
                                        onTap: () {
                                          // Navigator.of(context).push(
                                          //     MaterialPageRoute(
                                          //         builder: (context) {
                                          //   return SearchLocationScreen();
                                          // }));
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5),
                                          child: _buildTextField(
                                            provider.destinationController,
                                            provider.trips[item].name,
                                            false,
                                            provider,
                                            const Icon(Icons.check,
                                                size: 20, color: Colors.red),
                                            const Icon(
                                              Icons.drag_handle,
                                              size: 20,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                          ],
                        ),
                      ),
                    ),

                    if (provider.trips.length > 0)
                      Positioned(
                        top: MediaQuery.of(context).size.height * 0.5,
                        left: 10,
                        right: 10,
                        bottom: 10,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children:
                                  List.generate(provider.trips.length, (index) {
                                return GestureDetector(
                                  onTap: () async {
                                    provider.isSavedTrip = true;
                                    provider.isSave = true;
                                    provider.path =
                                        provider.trips[index].routePoints;
                                    await provider.fetchRouteWithWaypoints(
                                        provider.trips[index].routePoints);
                                  },
                                  child: Card(
                                    color: Colors.white,
                                    child: SizedBox(
                                      height:
                                          110, // Explicit height of the card
                                      width: MediaQuery.of(context).size.width *
                                          0.8, // Set the width for each card
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(
                                                  8.0), // Adjust the radius as needed
                                              child: Image.network(
                                                "https://images.pexels.com/photos/1386604/pexels-photo-1386604.jpeg",
                                                height:
                                                    100, // Image height should match the card height
                                                width: 100, // Image width
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Trip ${index + 1}",
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const Text(
                                                    "Lorem IpsumLorem Ipsum",
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 12),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                      ),
                    // GestureDetector(
                    //   onTap: () {
                    //     Navigator.of(context).push(
                    //       MaterialPageRoute(builder: (context) {
                    //         return const AddPhotoScreen();
                    //       }),
                    //     );
                    //   },
                    //   child: Padding(
                    //     padding: EdgeInsets.only(
                    //       top: MediaQuery.of(context).size.height * 0.27,
                    //       right: 10,
                    //     ),
                    //     child: const Align(
                    //       alignment: Alignment.topRight,
                    //       child: Icon(
                    //         Icons.camera_alt_outlined,
                    //         color: Colors.red,
                    //         size: 30,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    if (provider.isSave) tripCard(provider, context),
                    if (provider.isTripStart) add_stop_card(provider, context),
                    if (provider.isHurryUp) hurry_up_card(provider, context),
                    if (provider.isKeyDataPoint)
                      keyDataPoint(provider, context),
                  ],
                ),
              );
      },
    );
  }

  Positioned hurry_up_card(MapProvider provider, BuildContextcontext) {
    return Positioned(
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
              const SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Image.asset("assets/images/break_time.png"),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Late 5 min",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      Text(
                        "15 Min",
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              SizedBox(
                height: 35,
                child: BrandedPrimaryButton(
                  isEnabled: true,
                  isUnfocus: false,
                  name: "Hurry Up",
                  onPressed: () {
                    provider.hurryUp();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Positioned add_stop_card(MapProvider provider, BuildContext context) {
    return Positioned(
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
                            fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      Text(
                        "${provider.distance.toStringAsFixed(2)} KM",
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      _showDurationPicker(context, MarkerId("value"), provider);
                    },
                    child: const Text(
                      "Set Time",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Image.asset("assets/images/break_time.png"),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Break Time",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      Text(
                        "15 Min",
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              SizedBox(
                height: 35,
                child: BrandedPrimaryButton(
                  isEnabled: true,
                  isUnfocus: false,
                  name: "Add Stop",
                  onPressed: () {
                    provider.addStop();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Positioned tripCard(
    MapProvider provider,
    BuildContext context,
  ) {
    return Positioned(
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
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${provider.distance.toStringAsFixed(2)} KM",
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      _showDurationPicker(context, MarkerId("value"), provider);
                    },
                    child: const Text(
                      "Set Time",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
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
                        DateFormat('MMM d yyyy').format(DateTime.now()),
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
                            width: MediaQuery.of(context).size.width * 0.23,
                          ),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
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
                  onPressed: () {
                    provider.letsHunt();
                  },
                ),
              ),
              const SizedBox(height: 10),
              if (!provider.isSavedTrip)
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
    );
  }

  Positioned keyDataPoint(MapProvider provider, BuildContext context) {
    return Positioned(
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
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${provider.distance.toStringAsFixed(2)} KM",
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      _showDurationPicker(context, MarkerId("value"), provider);
                    },
                    child: const Text(
                      "Set Time",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
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
                        DateFormat('MMM d yyyy').format(DateTime.now()),
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
                            width: MediaQuery.of(context).size.width * 0.23,
                          ),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
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
              // SizedBox(
              //   height: 35,
              //   child: BrandedPrimaryButton(
              //     isEnabled: true,
              //     name: "Stop: 15 Min",
              //     onPressed: () {},
              //   ),
              // ),
              const SizedBox(height: 10),
              SizedBox(
                height: 35,
                child: BrandedPrimaryButton(
                  isEnabled: true,
                  isUnfocus: true,
                  name: "Key in  Data Point",
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return DataPointsScreen();
                    }));
                  },
                ),
              ),
            ],
          ),
        ),
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
            height: 40,
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

  Widget _buildSuggestionsBox(List<dynamic> suggestions, bool isStartField,
      MapProvider provider, BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.width,
      color: Colors.white.withOpacity(.7),
      child: ListView.builder(
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
      ),
    );
  }
}
