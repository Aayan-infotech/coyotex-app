import 'dart:convert';

import 'package:coyotex/feature/map/data/trip_model.dart';
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
  void showCustomDialog(BuildContext context, MapProvider mapProvider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Stop Duration",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              // List of iteFms
              ListView.separated(
                shrinkWrap: true,
                itemCount: mapProvider.markers.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  List<MarkerData> listMarkerData =
                      List.from(mapProvider.markers);
                  MarkerData markerData = listMarkerData[index];
                  return ListTile(
                    title: Text(markerData.snippet),
                    trailing: Text(
                      "${markerData.duration.toString()} min",
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    onTap: () {},
                  );
                },
              ),
              const SizedBox(height: 10),
              // Close button
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("Close"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    final mapProvider = Provider.of<MapProvider>(context, listen: false);
    mapProvider.loadCustomLiveLocationIcon();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MapProvider>(
      builder: (context, provider, child) {
        for (var item in provider.markers) {
          provider.mapMarkers.add(Marker(
            markerId: MarkerId(item.id),
            position: item.position,
            infoWindow: InfoWindow(title: item.title, snippet: item.snippet),
          ));
        }
        provider.context = context;
        return provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Scaffold(
                body: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: provider.mapMarkers.isNotEmpty
                            ? provider.mapMarkers.last.position
                            : provider.initialPosition,
                        zoom: 15,
                      ),
                      myLocationEnabled: true,
                      mapType: MapType.satellite,
                      myLocationButtonEnabled: true,
                      buildingsEnabled: true,
                      mapToolbarEnabled: true,
                      fortyFiveDegreeImageryEnabled: false,
                      polylines: provider.polylines,
                      markers: provider.mapMarkers,
                      onTap: (latlanng) async {
                        provider.onMapTapped(latlanng, context);
                      },
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
                            // if (!provider.onTapOnMap)
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
                                      })).then((value) async {
                                        print(value);
                                        Map<String, dynamic> data =
                                            jsonDecode(value);

                                        await provider.onSuggestionSelected(
                                            data['placeId'],
                                            data["isStart"],
                                            provider.startController,
                                            // data["controller"],
                                            context);
                                        // provider.showDurationPicker(context);
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
                            if (provider.onTapOnMap)
                              Container(
                                height: 50, // Item height + spacing
                                padding: const EdgeInsets.all(0),
                                child: ListView.builder(
                                  padding: EdgeInsets.all(0),
                                  itemCount: provider.markers.length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    MarkerData _marker =
                                        provider.markers[index];

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      child: Chip(
                                        label: Text(
                                          (_marker.snippet != null &&
                                                  _marker.snippet!.length > 1)
                                              ? _marker.snippet!.substring(
                                                  0) // Hides first letter
                                              : "",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors
                                                .white, // Adjust text color
                                          ),
                                        ),
                                        backgroundColor: Colors
                                            .blueAccent, // Change as needed
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          side: const BorderSide(
                                              color: Colors.white,
                                              width: 1), // Optional border
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        deleteIcon: const Icon(Icons.close,
                                            color: Colors
                                                .white), // Styled delete icon
                                        onDeleted: () {
                                          provider.onRemove(_marker.position);
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),

                            if (provider.startController.text.isNotEmpty &&
                                provider.trips.isEmpty)
                              const SizedBox(
                                height: 10,
                              ),
                            if (provider.startController.text.isNotEmpty &&
                                !provider.onTapOnMap)
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
                                                ).then((value) async {
                                                  Map<String, dynamic> data =
                                                      jsonDecode(value);
                                                  await provider
                                                      .onSuggestionSelected(
                                                          data['placeId'],
                                                          data["isStart"],
                                                          controller,
                                                          context);
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
                            // if (provider.trips.isNotEmpty &&
                            //     provider.startController.text.isEmpty)
                            // SizedBox(
                            //   height:
                            //       MediaQuery.of(context).size.height * 0.2,
                            //   child: ListView.builder(
                            //       padding: const EdgeInsets.all(0),
                            //       itemCount: provider.trips.length,
                            //       itemBuilder: (context, item) {
                            //         return GestureDetector(
                            //           onTap: () {
                            //             // Navigator.of(context).push(
                            //             //     MaterialPageRoute(
                            //             //         builder: (context) {
                            //             //   return SearchLocationScreen();
                            //             // }));
                            //           },
                            //           child: Padding(
                            //             padding: const EdgeInsets.symmetric(
                            //                 vertical: 5),
                            //             child: _buildTextField(
                            //               provider.destinationController,
                            //               provider.trips[item].name,
                            //               false,
                            //               provider,
                            //               const Icon(Icons.check,
                            //                   size: 20, color: Colors.red),
                            //               const Icon(
                            //                 Icons.drag_handle,
                            //                 size: 20,
                            //                 color: Colors.white,
                            //               ),
                            //             ),
                            //           ),
                            //         );
                            //       }),
                            // ),
                          ],
                        ),
                      ),
                    ),
                    if (provider.trips.isNotEmpty)
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
                                TripModel tripModel = provider.trips[index];

                                return GestureDetector(
                                  onTap: () async {
                                    provider.isSavedTrip = true;
                                    provider.isSave = true;
                                    provider.markers = tripModel.markers;
                                    provider.distance = tripModel.totalDistance;
                                    provider.selectedTripModel = tripModel;
                                    provider.providerLetsHuntButton = true;
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
                                                    tripModel.name,
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
                    if (provider.isSave) tripCard(provider, context),
                    if (provider.isTripStart)
                      add_stop_card(
                          provider, context, provider.selectedTripModel),
                    if (provider.isHurryUp) hurry_up_card(provider, context),
                    if (provider.isKeyDataPoint)
                      keyDataPoint(provider, context),
                  ],
                ),
              );
      },
    );
  }

  Positioned hurry_up_card(MapProvider provider, BuildContext context) {
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
              const SizedBox(
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

  Positioned add_stop_card(
      MapProvider provider, BuildContext context, TripModel trip_data) {
    int totalTime = 0;
    for (var item in trip_data.markers) {
      totalTime += item.duration;
    }
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
                        "${provider.selectedTripModel.totalDistance.toStringAsFixed(2)} KM",
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // GestureDetector(
                  //     onTap: () {
                  //       provider.resetFields();
                  //     },
                  //     child: IconButton(
                  //         onPressed: () {}, icon: const Icon(Icons.close))),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Image.asset("assets/images/break_time.png"),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Break Time",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      Text(
                        "${totalTime.toString()} Min",
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
                  IconButton(
                      onPressed: () {
                        provider.resetFields();
                      },
                      icon: Icon(Icons.close)),
                ],
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 200,
                            child: Row(
                              children: [
                                Text(
                                  "${provider.weather.main.temp}\u00B0",
                                  style: TextStyle(fontSize: 22),
                                ),
                                SizedBox(width: 5),
                                Text(
                                    "(${provider.weather.weather.first.description})"),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              showCustomDialog(context, provider);
                            },
                            child: Text(
                              " ${provider.totalTime.toString()} Min",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          )
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                  "Humidity: ${provider.weather.main.humidity}%"),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
               if (provider.providerLetsHuntButton)
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
                      provider.saveTrip(context);
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
                      Text("${30} KM"
                          //"${provider.distance.toStringAsFixed(2)} KM",
                          ),
                    ],
                  ),
                  const Spacer(),
                  // GestureDetector(
                  //   onTap: () {
                  //     // _showDurationPicker(context, MarkerId("value"), provider);
                  //   },
                  //   child: const Text(
                  //     "Set Time",
                  //     style: TextStyle(fontWeight: FontWeight.bold),
                  //   ),
                  // ),
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
                      return AddPhotoScreen();
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
