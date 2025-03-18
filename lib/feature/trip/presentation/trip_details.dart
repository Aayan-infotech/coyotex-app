import 'dart:convert';

import 'package:coyotex/core/utills/branded_primary_button.dart';
import 'package:coyotex/core/utills/media_widget.dart';
import 'package:coyotex/feature/map/data/trip_model.dart';
import 'package:coyotex/feature/map/presentation/map.dart';
import 'package:coyotex/feature/trip/presentation/trip_media_screen.dart';
import 'package:coyotex/feature/trip/view_model/trip_view_model.dart';
import 'package:coyotex/utils/graph.dart';
import 'package:coyotex/utils/pdf_view.dart';
import 'package:coyotex/utils/tem_graph.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../map/view_model/map_provider.dart';

class TripDetailsScreen extends StatefulWidget {
  TripModel tripModel;

  TripDetailsScreen({required this.tripModel, super.key});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  bool showAllStops = false;
  int totalSeenAnimal = 0;
  int totalKilledAnimal = 0;
  bool isLoading = false;
  String totalTravelTime = "";
  double speed = 40;

  String convertMinutesToHours(
    double distance,
    int totalTime, {
    bool isTotal = true,
  }) {
    double minutes = isTotal
        ? (totalTime + ((distance / 1000) / speed) * 60)
        : ((distance) / speed) * 60;

    int hours = minutes ~/ 60;
    int remainingMinutes =
        (minutes % 60).truncate(); // Ensures an integer value

    String hourText = hours > 0 ? "$hours hr" : "";
    String minuteText = remainingMinutes > 0 ? "$remainingMinutes min" : "";
    totalTravelTime =
        [hourText, minuteText].where((element) => element.isNotEmpty).join(" ");

    return [hourText, minuteText]
        .where((element) => element.isNotEmpty)
        .join(" ");
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TripViewModel>(context, listen: false);
    final mapProvider = Provider.of<MapProvider>(
      context,
    );
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
            child: CircularProgressIndicator.adaptive(
              backgroundColor: Colors.white,
            ),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.black,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.white),
              actions: [
                IconButton(
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                    // onPressed: () async {
                    //   setState(() {
                    //     isLoading = true;
                    //   });
                    //   await provider.generateTripPDF(
                    //     widget.tripModel.id,
                    //   );
                    //   setState(() {
                    //     isLoading = false;
                    //   });
                    // },
                    // In your existing IconButton's onPressed:
                    onPressed: () async {
                      setState(() => isLoading = true);
                      try {
                        final response =
                            await provider.generateTripPDF(widget.tripModel.id);
                        if (!mounted || response == null) return;

                        final Map<String, dynamic> responseData =
                            jsonDecode(response.body);

                        if (responseData["fileUrl"] != null) {
                          String pdfUrl =
                              responseData["fileUrl"]; // Extracting the URL
                          // final Uri uri = Uri.parse(pdfUrl);
                          // if (await canLaunchUrl(uri)) {
                          //   await launchUrl(uri,
                          //       mode: LaunchMode.externalApplication);
                          // } else {
                          //   // throw "Could not launch $url";
                          // }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PDFViewerScreen(pdfUrl: pdfUrl),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Failed to generate PDF')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}')),
                        );
                      } finally {
                        if (mounted) setState(() => isLoading = false);
                      }
                    }),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });
                    await provider.deleteTrip(widget.tripModel.id, context);
                    setState(() {
                      isLoading = false;
                    });
                  },
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return MarkerMediaScreen(tripModel: widget.tripModel);
                    }));
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: Icon(
                      Icons.photo_library,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
              title: Text(
                '${widget.tripModel.name}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 20),
              ),
              centerTitle: true,
            ),
            persistentFooterButtons: [
              BrandedPrimaryButton(
                  isEnabled: true,
                  name: (widget.tripModel.tripStatus == "created")
                      ? "Start Trip"
                      : "Restart Trip",
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });
                    final mapProvider =
                        Provider.of<MapProvider>(context, listen: false);
                    TripModel tripModel = TripModel(
                      tripStatus: widget.tripModel.tripStatus,
                      id: widget.tripModel.id,
                      userId: widget.tripModel.userId,
                      name: widget.tripModel.name,
                      startLocation: widget.tripModel.startLocation,
                      destination: widget.tripModel.destination,
                      waypoints: List.from(widget.tripModel.waypoints), // Copy
                      totalDistance: widget.tripModel.totalDistance,
                      createdAt: widget.tripModel.createdAt,
                      routePoints:
                          List.from(widget.tripModel.routePoints), // Copy
                      markers: List.from(widget.tripModel.markers), // Copy
                      weatherMarkers:
                          List.from(widget.tripModel.weatherMarkers), // Copy
                      animalKilled: widget.tripModel.animalKilled,
                      animalSeen: widget.tripModel.animalSeen,
                      images: List.from(widget.tripModel.images), // Copy
                    );
                    mapProvider.isSavedTrip = true;
                    mapProvider.isSave = true;
                    mapProvider.liveTripMarker = tripModel.markers;
                    mapProvider.isStartavigation = true;
                    mapProvider.markers = tripModel.markers;
                    mapProvider.distance = tripModel.totalDistance;
                    mapProvider.selectedTripModel = tripModel;
                    mapProvider.points = tripModel.routePoints;
                    mapProvider.providerLetsHuntButton = true;
                    mapProvider.path = tripModel.routePoints;
                    mapProvider.onTapOnMap = false;
                    mapProvider.isRestart =
                        (widget.tripModel.tripStatus == "created")
                            ? false
                            : true;
                    await mapProvider.fetchRouteWithWaypoints(
                      tripModel.routePoints,
                    );

                    setState(() {
                      isLoading = false;
                    });
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return MapScreen(
                        isRestart: true,
                      );
                    }));
                  })
            ],
            body: Container(
              color: Colors.black,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          ...widget.tripModel.markers
                              .take(showAllStops
                                  ? widget.tripModel.markers.length
                                  : 3) // Modified take()
                              .map((item) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 10),
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.red,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 10,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      item.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Color.fromRGBO(55, 65, 81, 1),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                          if (widget.tripModel.markers.length > 3 &&
                              !showAllStops) // Updated condition
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  showAllStops = true;
                                });
                              },
                              child: const Text(
                                'Show More',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Highlights',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Divider(color: Colors.grey.withOpacity(.4)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildHighlightCard(
                              'Coyote Killed', totalKilledAnimal.toString()),
                          _buildHighlightCard(
                              'Coyote Seen', totalSeenAnimal.toString()),
                        ],
                      ),
                      SizedBox(height: 16),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Trip Analysis',
                            style: TextStyle(
                              color: Color.fromRGBO(255, 255, 255, 1),
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.45,
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(255, 255, 255, 1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Image.asset(
                                            "assets/images/non_sleep_icon.png"),
                                        const Text(
                                          "Total Time",
                                          style: TextStyle(
                                              color:
                                                  Color.fromRGBO(36, 36, 37, 1),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Padding(
                                      padding: EdgeInsets.only(left: 20),
                                      child: Text(
                                        totalTravelTime, // "6 hr 20 min",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.45,
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(255, 255, 255, 1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(left: 20),
                                      child: Text(
                                        "Weather",
                                        style: TextStyle(
                                            color:
                                                Color.fromRGBO(36, 36, 37, 1),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Text(
                                          widget.tripModel.weatherMarkers
                                                  .isEmpty
                                              ? "Clear Sky"
                                              : widget
                                                  .tripModel
                                                  .weatherMarkers
                                                  .first
                                                  .weather
                                                  .weatherDescription,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                          ),
                                        ),
                                        if (widget.tripModel.weatherMarkers
                                            .isNotEmpty)
                                          Image.network(
                                            'https://openweathermap.org/img/wn/${widget.tripModel.weatherMarkers.first.weather.weatherIcon}@2x.png',
                                            width: 40,
                                            height: 40,
                                          ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 16),
                          Expanded(
                              child: Container(
                            height: MediaQuery.of(context).size.height * 0.18,
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(255, 255, 255, 1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Image.asset("assets/images/walk_icon.png"),
                                    const Text(
                                      "Distance",
                                      style: TextStyle(
                                          color: Color.fromRGBO(36, 36, 37, 1),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Center(
                                  child: Text(
                                    mapProvider.formatDistance(
                                        widget.tripModel.totalDistance,
                                        context),
                                    // '${widget.tripModel.totalDistance.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )),
                        ],
                      ),
                      SizedBox(height: 16),
                      SizedBox(height: 16),
                      const Text(
                        'Your Hunting',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 30),
                      WindDirectionChart(markers: widget.tripModel.markers),
                      const SizedBox(height: 30),
                      TemperatureChart(markers: widget.tripModel.markers),
                    ],
                  ),
                ),
              ),
            ),
          );
  }

  Widget _buildStopInfo(String title, {bool isHighlighted = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline_sharp,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightCard(String title, String value) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.08,
      width: MediaQuery.of(context).size.width * 0.4,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Color.fromRGBO(249, 249, 249, 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
                color: Color.fromRGBO(83, 82, 82, 1),
                fontSize: 12,
                fontWeight: FontWeight.w500),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            value,
            style: TextStyle(
              color: Color.fromRGBO(29, 27, 27, 1),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String unit,
      {bool isCircular = false}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 8),
          isCircular
              ? Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 60,
                        width: 60,
                        child: CircularProgressIndicator(
                          value: 0.8,
                          backgroundColor: Colors.grey[800],
                          color: Colors.red,
                          strokeWidth: 6,
                        ),
                      ),
                      Text(
                        '$value $unit',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : Text(
                  '$value $unit',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
        ],
      ),
    );
  }
}
