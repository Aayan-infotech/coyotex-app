import 'dart:convert';
import 'dart:io';

import 'package:coyotex/core/services/call_halper.dart';
import 'package:coyotex/core/utills/branded_primary_button.dart';
import 'package:coyotex/feature/map/data/trip_model.dart';
import 'package:coyotex/feature/map/presentation/map.dart';
import 'package:coyotex/feature/map/presentation/show_duration_and_animal_details_sheet.dart';
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

import '../../../core/utills/constant.dart';
import '../../../core/utills/shared_pref.dart';
import '../../../utils/app_dialogue_box.dart';
import '../../map/view_model/map_provider.dart';
import '../../profile/presentation/subscription_details_screen.dart';

class TripDetailsScreen extends StatefulWidget {
  final TripModel tripModel;

  const TripDetailsScreen({required this.tripModel, super.key});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  var isSubscription = SharedPrefUtil.getValue(hasSubscription, false) as bool;
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
          isLocation: true,
          mapProvider: provider,
        );
      },
    );
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
                  if (isSubscription) {
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
                      weatherMarkers:
                          List.from(widget.tripModel.weatherMarkers),
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
                  } else {
                    AppDialog.showErrorDialog(
                      context,
                      "You need an active subscription to use this feature.",
                      () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SubscriptionDetailsScreen(),
                          ),
                        );
                      },
                    );
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

      String url = "${CallHelper.baseUrl}trips/${tripId}/gpx";
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
    return GestureDetector(
      onTap: () {
        final mapProvider = Provider.of<MapProvider>(context, listen: false);
        showCustomDialog(context, mapProvider);
      },
      child: Container(
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
