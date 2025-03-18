// import 'dart:async';
// import 'dart:convert';
// import 'dart:math';
// import 'package:animated_marker/animated_marker.dart';
// import 'package:coyotex/feature/auth/data/view_model/user_view_model.dart';
// import 'package:coyotex/feature/map/data/trip_model.dart';
// import 'package:coyotex/feature/map/presentation/marker_bottom_sheat.dart';
// import 'package:coyotex/feature/map/presentation/search_location_screen.dart';
// import 'package:coyotex/feature/map/presentation/show_duration_and_animal_details_sheet.dart';
// import 'package:coyotex/feature/map/view_model/map_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_compass/flutter_compass.dart';
// import 'package:provider/provider.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:intl/intl.dart';
// import '../../trip/presentation/add_photos.dart';
// import '../../../core/utills/app_colors.dart';
// import '../../../core/utills/branded_primary_button.dart';
// import '../../../core/utills/branded_text_filed.dart';
// import 'dart:ui' as ui;
// import 'package:permission_handler/permission_handler.dart';

// class MapScreen extends StatefulWidget {
//   const MapScreen({Key? key}) : super(key: key);

//   @override
//   State<MapScreen> createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   int selectedMode = 0;
//   final List<String> modes = ["Drive", "Bike", "Walk"];
//   final List<IconData> modeIcons = [
//     Icons.directions_car,
//     Icons.two_wheeler,
//     Icons.directions_walk,
//   ];
//   StreamSubscription<CompassEvent>? _compassSubscription;
//   double? _compassHeading;
//   final Map<String, BitmapDescriptor> icons = {};
//   Future<void> _loadMarkers() async {
//     icons['markerIcon'] = await _getIcon('assets/images/marker_icon.png', 200);
//   }

//   Future<void> _initCompass() async {
//     // Request permission for sensors (Android)
//     if (await Permission.sensors.request().isGranted) {
//       FlutterCompass.events?.listen((event) {
//         final provider = Provider.of<MapProvider>(context, listen: false);
//         if (provider.isTripStart && event.heading != null) {
//           setState(() => _compassHeading = event.heading);
//           _updateMapBearing(provider, event.heading!);
//         }
//       });
//     }
//   }

//   void _updateMapBearing(MapProvider provider, double heading) {
//     if (provider.mapController != null) {
//       provider.mapController!.animateCamera(
//         CameraUpdate.newCameraPosition(
//           CameraPosition(
//             target: provider.currentCameraTarget,
//             bearing: heading,
//             tilt: 0,
//             zoom: provider.currentZoom,
//           ),
//         ),
//       );
//     }
//   }

//   Future<BitmapDescriptor> _getIcon(String path, int width) async {
//     final ui.Image image = await _loadImage(path, width);
//     return BitmapDescriptor.fromBytes(
//       await _getBytesFromImage(image),
//       size: const Size(0.5, 1.0),
//       // Set anchor to bottom center
//     );
//   }

//   Future<ui.Image> _loadImage(String path, int width) async {
//     final ByteData data = await rootBundle.load(path);
//     final ui.Codec codec = await ui.instantiateImageCodec(
//       data.buffer.asUint8List(),
//       targetWidth: width,
//     );
//     final ui.FrameInfo fi = await codec.getNextFrame();
//     return fi.image;
//   }

//   Future<Uint8List> _getBytesFromImage(ui.Image image) async {
//     final ByteData? byteData = await image.toByteData(
//       format: ui.ImageByteFormat.png,
//     );
//     return byteData!.buffer.asUint8List();
//   }

//   String time = "0";

//   void showCustomDialog(BuildContext context, MapProvider provider,
//       {bool isLocation = false}) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       backgroundColor: Colors.white,
//       builder: (context) {
//         return CustomDialog(
//           isLocation: isLocation,
//           mapProvider: provider,
//         );
//       },
//     );
//   }

//   @override
//   void initState() {
//     _loadMarkers();
//     _initCompass();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     // TODO: implement dispose
//     _compassSubscription?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<MapProvider>(
//       builder: (context, provider, child) {
//         for (var item in provider.markers) {
//           provider.mapMarkers.add(Marker(
//             markerId: MarkerId(item.id),
//             position: item.position,
//             //icon: icons[item.icon] ?? icons["markerIcon"]!,
//             infoWindow: InfoWindow(title: item.title, snippet: item.snippet),
//           ));
//         }
//         provider.context = context;
//         return provider.isLoading
//             ? const Center(
//                 child: CircularProgressIndicator.adaptive(
//                 backgroundColor: Colors.white,
//               ))
//             : Scaffold(
//                 // appBar: AppBar(
//                 //   backgroundColor: Colors.black,
//                 //   centerTitle: true,
//                 //   title: Text(
//                 //     "Map",
//                 //     style: TextStyle(color: Colors.white),
//                 //   ),
//                 // ),
//                 body: Stack(
//                   children: [
//                     Column(
//                       children: [
//                         Expanded(
//                           child: Stack(
//                             children: [
                             
//                                StreamBuilder<LatLng>(
//         stream: provider.positionStream, // use the stream in the builder
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) return Container(); // handle no data

//           final markers = {
//             Marker(
//               markerId: const MarkerId('uniqueMarkerId'),
              
//               position: snapshot.data!,
//               rotation: Random().nextDouble() * 360, // randomize the rotation
//               infoWindow: InfoWindow(
//                 title: 'Animated Marker',
//                 onTap: () => showDialog(
//                   context: context,
//                   builder: (context) => const AlertDialog(
//                     title: Text('Animated Marker Info'),
//                   ),
//                 ),
//               ),
//             )
//           };

//           return AnimatedMarker(
//             staticMarkers: staticMarkers,
//             animatedMarkers: markers,
//             duration:
//                 const Duration(seconds: 3), // change the animation duration
//             // fps: 30, // change the animation frames per second
//             curve: Curves.easeOut, // change the animation curve
//             builder: (context, animatedMarkers) {
//               return  GoogleMap(
//                                 initialCameraPosition: CameraPosition(
//                                   target: provider.mapMarkers.isNotEmpty
//                                       ? provider.mapMarkers.last.position
//                                       : provider.initialPosition,
//                                   zoom: 12,
//                                 ),
//                                 myLocationEnabled: true,
//                                 mapType: MapType.normal,
//                                 compassEnabled: true,
//                                 onCameraMove: (position) =>
//                                     provider.onCameraMove(position),
//                                 myLocationButtonEnabled: false,
//                                 buildingsEnabled: true,
//                                 mapToolbarEnabled: false,
//                                 fortyFiveDegreeImageryEnabled: false,
//                                 polylines: provider.polylines,
//                                 markers: provider.mapMarkers,
//                                 onTap: provider.isSavedTrip
//                                     ? null
//                                     : (latlanng) async {
//                                         provider.onMapTapped(latlanng, context);
//                                       },
//                                 zoomGesturesEnabled: true,
//                                 onMapCreated: (controller) {
//                                   provider.mapController = controller;
//                                 },
//                               );
//             },
//           );
//         },
//       ),
//                               if (provider.isTripStart)
//                                 Padding(
//                                   padding:
//                                       const EdgeInsets.only(top: 30, right: 10),
//                                   child: Align(
//                                     alignment: Alignment.topRight,
//                                     child: FloatingActionButton(
//                                       backgroundColor: Colors.white,
//                                       onPressed: () async {
//                                         final position =
//                                             await Provider.of<MapProvider>(
//                                                     context,
//                                                     listen: false)
//                                                 .getCurrentLocation();
//                                         if (position != null) {
//                                           provider.mapController?.animateCamera(
//                                             CameraUpdate.newCameraPosition(
//                                               CameraPosition(
//                                                 target: LatLng(
//                                                     position.latitude,
//                                                     position.longitude),
//                                                 zoom: 14,
//                                               ),
//                                             ),
//                                           );
//                                         }
//                                       },
//                                       child: const Icon(Icons.my_location,
//                                           color: Colors.blue),
//                                     ),
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ),
//                         if (provider.isTripStart)
//                           SizedBox(
//                             height: 220,
//                             child: Column(
//                               children: [
//                                 // Drag Handle
//                                 Padding(
//                                   padding: const EdgeInsets.only(top: 8.0),
//                                   child: Center(
//                                     child: Container(
//                                       width: 40,
//                                       height: 5,
//                                       decoration: BoxDecoration(
//                                         color: Colors.grey[400],
//                                         borderRadius: BorderRadius.circular(10),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 // Horizontal Mode Selector
//                                 SingleChildScrollView(
//                                   scrollDirection: Axis.horizontal,
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 16.0, vertical: 10),
//                                   child: Row(
//                                     children:
//                                         List.generate(modes.length, (index) {
//                                       final isSelected = selectedMode == index;
//                                       return GestureDetector(
//                                         onTap: () {
//                                           setState(() {
//                                             selectedMode =
//                                                 index; // Update selectedMode first
//                                           });

//                                           String selectedTransport = modes[
//                                               index]; // Get the correct mode

//                                           if (selectedTransport == "Drive") {
//                                             provider.speed = 45;
//                                           } else if (selectedTransport ==
//                                               "Bike") {
//                                             provider.speed = 35;
//                                           } else if (selectedTransport ==
//                                               "Bus") {
//                                             provider.speed = 30;
//                                           } else if (selectedTransport ==
//                                               "Walk") {
//                                             provider.speed = 5;
//                                           } else {
//                                             provider.speed = 45;
//                                           }

//                                           provider.convertMinutesToHours(
//                                               provider.distance);
//                                         },
//                                         child: Container(
//                                           margin:
//                                               const EdgeInsets.only(right: 10),
//                                           padding: const EdgeInsets.symmetric(
//                                               horizontal: 16.0, vertical: 8.0),
//                                           decoration: BoxDecoration(
//                                             color: isSelected
//                                                 ? Colors.blue
//                                                 : Colors.grey[200],
//                                             borderRadius:
//                                                 BorderRadius.circular(20),
//                                           ),
//                                           child: Row(
//                                             children: [
//                                               Icon(
//                                                 modeIcons[index],
//                                                 color: isSelected
//                                                     ? Colors.white
//                                                     : Colors.black,
//                                               ),
//                                               const SizedBox(width: 8),
//                                               Text(
//                                                 modes[index],
//                                                 style: TextStyle(
//                                                   color: isSelected
//                                                       ? Colors.white
//                                                       : Colors.black,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       );
//                                     }),
//                                   ),
//                                 ),

//                                 // Route Info
//                                 const SizedBox(height: 10),
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 16.0),
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Row(
//                                         children: [
//                                           Icon(modeIcons[selectedMode],
//                                               size: 28, color: Colors.blue),
//                                           const SizedBox(width: 10),
//                                           Expanded(
//                                             child: Text(
//                                               provider.totalTravelTime,
//                                               style: const TextStyle(
//                                                 fontSize: 20,
//                                                 height: 1.5,
//                                                 fontWeight: FontWeight.bold,
//                                                 color: Colors.green,
//                                               ),
//                                             ),
//                                           ),
//                                           GestureDetector(
//                                             onTap: () {
//                                               showCustomDialog(
//                                                   context, provider);
//                                             },
//                                             child: const Text(
//                                               "Break Time ",
//                                               style: TextStyle(
//                                                   fontWeight: FontWeight.bold),
//                                             ),
//                                           ),
//                                           IconButton(
//                                               onPressed: () {
//                                                 provider.showRoutesBottomSheet(
//                                                     context);
//                                               },
//                                               icon: Icon(Icons.route)),
//                                           // Corrected part: Remove Expanded from GestureDetector
//                                           GestureDetector(
//                                             onTap: () {
//                                               showCustomDialog(
//                                                   context, provider,
//                                                   isLocation: true);
//                                             },
//                                             child: Image.asset(
//                                               "assets/images/location.png",
//                                               height: 30,
//                                               width: 30,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       Padding(
//                                           padding:
//                                               const EdgeInsets.only(left: 40),
//                                           child: Text(provider.formattedDistance
//                                               // "${provider.formatDistance(provider.distance, context)}",
//                                               )
//                                           // "${provider.distance.toStringAsFixed(2)} ${userProvider.user.userUnit}"),
//                                           )
//                                     ],
//                                   ),
//                                 ),
//                                 // Start Button
//                                 const SizedBox(height: 20),
//                                 Padding(
//                                   padding:
//                                       const EdgeInsets.symmetric(horizontal: 5),
//                                   child: Row(
//                                     children: [
//                                       Expanded(
//                                         child: BrandedPrimaryButton(
//                                           isEnabled: true,
//                                           isUnfocus: true,
//                                           name: "Add Photos",
//                                           onPressed: () {
//                                             Navigator.of(context).push(
//                                                 MaterialPageRoute(
//                                                     builder: (context) {
//                                               return AddPhotoScreen();
//                                             }));
//                                           },
//                                           borderRadius: 20,
//                                         ),
//                                       ),
//                                       const SizedBox(
//                                         width: 10,
//                                       ),
//                                       Expanded(
//                                         child: BrandedPrimaryButton(
//                                           isEnabled: true,
//                                           isUnfocus: false,
//                                           name: "Add Stop",
//                                           onPressed: () {
//                                             provider.addStop();
//                                           },
//                                           borderRadius: 20,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 )
//                               ],
//                             ),
//                           )
//                       ],
//                     ),
//                     Positioned(
//                       top: -45,
//                       left: 10,
//                       right: 10,
//                       child: Padding(
//                         padding: const EdgeInsets.only(top: 80),
//                         child: Column(
//                           children: [
//                             if (!provider.onTapOnMap && !provider.isSavedTrip)
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     child: BrandedTextField(
//                                       height: 40,
//                                       controller: provider.startController,
//                                       labelText: "Search here",
//                                       onTap: () {
//                                         provider.resetFields();

//                                         Navigator.of(context).push(
//                                             MaterialPageRoute(
//                                                 builder: (context) {
//                                           return SearchLocationScreen(
//                                             controller:
//                                                 provider.startController,
//                                             isStart: true,
//                                           );
//                                         })).then((value) async {
//                                           Map<String, dynamic> data =
//                                               jsonDecode(value);

//                                           await provider.onSuggestionSelected(
//                                               data['placeId'],
//                                               data["isStart"],
//                                               provider.startController,
//                                               // data["controller"],
//                                               context);
//                                           // provider.showDurationPicker(context);
//                                         });
//                                       },
//                                       prefix: Icon(Icons.location_on),
//                                     ),
//                                   ),
//                                   const SizedBox(width: 5),
//                                   GestureDetector(
//                                     onTap: () async {},
//                                     child: Container(
//                                       width: 40,
//                                       height: 40,
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(6),
//                                         border: Border.all(
//                                             color: Colors.white, width: 2),
//                                       ),
//                                       child: const Icon(
//                                         Icons.person,
//                                         color: Colors.red,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             const SizedBox(
//                               height: 10,
//                             ),
//                             if (provider.onTapOnMap &&
//                                 provider.mapMarkers.isNotEmpty)
//                               GestureDetector(
//                                 onTap: () {
//                                   showMarkersBottomSheet(context, provider);
//                                 },
//                                 child: Container(
//                                   height: 50,
//                                   width: MediaQuery.of(context).size.width,
//                                   padding: const EdgeInsets.all(12),
//                                   // margin: const EdgeInsets.all(8),
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(12),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.black.withOpacity(0.2),
//                                         blurRadius: 6,
//                                         spreadRadius: 2,
//                                         offset: Offset(0, 4),
//                                       ),
//                                     ],
//                                   ),
//                                   child: Text(
//                                     provider.mapMarkers.last.infoWindow.snippet
//                                         .toString(),
//                                     style: const TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w600,
//                                       color: Colors.black87,
//                                     ),
//                                     textAlign: TextAlign.center,
//                                   ),
//                                 ),
//                               ),
//                             if (provider.startController.text.isNotEmpty &&
//                                 provider.trips.isEmpty)
//                               const SizedBox(
//                                 height: 10,
//                               ),
//                             if (provider.startController.text.isNotEmpty &&
//                                 !provider.onTapOnMap)
//                               Container(
//                                 height: (provider.destinationCount + 1) *
//                                             (40 + 10) >
//                                         MediaQuery.of(context).size.height * 0.3
//                                     ? MediaQuery.of(context).size.height * 0.3
//                                     : (provider.destinationCount + 1) *
//                                         (40 + 10), // Item height + spacing
//                                 padding: const EdgeInsets.all(0),
//                                 child: ListView.builder(
//                                   padding: EdgeInsets.all(0),
//                                   itemCount: provider.destinationCount,
//                                   itemBuilder: (context, index) {
//                                     TextEditingController controller = provider
//                                             .destinationControllers.isNotEmpty
//                                         ? provider.destinationControllers[index]
//                                         : TextEditingController();

//                                     return Padding(
//                                       padding: const EdgeInsets.symmetric(
//                                           vertical: 5),
//                                       child: Row(
//                                         children: [
//                                           Expanded(
//                                             child: BrandedTextField(
//                                               height: 40,
//                                               controller: controller,
//                                               labelText: "Destination",
//                                               onTap: () {
//                                                 Navigator.of(context).push(
//                                                   MaterialPageRoute(
//                                                     builder: (context) {
//                                                       return SearchLocationScreen(
//                                                         controller: controller,
//                                                         isStart: false,
//                                                       );
//                                                     },
//                                                   ),
//                                                 ).then((value) async {
//                                                   Map<String, dynamic> data =
//                                                       jsonDecode(value);
//                                                   await provider
//                                                       .onSuggestionSelected(
//                                                           data['placeId'],
//                                                           data["isStart"],
//                                                           controller,
//                                                           context);
//                                                 });
//                                               },
//                                               prefix: Icon(Icons.location_on),
//                                             ),
//                                           ),
//                                           const SizedBox(width: 10),
//                                           if (index ==
//                                               provider.destinationCount - 1)
//                                             GestureDetector(
//                                               onTap: () {
//                                                 provider.increaseCount();
//                                               },
//                                               child: Container(
//                                                 width: 40,
//                                                 height: 40,
//                                                 decoration: BoxDecoration(
//                                                   borderRadius:
//                                                       BorderRadius.circular(6),
//                                                   border: Border.all(
//                                                       color: Colors.white,
//                                                       width: 2),
//                                                 ),
//                                                 child: const Icon(
//                                                   Icons.add,
//                                                   color: Colors.red,
//                                                 ),
//                                               ),
//                                             )
//                                           else
//                                             Container(
//                                               width: 40,
//                                               height: 40,
//                                               decoration: BoxDecoration(
//                                                 borderRadius:
//                                                     BorderRadius.circular(6),
//                                                 border: Border.all(
//                                                     color: Colors.white,
//                                                     width: 2),
//                                               ),
//                                               child: const Icon(
//                                                 Icons.close,
//                                                 color: Colors.red,
//                                               ),
//                                             ),
//                                         ],
//                                       ),
//                                     );
//                                   },
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     if (provider.trips.isNotEmpty && !provider.isTripStart)
//                       Positioned(
//                         top: MediaQuery.of(context).size.height * 0.5,
//                         left: 15,
//                         right: 10,
//                         bottom: 10,
//                         child: SingleChildScrollView(
//                           scrollDirection: Axis.horizontal,
//                           reverse: true,
//                           child: Row(
//                             children:
//                                 List.generate(provider.trips.length, (index) {
//                               TripModel tripModel = TripModel(
//                                 id: provider.trips[index].id,
//                                 userId: provider.trips[index].userId,
//                                 name: provider.trips[index].name,
//                                 startLocation:
//                                     provider.trips[index].startLocation,
//                                 destination: provider.trips[index].destination,
//                                 waypoints: List.from(
//                                     provider.trips[index].waypoints), // Copy
//                                 totalDistance:
//                                     provider.trips[index].totalDistance,
//                                 createdAt: provider.trips[index].createdAt,
//                                 routePoints: List.from(
//                                     provider.trips[index].routePoints), // Copy
//                                 markers: List.from(
//                                     provider.trips[index].markers), // Copy
//                                 weatherMarkers: List.from(provider
//                                     .trips[index].weatherMarkers), // Copy
//                                 animalKilled:
//                                     provider.trips[index].animalKilled,
//                                 animalSeen: provider.trips[index].animalSeen,
//                                 images: List.from(
//                                     provider.trips[index].images), // Copy
//                               );

//                               return GestureDetector(
//                                 onTap: () async {
//                                   provider.isSavedTrip = true;
//                                   provider.isSave = true;
//                                   provider.markers = tripModel.markers;
//                                   provider.distance = tripModel.totalDistance;
//                                   provider.selectedTripModel = tripModel;
//                                   provider.points = tripModel.routePoints;
//                                   provider.providerLetsHuntButton = true;
//                                   provider.path = tripModel.routePoints;
//                                   await provider.fetchRouteWithWaypoints(
//                                     tripModel.routePoints,
//                                   );
//                                 },
//                                 child: Card(
//                                   color: const Color.fromRGBO(255, 255, 255, 1),
//                                   child: SizedBox(
//                                     height: MediaQuery.of(context).size.height *
//                                         0.13, // Explicit height of the card
//                                     width: MediaQuery.of(context).size.width *
//                                         0.8, // Set the width for each card
//                                     child: Row(
//                                       children: [
//                                         const SizedBox(width: 10),
//                                         Expanded(
//                                           child: Padding(
//                                             padding: const EdgeInsets.all(12.0),
//                                             child: Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 Text(
//                                                   tripModel.name,
//                                                   style: const TextStyle(
//                                                       fontSize: 14,
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                       color: Color.fromRGBO(
//                                                           44, 51, 62, 1)),
//                                                   overflow:
//                                                       TextOverflow.ellipsis,
//                                                 ),
//                                                 Text(
//                                                   tripModel.startLocation,
//                                                   maxLines: 4,
//                                                   overflow:
//                                                       TextOverflow.ellipsis,
//                                                   style: const TextStyle(
//                                                       color: Colors.grey,
//                                                       fontSize: 12),
//                                                 )
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             }),
//                           ),
//                         ),
//                       ),
//                     if (provider.isSave) tripCard(provider, context),
//                   ],
//                 ),
//               );
//       },
//     );
//   }

//   Positioned tripCard(
//     MapProvider provider,
//     BuildContext context,
//   ) {
//     return Positioned(
//       bottom: 20,
//       left: 10,
//       right: 10,
//       child: Card(
//         elevation: 4,
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Image.asset("assets/images/distance_icons.png"),
//                   const SizedBox(width: 10),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         "Distance",
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       Text(
//                           "${provider.formatDistance(provider.distance, context)}"
//                           //"${provider.distance.toStringAsFixed(2)} ${Provider.of<UserViewModel>(context, listen: false).user.userUnit}",
//                           ),
//                     ],
//                   ),
//                   const Spacer(),
//                   IconButton(
//                       onPressed: () {
//                         provider.resetFields();
//                       },
//                       icon: Icon(Icons.close)),
//                 ],
//               ),
//               Row(
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           SizedBox(
//                             width: 200,
//                             child: Row(
//                               children: [
//                                 Text(
//                                   "${provider.weather.main.temp}\u00B0",
//                                   style: TextStyle(fontSize: 22),
//                                 ),
//                                 SizedBox(width: 5),
//                                 Text(
//                                     "(${provider.weather.weather.first.description})"),
//                               ],
//                             ),
//                           ),
//                           GestureDetector(
//                             onTap: () {
//                               showCustomDialog(context, provider);
//                             },
//                             child: const Text(
//                               'Break Time',
//                               style: TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                           )
//                         ],
//                       ),
//                       Text(
//                         DateFormat('MMM d yyyy').format(DateTime.now()),
//                         style: const TextStyle(fontSize: 15),
//                       ),
//                       Row(
//                         children: [
//                           const Icon(
//                             Icons.location_on_outlined,
//                             size: 13,
//                           ),
//                           const SizedBox(width: 8),
//                           Text(
//                             provider.weather.base,
//                             style: const TextStyle(fontSize: 12),
//                           ),
//                           SizedBox(
//                             width: MediaQuery.of(context).size.width * 0.37,
//                           ),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                   "Humidity: ${provider.weather.main.humidity}%"),
//                               Text(
//                                   "Pressure: ${provider.weather.main.pressure} "),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               if (provider.providerLetsHuntButton)
//                 SizedBox(
//                   height: 35,
//                   child: BrandedPrimaryButton(
//                     isEnabled: true,
//                     name: "Let's Hunt",
//                     onPressed: () {
//                       provider.context = context;
//                       provider.letsHunt();
//                     },
//                   ),
//                 ),
//               const SizedBox(height: 10),
//               if (!provider.isSavedTrip)
//                 SizedBox(
//                   height: 35,
//                   child: BrandedPrimaryButton(
//                     isEnabled: true,
//                     isUnfocus: true,
//                     name: "Save Trip",
//                     onPressed: () {
//                       provider.saveTrip(context);
//                     },
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField(
//     TextEditingController controller,
//     String label,
//     bool isStartField,
//     MapProvider provider,
//     Icon prefixIcon,
//     Icon suffixIcon,
//   ) {
//     return Row(
//       children: [
//         Expanded(
//           child: BrandedTextField(
//             height: 40,
//             controller: controller,
//             labelText: label,
//             onChanged: (value) =>
//                 provider.getPlaceSuggestions(value, isStartField),
//             prefix: prefixIcon,
//           ),
//         ),
//         const SizedBox(width: 5),
//         Container(
//           width: 40,
//           height: 40,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(6),
//             border: Border.all(color: Colors.white, width: 2),
//           ),
//           child: suffixIcon,
//         ),
//       ],
//     );
//   }

//   Widget _buildSuggestionsBox(List<dynamic> suggestions, bool isStartField,
//       MapProvider provider, BuildContext context) {
//     return Container(
//       height: MediaQuery.of(context).size.width,
//       color: Colors.white.withOpacity(.7),
//       child: ListView.builder(
//         shrinkWrap: true,
//         itemCount: suggestions.length,
//         itemBuilder: (context, index) {
//           return ListTile(
//             title: Text(suggestions[index]['description']),
//             onTap: () {
//               // provider.selectSuggestion(suggestions[index], isStartField);
//             },
//           );
//         },
//       ),
//     );
//   }
// }
