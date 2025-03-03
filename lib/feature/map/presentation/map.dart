import 'dart:convert';
import 'package:coyotex/feature/auth/data/view_model/user_view_model.dart';
import 'package:coyotex/feature/map/data/trip_model.dart';
import 'package:coyotex/feature/map/presentation/marker_bottom_sheat.dart';
import 'package:coyotex/feature/map/presentation/search_location_screen.dart';
import 'package:coyotex/feature/map/presentation/show_duration_and_animal_details_sheet.dart';
import 'package:coyotex/feature/map/view_model/map_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../../trip/presentation/add_photos.dart';
import '../../../core/utills/app_colors.dart';
import '../../../core/utills/branded_primary_button.dart';
import '../../../core/utills/branded_text_filed.dart';
import 'dart:ui' as ui;

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  int selectedMode = 0;
  final List<String> modes = ["Drive", "Bike", "Walk"];
  final List<IconData> modeIcons = [
    Icons.directions_car,
    Icons.two_wheeler,
    Icons.directions_walk,
  ];
  final Map<String, BitmapDescriptor> _icons = {};
  Future<void> _loadMarkers() async {
    _icons['markerIcon'] = await _getIcon('assets/images/marker_icon.png', 200);
  }

  Future<BitmapDescriptor> _getIcon(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return BitmapDescriptor.fromBytes(
        (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
            .buffer
            .asUint8List());
  }

  String time = "0";

  void showCustomDialog(BuildContext context, MapProvider provider,
      {bool isLocation = false}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return CustomDialog(
          isLocation: isLocation,
          mapProvider: provider,
        );
      },
    );
  }

  @override
  void initState() {
    final mapProvider = Provider.of<MapProvider>(context, listen: false);
    mapProvider.loadCustomLiveLocationIcon();
    _loadMarkers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserViewModel>(context, listen: false);

    return Consumer<MapProvider>(
      builder: (context, provider, child) {
        for (var item in provider.markers) {
          provider.mapMarkers.add(Marker(
            markerId: MarkerId(item.id),
            position: item.position,
            //  icon: _icons[item.icon] ?? _icons["markerIcon"]!,
            infoWindow: InfoWindow(title: item.title, snippet: item.snippet),
          ));
        }
        provider.context = context;
        return provider.isLoading
            ? const Center(
                child: CircularProgressIndicator.adaptive(
                backgroundColor: Colors.white,
              ))
            : Scaffold(
                body: Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: provider.mapMarkers.isNotEmpty
                                  ? provider.mapMarkers.last.position
                                  : provider.initialPosition,
                              zoom: 12,
                            ),
                            myLocationEnabled: true,
                            mapType: MapType.satellite,
                            compassEnabled: true,
                            myLocationButtonEnabled: true,
                            buildingsEnabled: true,
                            mapToolbarEnabled: true,
                            fortyFiveDegreeImageryEnabled: false,
                            polylines: provider.polylines,
                            markers: provider.mapMarkers,
                            onTap: provider.isSavedTrip
                                ? null
                                : (latlanng) async {
                                    provider.onMapTapped(latlanng, context);
                                  },
                            zoomGesturesEnabled: true,
                            onMapCreated: (controller) {
                              provider.mapController = controller;
                            },
                          ),
                        ),
                        if (provider.isTripStart)
                          SizedBox(
                            height: 220,
                            child: Column(
                              children: [
                                // Drag Handle
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Center(
                                    child: Container(
                                      width: 40,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[400],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                                // Horizontal Mode Selector
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 10),
                                  child: Row(
                                    children:
                                        List.generate(modes.length, (index) {
                                      final isSelected = selectedMode == index;
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedMode =
                                                index; // Update selectedMode first
                                          });

                                          String selectedTransport = modes[
                                              index]; // Get the correct mode

                                          if (selectedTransport == "Drive") {
                                            provider.speed = 45;
                                          } else if (selectedTransport ==
                                              "Bike") {
                                            provider.speed = 35;
                                          } else if (selectedTransport ==
                                              "Bus") {
                                            provider.speed = 30;
                                          } else if (selectedTransport ==
                                              "Walk") {
                                            provider.speed = 5;
                                          } else {
                                            provider.speed = 45;
                                          }

                                          provider.convertMinutesToHours();
                                        },
                                        child: Container(
                                          margin:
                                              const EdgeInsets.only(right: 10),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0, vertical: 8.0),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? Colors.blue
                                                : Colors.grey[200],
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                modeIcons[index],
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                modes[index],
                                                style: TextStyle(
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),

                                // Route Info
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(modeIcons[selectedMode],
                                              size: 28, color: Colors.blue),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              provider.totalTravelTime,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                height: 1.5,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              showCustomDialog(
                                                  context, provider);
                                            },
                                            child: const Text(
                                              "Break Time ",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          // Corrected part: Remove Expanded from GestureDetector
                                          GestureDetector(
                                            onTap: () {
                                              showCustomDialog(
                                                  context, provider,
                                                  isLocation: true);
                                            },
                                            child: Image.asset(
                                              "assets/images/location.png",
                                              height: 30,
                                              width: 30,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                          padding:
                                              const EdgeInsets.only(left: 40),
                                          child: Text(
                                            "${provider.formatDistance(provider.distance, context)}",
                                          )
                                          // "${provider.distance.toStringAsFixed(2)} ${userProvider.user.userUnit}"),
                                          )
                                    ],
                                  ),
                                ),
                                // Start Button
                                const SizedBox(height: 20),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: BrandedPrimaryButton(
                                          isEnabled: true,
                                          isUnfocus: true,
                                          name: "Add Photos",
                                          onPressed: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return AddPhotoScreen();
                                            }));
                                          },
                                          borderRadius: 20,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: BrandedPrimaryButton(
                                          isEnabled: true,
                                          isUnfocus: false,
                                          name: "Add Stop",
                                          onPressed: () {
                                            provider.addStop();
                                          },
                                          borderRadius: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                      ],
                    ),
                    Positioned(
                      top: -45,
                      left: 10,
                      right: 10,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 80),
                        child: Column(
                          children: [
                            if (!provider.onTapOnMap && !provider.isSavedTrip)
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
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return SearchLocationScreen(
                                            controller:
                                                provider.startController,
                                            isStart: true,
                                          );
                                        })).then((value) async {
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
                            const SizedBox(
                              height: 10,
                            ),
                            if (provider.onTapOnMap &&
                                provider.mapMarkers.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  showMarkersBottomSheet(context, provider);
                                },
                                child: Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width,
                                  padding: const EdgeInsets.all(12),
                                  // margin: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 6,
                                        spreadRadius: 2,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    provider.mapMarkers.last.infoWindow.snippet
                                        .toString(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            //   Container(
                            //     height: 50, // Item height + spacing
                            //     padding: const EdgeInsets.all(0),
                            //     child: ListView.builder(
                            //       padding: EdgeInsets.all(0),
                            //       itemCount: provider.markers.length,
                            //       scrollDirection: Axis.horizontal,
                            //       itemBuilder: (context, index) {
                            //         MarkerData _marker =
                            //             provider.markers[index];

                            //         return Padding(
                            //           padding: const EdgeInsets.symmetric(
                            //               horizontal: 4.0),
                            //           child: Chip(
                            //             label: Text(
                            //               (_marker.snippet != null &&
                            //                       _marker.snippet!.length > 1)
                            //                   ? _marker.snippet!.substring(
                            //                       0) // Hides first letter
                            //                   : "",
                            //               style: const TextStyle(
                            //                 fontSize: 16,
                            //                 fontWeight: FontWeight.bold,
                            //                 color: Colors
                            //                     .white, // Adjust text color
                            //               ),
                            //             ),
                            //             backgroundColor: Colors
                            //                 .blueAccent, // Change as needed
                            //             shape: RoundedRectangleBorder(
                            //               borderRadius:
                            //                   BorderRadius.circular(20),
                            //               side: const BorderSide(
                            //                   color: Colors.white,
                            //                   width: 1), // Optional border
                            //             ),
                            //             padding: const EdgeInsets.symmetric(
                            //                 horizontal: 12, vertical: 6),
                            //             deleteIcon: const Icon(Icons.close,
                            //                 color: Colors
                            //                     .white), // Styled delete icon
                            //             onDeleted: () {
                            //               provider.onRemove(_marker.position);
                            //             },
                            //           ),
                            //         );
                            //       },
                            //     ),
                            //   ),

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
                                                Icons.close,
                                                color: Colors.red,
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (provider.trips.isNotEmpty && !provider.isTripStart)
                      Positioned(
                        top: MediaQuery.of(context).size.height * 0.5,
                        left: 10,
                        right: 10,
                        bottom: 10,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            reverse: true,
                            child: Row(
                              children:
                                  List.generate(provider.trips.length, (index) {
                                TripModel tripModel = TripModel(
                                  id: provider.trips[index].id,
                                  userId: provider.trips[index].userId,
                                  name: provider.trips[index].name,
                                  startLocation:
                                      provider.trips[index].startLocation,
                                  destination:
                                      provider.trips[index].destination,
                                  waypoints: List.from(
                                      provider.trips[index].waypoints), // Copy
                                  totalDistance:
                                      provider.trips[index].totalDistance,
                                  createdAt: provider.trips[index].createdAt,
                                  routePoints: List.from(provider
                                      .trips[index].routePoints), // Copy
                                  markers: List.from(
                                      provider.trips[index].markers), // Copy
                                  weatherMarkers: List.from(provider
                                      .trips[index].weatherMarkers), // Copy
                                  animalKilled:
                                      provider.trips[index].animalKilled,
                                  animalSeen: provider.trips[index].animalSeen,
                                  images: List.from(
                                      provider.trips[index].images), // Copy
                                );

                                return GestureDetector(
                                  onTap: () async {
                                    provider.isSavedTrip = true;
                                    provider.isSave = true;
                                    provider.markers = tripModel.markers;
                                    provider.distance = tripModel.totalDistance;
                                    provider.selectedTripModel = tripModel;
                                    provider.points = tripModel.routePoints;
                                    provider.providerLetsHuntButton = true;
                                    provider.path = tripModel.routePoints;
                                    await provider.fetchRouteWithWaypoints(
                                      tripModel.routePoints,
                                    );
                                  },
                                  child: Card(
                                    color:
                                        const Color.fromRGBO(255, 255, 255, 1),
                                    child: SizedBox(
                                      height: MediaQuery.of(context)
                                              .size
                                              .height *
                                          0.1, // Explicit height of the card
                                      width: MediaQuery.of(context).size.width *
                                          0.8, // Set the width for each card
                                      child: Row(
                                        children: [
                                          // Padding(
                                          //   padding: const EdgeInsets.all(12.0),
                                          //   child: ClipRRect(
                                          //     borderRadius: BorderRadius.circular(
                                          //         8.0), // Adjust the radius as needed
                                          //     child: CachedNetworkImage(
                                          //       imageUrl:
                                          //           tripModel.images.isNotEmpty
                                          //               ? tripModel.images.first
                                          //               : '',
                                          //       height:
                                          //           100, // Image height should match the card height
                                          //       width: 100, // Image width
                                          //       fit: BoxFit.cover,
                                          //       placeholder: (context, url) =>
                                          //           Container(
                                          //         height: 100,
                                          //         width: 100,
                                          //         color: Colors.grey[
                                          //             300], // Placeholder color
                                          //         child: const Center(
                                          //             child:
                                          //                 CircularProgressIndicator()), // Loading indicator
                                          //       ),
                                          //       errorWidget:
                                          //           (context, url, error) =>
                                          //               Container(
                                          //         height: 100,
                                          //         width: 100,
                                          //         color: Colors.grey[
                                          //             300], // Background for error case
                                          //         child: const Icon(Icons.error,
                                          //             color: Colors
                                          //                 .red), // Error icon
                                          //       ),
                                          //     ),
                                          //   ),
                                          // ),
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
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Color.fromRGBO(
                                                            44, 51, 62, 1)),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    tripModel.startLocation,
                                                    maxLines: 4,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
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
                    // if (provider.isTripStart)
                    //   add_stop_card(
                    //       provider, context, provider.selectedTripModel),

                    // if (provider.isKeyDataPoint)
                    //   keyDataPoint(provider, context),
                  ],
                ),
              );
      },
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
                          "${provider.formatDistance(provider.distance, context)}"
                          //"${provider.distance.toStringAsFixed(2)} ${Provider.of<UserViewModel>(context, listen: false).user.userUnit}",
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
                          SizedBox(
                            width: 18,
                          ),
                          GestureDetector(
                            onTap: () {
                              showCustomDialog(context, provider);
                            },
                            child: const Text(
                              'Break Time',
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
                          Text(
                            provider.weather.base,
                            style: const TextStyle(fontSize: 12),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.37,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "Humidity: ${provider.weather.main.humidity}%"),
                              Text(
                                  "Pressure: ${provider.weather.main.pressure} "),
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
                      provider.context = context;
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

  // Positioned keyDataPoint(MapProvider provider, BuildContext context) {
  //   return Positioned(
  //     bottom: 20,
  //     left: 10,
  //     right: 10,
  //     child: Card(
  //       elevation: 4,
  //       child: Padding(
  //         padding: const EdgeInsets.all(8.0),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Row(
  //               children: [
  //                 Image.asset("assets/images/distance_icons.png"),
  //                 const SizedBox(width: 10),
  //                 const Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       "Distance",
  //                       style: TextStyle(fontWeight: FontWeight.bold),
  //                     ),
  //                     Text("${30} KM"
  //                         //"${provider.distance.toStringAsFixed(2)} KM",
  //                         ),
  //                   ],
  //                 ),
  //                 const Spacer(),
  //               ],
  //             ),
  //             Row(
  //               children: [
  //                 Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     const Row(
  //                       children: [
  //                         Text(
  //                           "22\u00B0",
  //                           style: TextStyle(fontSize: 22),
  //                         ),
  //                         SizedBox(width: 5),
  //                         Text("(Great Weather)"),
  //                       ],
  //                     ),
  //                     Text(
  //                       DateFormat('MMM d yyyy').format(DateTime.now()),
  //                       style: const TextStyle(fontSize: 15),
  //                     ),
  //                     Row(
  //                       children: [
  //                         const Icon(
  //                           Icons.location_on_outlined,
  //                           size: 13,
  //                         ),
  //                         const SizedBox(width: 8),
  //                         const Text(
  //                           "Birds Hunting A",
  //                           style: TextStyle(fontSize: 12),
  //                         ),
  //                         SizedBox(
  //                           width: MediaQuery.of(context).size.width * 0.23,
  //                         ),
  //                         const Column(
  //                           crossAxisAlignment: CrossAxisAlignment.end,
  //                           children: [
  //                             Text("Humidity: 75%"),
  //                           ],
  //                         ),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //             const SizedBox(height: 10),
  //             // SizedBox(
  //             //   height: 35,
  //             //   child: BrandedPrimaryButton(
  //             //     isEnabled: true,
  //             //     name: "Stop: 15 Min",
  //             //     onPressed: () {},
  //             //   ),
  //             // ),
  //             const SizedBox(height: 10),
  //             SizedBox(
  //               height: 35,
  //               child: BrandedPrimaryButton(
  //                 isEnabled: true,
  //                 isUnfocus: true,
  //                 name: "Key in  Data Point",
  //                 onPressed: () {
  //                   Navigator.of(context)
  //                       .push(MaterialPageRoute(builder: (context) {
  //                     return AddPhotoScreen();
  //                   }));
  //                 },
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

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
