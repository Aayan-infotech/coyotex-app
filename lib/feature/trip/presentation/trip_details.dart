// import 'dart:convert';

// import 'package:coyotex/core/utills/branded_primary_button.dart';
// import 'package:coyotex/core/utills/media_widget.dart';
// import 'package:coyotex/feature/map/data/trip_model.dart';
// import 'package:coyotex/feature/map/presentation/map.dart';
// import 'package:coyotex/feature/trip/presentation/trip_media_screen.dart';
// import 'package:coyotex/feature/trip/view_model/trip_view_model.dart';
// import 'package:coyotex/utils/graph.dart';
// import 'package:coyotex/utils/pdf_view.dart';
// import 'package:coyotex/utils/tem_graph.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../../map/view_model/map_provider.dart';

// class TripDetailsScreen extends StatefulWidget {
//   TripModel tripModel;

//   TripDetailsScreen({required this.tripModel, super.key});

//   @override
//   State<TripDetailsScreen> createState() => _TripDetailsScreenState();
// }

// class _TripDetailsScreenState extends State<TripDetailsScreen> {
//   bool showAllStops = false;
//   int totalSeenAnimal = 0;
//   int totalKilledAnimal = 0;
//   bool isLoading = false;
//   String totalTravelTime = "";
//   String totalTripTime = "";
//   double speed = 40;

//   String convertMinutesToHours(
//     double distance,
//     int totalTime, {
//     bool isTotal = true,
//   }) {
//     double tripMinutes = ((distance / 1000) / speed) * 60;
//     ;
//     double minutes = isTotal
//         ? (totalTime + ((distance / 1000) / speed) * 60)
//         : ((distance) / speed) * 60;

//     int hours = minutes ~/ 60;
//     int tripHour = tripMinutes ~/ 60;
//     int remainingMinutes = (minutes % 60).truncate();
//     int remainingTripMinutes =
//         (tripMinutes % 60).truncate(); // Ensures an integer value

//     String hourText = hours > 0 ? "$hours hr" : "";
//     String tripHourText = tripHour > 0 ? "$tripHour hr" : "";
//     String minuteText = remainingMinutes > 0 ? "$remainingMinutes min" : "";
//     String tripMinuteText =
//         remainingTripMinutes > 0 ? "$remainingTripMinutes min" : "";
//     totalTravelTime =
//         [hourText, minuteText].where((element) => element.isNotEmpty).join(" ");
//     totalTripTime = [tripHourText, tripMinuteText]
//         .where((element) => element.isNotEmpty)
//         .join(" ");

//     return [hourText, minuteText]
//         .where((element) => element.isNotEmpty)
//         .join(" ");
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<TripViewModel>(context, listen: false);
//     final mapProvider = Provider.of<MapProvider>(
//       context,
//     );
//     int totalTime = 0;
//     totalKilledAnimal = 0;
//     totalSeenAnimal = 0;
//     for (var item in widget.tripModel.markers) {
//       totalTime += item.duration;
//       totalKilledAnimal += int.parse(item.animalKilled);
//       totalSeenAnimal += int.parse(item.animalSeen);
//     }

//     totalTravelTime =
//         convertMinutesToHours(widget.tripModel.totalDistance, totalTime);
//     return isLoading
//         ? const Center(
//             child: CircularProgressIndicator.adaptive(
//               backgroundColor: Colors.white,
//             ),
//           )
//         : Scaffold(
//             appBar: AppBar(
//               backgroundColor: Colors.black,
//               elevation: 0,
//               iconTheme: const IconThemeData(color: Colors.white),
//               actions: [
//                 IconButton(
//                     icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
//                     // onPressed: () async {
//                     //   setState(() {
//                     //     isLoading = true;
//                     //   });
//                     //   await provider.generateTripPDF(
//                     //     widget.tripModel.id,
//                     //   );
//                     //   setState(() {
//                     //     isLoading = false;
//                     //   });
//                     // },
//                     // In your existing IconButton's onPressed:
//                     onPressed: () async {
//                       setState(() => isLoading = true);
//                       try {
//                         final response =
//                             await provider.generateTripPDF(widget.tripModel.id);
//                         print(response!.statusCode);
//                         if (!mounted) return;

//                         final Map<String, dynamic> responseData =
//                             jsonDecode(response.body);

//                         if (responseData["fileUrl"] != null) {
//                           String pdfUrl =
//                               responseData["fileUrl"]; // Extracting the URL
//                           // final Uri uri = Uri.parse(pdfUrl);
//                           // if (await canLaunchUrl(uri)) {
//                           //   await launchUrl(uri,
//                           //       mode: LaunchMode.externalApplication);
//                           // } else {
//                           //   // throw "Could not launch $url";
//                           // }
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) =>
//                                   PDFViewerScreen(pdfUrl: pdfUrl),
//                             ),
//                           );
//                         } else {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                                 content: Text('Failed to generate PDF')),
//                           );
//                         }
//                       } catch (e) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(content: Text('Error: ${e.toString()}')),
//                         );
//                       } finally {
//                         if (mounted) setState(() => isLoading = false);
//                       }
//                     }),
//                 IconButton(
//                   icon: const Icon(Icons.delete_outline, color: Colors.white),
//                   onPressed: () async {
//                     setState(() {
//                       isLoading = true;
//                     });
//                     await provider.deleteTrip(widget.tripModel.id, context);
//                     setState(() {
//                       isLoading = false;
//                     });
//                   },
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.of(context)
//                         .push(MaterialPageRoute(builder: (context) {
//                       return MarkerMediaScreen(tripModel: widget.tripModel);
//                     }));
//                   },
//                   child: const Padding(
//                     padding: EdgeInsets.only(right: 20),
//                     child: Icon(
//                       Icons.photo_library,
//                       color: Colors.white,
//                     ),
//                   ),
//                 )
//               ],
//               title: Text(
//                 widget.tripModel.name,
//                 style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w700,
//                     fontSize: 20),
//               ),
//               centerTitle: true,
//             ),
//             persistentFooterButtons: [
//               BrandedPrimaryButton(
//                   isEnabled: true,
//                   name: (widget.tripModel.tripStatus == "created")
//                       ? "Start Trip"
//                       : "Restart Trip",
//                   onPressed: () async {
//                     setState(() {
//                       isLoading = true;
//                     });
//                     final mapProvider =
//                         Provider.of<MapProvider>(context, listen: false);
//                     mapProvider.resetFields();
//                     TripModel tripModel = TripModel(
//                       tripStatus: widget.tripModel.tripStatus,
//                       id: widget.tripModel.id,
//                       userId: widget.tripModel.userId,
//                       name: widget.tripModel.name,
//                       startLocation: widget.tripModel.startLocation,
//                       destination: widget.tripModel.destination,
//                       waypoints: List.from(widget.tripModel.waypoints), // Copy
//                       totalDistance: widget.tripModel.totalDistance,
//                       createdAt: widget.tripModel.createdAt,
//                       routePoints:
//                           List.from(widget.tripModel.routePoints), // Copy
//                       markers: List.from(widget.tripModel.markers), // Copy
//                       weatherMarkers:
//                           List.from(widget.tripModel.weatherMarkers), // Copy
//                       animalKilled: widget.tripModel.animalKilled,
//                       animalSeen: widget.tripModel.animalSeen,
//                       images: List.from(widget.tripModel.images), // Copy
//                     );
//                     mapProvider.isSavedTrip = true;
//                     mapProvider.isSave = true;
//                     mapProvider.liveTripMarker = tripModel.markers;
//                     mapProvider.isStartavigation = true;
//                     mapProvider.markers = tripModel.markers;
//                     mapProvider.distance = tripModel.totalDistance;
//                     mapProvider.selectedTripModel = tripModel;
//                     mapProvider.points = tripModel.routePoints;
//                     mapProvider.providerLetsHuntButton = true;
//                     mapProvider.path = tripModel.routePoints;
//                     mapProvider.onTapOnMap = false;
//                     mapProvider.isRestart =
//                         (widget.tripModel.tripStatus == "created")
//                             ? false
//                             : true;

//                     await mapProvider.fetchRouteWithWaypoints(
//                       tripModel.routePoints,
//                     );
//                     setState(() {
//                       isLoading = false;
//                     });

//                     Navigator.of(context)
//                         .push(MaterialPageRoute(builder: (context) {
//                       return MapScreen(
//                         isRestart: true,
//                       );
//                     })).then((value) {
//                       setState(() {
//                         isLoading = false;
//                       });
//                     });
//                   }),
//             ],
//             body: Container(
//               color: Colors.black,
//               child: SingleChildScrollView(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Column(
//                         children: [
//                           ...widget.tripModel.markers
//                               .take(showAllStops
//                                   ? widget.tripModel.markers.length
//                                   : 3) // Modified take()
//                               .map((item) {
//                             return Padding(
//                               padding: const EdgeInsets.symmetric(vertical: 5),
//                               child: Container(
//                                 height: 40,
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child: Row(
//                                   children: [
//                                     const SizedBox(width: 10),
//                                     Container(
//                                       padding: const EdgeInsets.all(5),
//                                       decoration: const BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         color: Colors.red,
//                                       ),
//                                       child: const Icon(
//                                         Icons.check,
//                                         color: Colors.white,
//                                         size: 10,
//                                       ),
//                                     ),
//                                     const SizedBox(width: 10),
//                                     Text(
//                                       item.title,
//                                       style: const TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 14,
//                                         color: Color.fromRGBO(55, 65, 81, 1),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           }),
//                           if (widget.tripModel.markers.length > 3 &&
//                               !showAllStops) // Updated condition
//                             TextButton(
//                               onPressed: () {
//                                 setState(() {
//                                   showAllStops = true;
//                                 });
//                               },
//                               child: const Text(
//                                 'Show More',
//                                 style: TextStyle(color: Colors.blue),
//                               ),
//                             ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       const Align(
//                         alignment: Alignment.center,
//                         child: Text(
//                           'Highlights',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.w800,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ),
//                       Divider(color: Colors.grey.withOpacity(.4)),
//                       const SizedBox(height: 8),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           _buildHighlightCard(
//                               'Coyote Killed', totalKilledAnimal.toString()),
//                           _buildHighlightCard(
//                               'Coyote Seen', totalSeenAnimal.toString()),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       const Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'Trip Analysis',
//                             style: TextStyle(
//                               color: Color.fromRGBO(255, 255, 255, 1),
//                               fontWeight: FontWeight.w800,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       Row(
//                         children: [
//                           Column(
//                             children: [
//                               Container(
//                                 width: MediaQuery.of(context).size.width * 0.45,
//                                 padding: const EdgeInsets.all(8),
//                                 decoration: BoxDecoration(
//                                   color: const Color.fromRGBO(255, 255, 255, 1),
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Row(
//                                       children: [
//                                         Image.asset(
//                                             "assets/images/non_sleep_icon.png"),
//                                         const Text(
//                                           "Total Time",
//                                           style: TextStyle(
//                                               color:
//                                                   Color.fromRGBO(36, 36, 37, 1),
//                                               fontSize: 12,
//                                               fontWeight: FontWeight.w800),
//                                         ),
//                                       ],
//                                     ),
//                                     const SizedBox(height: 8),
//                                     Padding(
//                                       padding: const EdgeInsets.only(left: 20),
//                                       child: Text(
//                                         totalTravelTime, // "6 hr 20 min",
//                                         style: const TextStyle(
//                                           color: Colors.black,
//                                           fontWeight: FontWeight.w400,
//                                           fontSize: 14,
//                                         ),
//                                       ),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                               const SizedBox(
//                                 height: 10,
//                               ),
//                               Container(
//                                 width: MediaQuery.of(context).size.width * 0.45,
//                                 padding: const EdgeInsets.all(8),
//                                 decoration: BoxDecoration(
//                                   color: const Color.fromRGBO(255, 255, 255, 1),
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Row(
//                                       children: [
//                                         Image.asset(
//                                             "assets/images/non_sleep_icon.png"),
//                                         const Text(
//                                           "Trip Time",
//                                           style: TextStyle(
//                                               color:
//                                                   Color.fromRGBO(36, 36, 37, 1),
//                                               fontSize: 12,
//                                               fontWeight: FontWeight.w800),
//                                         ),
//                                       ],
//                                     ),
//                                     const SizedBox(height: 8),
//                                     Padding(
//                                       padding: const EdgeInsets.only(left: 20),
//                                       child: Text(
//                                         totalTripTime, // "6 hr 20 min",
//                                         style: const TextStyle(
//                                           color: Colors.black,
//                                           fontWeight: FontWeight.w400,
//                                           fontSize: 14,
//                                         ),
//                                       ),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(width: 16),
//                           Expanded(
//                               child: Container(
//                             height: MediaQuery.of(context).size.height * 0.19,
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: const Color.fromRGBO(255, 255, 255, 1),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   children: [
//                                     Image.asset("assets/images/walk_icon.png"),
//                                     const Text(
//                                       "Distance",
//                                       style: TextStyle(
//                                           color: Color.fromRGBO(36, 36, 37, 1),
//                                           fontSize: 12,
//                                           fontWeight: FontWeight.w800),
//                                     ),
//                                   ],
//                                 ),
//                                 SizedBox(
//                                   height: 5,
//                                 ),
//                                 Center(
//                                   child: Text(
//                                     mapProvider.formatDistance(
//                                         widget.tripModel.totalDistance,
//                                         context),
//                                     // '${widget.tripModel.totalDistance.toStringAsFixed(2)}',
//                                     style: const TextStyle(
//                                       color: Colors.black,
//                                       fontWeight: FontWeight.w400,
//                                       fontSize: 14,
//                                     ),
//                                   ),
//                                 ),
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     const Padding(
//                                       padding: EdgeInsets.only(left: 20),
//                                       child: Text(
//                                         "Weather",
//                                         style: TextStyle(
//                                             color:
//                                                 Color.fromRGBO(36, 36, 37, 1),
//                                             fontSize: 12,
//                                             fontWeight: FontWeight.w800),
//                                       ),
//                                     ),
//                                     const SizedBox(height: 8),
//                                     Row(
//                                       children: [
//                                         const SizedBox(
//                                           width: 20,
//                                         ),
//                                         Text(
//                                           widget.tripModel.weatherMarkers
//                                                   .isEmpty
//                                               ? "Clear Sky"
//                                               : widget
//                                                   .tripModel
//                                                   .weatherMarkers
//                                                   .first
//                                                   .weather
//                                                   .weatherDescription,
//                                           style: const TextStyle(
//                                             color: Colors.black,
//                                             fontWeight: FontWeight.w400,
//                                             fontSize: 14,
//                                           ),
//                                         ),
//                                         if (widget.tripModel.weatherMarkers
//                                             .isNotEmpty)
//                                           Image.network(
//                                             'https://openweathermap.org/img/wn/${widget.tripModel.weatherMarkers.first.weather.weatherIcon}@2x.png',
//                                             width: 40,
//                                             height: 40,
//                                           ),
//                                       ],
//                                     )
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           )),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       const SizedBox(height: 16),
//                       const Text(
//                         'Your Hunting',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 18,
//                         ),
//                       ),
//                       const SizedBox(height: 30),
//                       WindDirectionChart(markers: widget.tripModel.markers),
//                       const SizedBox(height: 30),
//                       TemperatureChart(markers: widget.tripModel.markers),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           );
//   }

//   Widget _buildStopInfo(String title) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 5.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(4),
//                 decoration: const BoxDecoration(
//                   color: Colors.red,
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.check_circle_outline_sharp,
//                   color: Colors.white,
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 title,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildHighlightCard(String title, String value) {
//     return Container(
//       height: MediaQuery.of(context).size.height * 0.08,
//       width: MediaQuery.of(context).size.width * 0.4,
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: const Color.fromRGBO(249, 249, 249, 1),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//                 color: Color.fromRGBO(83, 82, 82, 1),
//                 fontSize: 12,
//                 fontWeight: FontWeight.w500),
//           ),
//           const SizedBox(
//             height: 5,
//           ),
//           Text(
//             value,
//             style: const TextStyle(
//               color: Color.fromRGBO(29, 27, 27, 1),
//               fontWeight: FontWeight.bold,
//               fontSize: 14,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatCard(String title, String value, String unit,
//       {bool isCircular = false}) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.grey[900],
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               color: Colors.white70,
//               fontSize: 14,
//             ),
//           ),
//           const SizedBox(height: 8),
//           isCircular
//               ? Center(
//                   child: Stack(
//                     alignment: Alignment.center,
//                     children: [
//                       SizedBox(
//                         height: 60,
//                         width: 60,
//                         child: CircularProgressIndicator(
//                           value: 0.8,
//                           backgroundColor: Colors.grey[800],
//                           color: Colors.red,
//                           strokeWidth: 6,
//                         ),
//                       ),
//                       Text(
//                         '$value $unit',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//               : Text(
//                   '$value $unit',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 18,
//                   ),
//                 ),
//         ],
//       ),
//     );
//   }
// }
import 'dart:convert';
import 'dart:io';

import 'package:coyotex/core/services/call_halper.dart';
import 'package:coyotex/core/utills/branded_primary_button.dart';
import 'package:coyotex/feature/map/data/trip_model.dart';
import 'package:coyotex/feature/map/presentation/map.dart';
import 'package:coyotex/feature/trip/presentation/trip_media_screen.dart';
import 'package:coyotex/feature/trip/view_model/trip_view_model.dart';
import 'package:coyotex/utils/graph.dart';
import 'package:coyotex/utils/humidity_graph.dart';
import 'package:coyotex/utils/pdf_view.dart';
import 'package:coyotex/utils/pressure_graph.dart';
import 'package:coyotex/utils/tem_graph.dart';
import 'package:coyotex/utils/wind_speed.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../map/view_model/map_provider.dart';

class TripDetailsScreen extends StatefulWidget {
  final TripModel tripModel;

  const TripDetailsScreen({required this.tripModel, super.key});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  bool showAllStops = false;
  int totalSeenAnimal = 0;
  int totalKilledAnimal = 0;
  bool isLoading = false;
  String totalTravelTime = "";
  String totalTripTime = "";
  double speed = 40;

  String convertMinutesToHours(
    double distance,
    int totalTime, {
    bool isTotal = true,
  }) {
    double tripMinutes = ((distance / 1000) / speed) * 60;
    double minutes = isTotal
        ? (totalTime + ((distance / 1000) / speed) * 60)
        : ((distance) / speed) * 60;

    int hours = minutes ~/ 60;
    int tripHour = tripMinutes ~/ 60;
    int remainingMinutes = (minutes % 60).truncate();
    int remainingTripMinutes = (tripMinutes % 60).truncate();

    String hourText = hours > 0 ? "$hours hr" : "";
    String tripHourText = tripHour > 0 ? "$tripHour hr" : "";
    String minuteText = remainingMinutes > 0 ? "$remainingMinutes min" : "";
    String tripMinuteText =
        remainingTripMinutes > 0 ? "$remainingTripMinutes min" : "";
    totalTravelTime =
        [hourText, minuteText].where((element) => element.isNotEmpty).join(" ");
    totalTripTime = [tripHourText, tripMinuteText]
        .where((element) => element.isNotEmpty)
        .join(" ");

    return [hourText, minuteText]
        .where((element) => element.isNotEmpty)
        .join(" ");
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TripViewModel>(context, listen: false);
    final mapProvider = Provider.of<MapProvider>(context);

    int totalTime = 0;
    totalKilledAnimal = 0;
    totalSeenAnimal = 0;
    for (var item in widget.tripModel.markers) {
      totalTime += item.duration;
      totalKilledAnimal += int.parse(item.animalKilled);
      totalSeenAnimal += int.parse(item.animalSeen);
    }

    totalTravelTime =
        convertMinutesToHours(widget.tripModel.totalDistance, totalTime);

    return isLoading
        ? const Center(
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red)))
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.black,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              actions: [
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                  onPressed: () async {
                    setState(() => isLoading = true);
                    try {
                      final response =
                          await provider.generateTripPDF(widget.tripModel.id);
                      if (!mounted) return;
                      final Map<String, dynamic> responseData =
                          jsonDecode(response!.body);
                      if (responseData["fileUrl"] != null) {
                        String pdfUrl = responseData["fileUrl"];
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PDFViewerScreen(pdfUrl: pdfUrl),
                          ),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => isLoading = false);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                  onPressed: () async {
                    setState(() => isLoading = true);
                    await provider.deleteTrip(widget.tripModel.id, context);
                    setState(() => isLoading = false);
                  },
                ),
                IconButton(
                    icon: const Icon(Icons.photo_library, color: Colors.white),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MarkerMediaScreen(
                                tripModel: widget.tripModel)))),
              ],
              title: Text(
                widget.tripModel.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  letterSpacing: 1.2,
                ),
              ),
              centerTitle: true,
            ),
            persistentFooterButtons: [
              BrandedPrimaryButton(
                isEnabled: true,
                name: widget.tripModel.tripStatus == "created"
                    ? "Start Trip"
                    : "Restart Trip",
                onPressed: () async {
                  setState(() => isLoading = true);
                  final mapProvider =
                      Provider.of<MapProvider>(context, listen: false);
                  mapProvider.resetFields();
                  TripModel tripModel = TripModel(
                    id: widget.tripModel.id,
                    userId: widget.tripModel.userId,
                    name: widget.tripModel.name,
                    startLocation: widget.tripModel.startLocation,
                    destination: widget.tripModel.destination,
                    waypoints: List.from(widget.tripModel.waypoints),
                    totalDistance: widget.tripModel.totalDistance,
                    createdAt: widget.tripModel.createdAt,
                    routePoints: List.from(widget.tripModel.routePoints),
                    markers: List.from(widget.tripModel.markers),
                    weatherMarkers: List.from(widget.tripModel.weatherMarkers),
                    animalKilled: widget.tripModel.animalKilled,
                    animalSeen: widget.tripModel.animalSeen,
                    images: List.from(widget.tripModel.images),
                    tripStatus: widget.tripModel.tripStatus,
                  );
                  mapProvider
                    ..isSavedTrip = true
                    ..isSave = true
                    ..liveTripMarker = tripModel.markers
                    ..isStartavigation = true
                    ..markers = tripModel.markers
                    ..distance = tripModel.totalDistance
                    ..selectedTripModel = tripModel
                    ..points = tripModel.routePoints
                    ..providerLetsHuntButton = true
                    ..path = tripModel.routePoints
                    ..onTapOnMap = false
                    ..isRestart = widget.tripModel.tripStatus != "created";

                  await mapProvider
                      .fetchRouteWithWaypoints(tripModel.routePoints);
                  if (mounted) {
                    Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    MapScreen(isRestart: true)))
                        .then((_) => setState(() => isLoading = false));
                  }
                },
              )
            ],
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black, Color(0xFF1a1a1a)],
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStopsSection(context),
                    const SizedBox(height: 24),
                    _buildHighlightsSection(),
                    const SizedBox(height: 24),
                    _buildTripAnalysisSection(mapProvider),
                    const SizedBox(height: 24),
                    _buildChartsSection(),
                  ],
                ),
              ),
            ),
          );
  }

  // Future<void> downloadAndOpenGPXFile(String tripId) async {
  //   try {
  //     String url = "${CallHelper.baseUrl}api/trips/${tripId}/gpx";
  //     Dio dio = Dio();

  //     // Get the directory to store the file
  //     Directory directory = await getApplicationDocumentsDirectory();
  //     String filePath = "${directory.path}/trip_${widget.tripModel.name}.gpx";

  //     // Download file
  //     await dio.download(url, filePath);

  //     print("File downloaded at: $filePath");

  //     // Open the downloaded file
  //     OpenFilex.open(filePath);
  //   } catch (e) {
  //     print("Download failed: $e");
  //   }
  // }
  Future<void> downloadAndOpenGPXFile(String tripId) async {
    try {
      setState(() {
        isLoading = true;
      });

      String url = "${CallHelper.baseUrl}api/trips/${tripId}/gpx";
      Dio dio = Dio();

      // Get the directory to store the file
      Directory directory = await getApplicationDocumentsDirectory();
      String filePath = "${directory.path}/trip_${widget.tripModel.name}.gpx";

      // Download file with response handling
      Response response = await dio.download(
        url,
        filePath,
        options: Options(
          followRedirects: false,
          validateStatus: (status) {
            return status != null && status < 500; // Accept status < 500
          },
        ),
      );

      if (response.statusCode == 200) {
        print("File downloaded at: $filePath");
        OpenFilex.open(filePath);
      } else {
        String errorMessage =
            "Download failed: ${response.statusCode} - ${response.statusMessage}";
        print(errorMessage);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(errorMessage, style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print("Download error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Error: $e", style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildStopsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Markers',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              IconButton(
                  onPressed: () async {
                    await downloadAndOpenGPXFile(widget.tripModel.id);
                    // final tripProvider =
                    //     Provider.of<TripViewModel>(context, listen: false);
                    // var response =
                    //     await tripProvider.generateGpxUrl(widget.tripModel.id);
                    // if (response.success) {}
                  },
                  icon: Icon(
                    Icons.save_alt,
                    color: Colors.red,
                  ))
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...widget.tripModel.markers
            .take(showAllStops ? widget.tripModel.markers.length : 3)
            .map((item) => _buildStopItem(item)),
        if (widget.tripModel.markers.length > 3 && !showAllStops)
          Center(
            child: TextButton(
              onPressed: () => setState(() => showAllStops = true),
              child: const Text(
                'Show More Stops',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStopItem(MarkerData item) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.red.withOpacity(0.3))),
      child: ListTile(
        leading: const Icon(Icons.location_pin, color: Colors.red),
        title: Text(
          item.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        minLeadingWidth: 0,
      ),
    );
  }

  Widget _buildHighlightsSection() {
    return Column(
      children: [
        const Center(
          child: Text(
            'Hunting Highlights',
            style: TextStyle(
              color: Colors.red,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildHighlightCard(
                'Skull', totalKilledAnimal.toString(), Icons.dangerous),
            _buildHighlightCard(
                'Eye', totalSeenAnimal.toString(), Icons.remove_red_eye),
          ],
        ),
      ],
    );
  }

  Widget _buildHighlightCard(String title, String value, IconData icon) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.red, size: 30),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripAnalysisSection(MapProvider mapProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(
            'Trip Metrics',
            style: TextStyle(
              color: Colors.red,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: Icons.timer,
                title: "Total Time",
                value: totalTravelTime,
                subtitle: "Including stops",
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.speed,
                title: "Trip Time",
                value: totalTripTime,
                subtitle: "Moving time",
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: Icons.directions_walk,
                title: "Distance",
                value: mapProvider.formatDistance(
                    widget.tripModel.totalDistance, context),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildWeatherCard(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    String subtitle = '',
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.cloud, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text(
                "Weather",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (widget.tripModel.weatherMarkers.isNotEmpty)
            Row(
              children: [
                Text(
                  widget.tripModel.weatherMarkers.first.weather
                      .weatherDescription,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 5),
                Image.network(
                  'https://openweathermap.org/img/wn/${widget.tripModel.weatherMarkers.first.weather.weatherIcon}@2x.png',
                  width: 40,
                  height: 40,
                ),
              ],
            )
          else
            const Text(
              "Clear Sky",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChartsSection() {
    return Column(
      children: [
        const Text(
          'Hunting Analytics',
          style: TextStyle(
            color: Colors.red,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          //  padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(15),
          ),
          child: WindDirectionChart(markers: widget.tripModel.markers),
        ),
        const SizedBox(height: 24),
        Container(
          // padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(15),
          ),
          child: TemperatureChart(markers: widget.tripModel.markers),
        ),
        const SizedBox(height: 24),
        Container(
          // padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(15),
          ),
          child: HumidityChart(markers: widget.tripModel.markers),
        ),
        const SizedBox(height: 24),
        Container(
          // padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(15),
          ),
          child: PressureChart(markers: widget.tripModel.markers),
        ),
        const SizedBox(height: 24),
        Container(
          // padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(15),
          ),
          child: WindSpeedChart(markers: widget.tripModel.markers),
        ),
      ],
    );
  }
}
