import 'dart:async';
import 'dart:convert';
import 'package:coyotex/feature/auth/data/view_model/user_view_model.dart';
import 'package:coyotex/feature/map/data/trip_model.dart';
import 'package:coyotex/feature/map/presentation/add_stop_map.dart';
import 'package:coyotex/feature/map/presentation/marker_bottom_sheat.dart';
import 'package:coyotex/feature/map/presentation/notofication_screen.dart';
import 'package:coyotex/feature/map/presentation/search_location_screen.dart';
import 'package:coyotex/feature/map/presentation/show_duration_and_animal_details_sheet.dart';
import 'package:coyotex/feature/map/view_model/map_provider.dart';
import 'package:coyotex/feature/trip/view_model/trip_view_model.dart';
import 'package:coyotex/utils/distance_dialogue.dart';
import 'package:coyotex/utils/filter_dialoguebox.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_compass/flutter_compass.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../../trip/presentation/add_photos.dart';
import '../../../core/utills/app_colors.dart';
import '../../../core/utills/branded_primary_button.dart';
import '../../../core/utills/branded_text_filed.dart';
import 'dart:ui' as ui;
import 'package:permission_handler/permission_handler.dart';

class MapScreen extends StatefulWidget {
  bool? isRestart;
  GoogleMapController? googleMapController;
  MapScreen({this.googleMapController, this.isRestart = false, Key? key})
      : super(key: key);

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
  // StreamSubscription<CompassEvent>? _compassSubscription;
  double? _compassHeading;
  final Map<String, BitmapDescriptor> icons = {};
  Future<void> _loadMarkers() async {
    icons['markerIcon'] = await _getIcon('assets/images/marker_icon.png', 200);
  }

  MapType _currentMapType = MapType.hybrid;
  void _showLayerDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).dialogBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                height: 4,
                width: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Text(
                      "Map Style",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ..._buildLayerOptions(),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildLayerOptions() {
    return [
      _buildLayerOption("Normal", MapType.normal, Icons.map_outlined),
      _buildLayerOption("Satellite", MapType.satellite, Icons.satellite_alt),
      _buildLayerOption("Terrain", MapType.terrain, Icons.terrain),
      _buildLayerOption("Hybrid", MapType.hybrid, Icons.layers),
    ];
  }

  Widget _buildLayerOption(String title, MapType type, IconData icon) {
    final isSelected = _currentMapType == type;
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _currentMapType = type;
            Navigator.pop(context);
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                isSelected ? theme.colorScheme.primary.withOpacity(0.1) : null,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: theme.colorScheme.primary.withOpacity(0.3))
                : null,
          ),
          child: Row(
            children: [
              Icon(icon,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface),
              const SizedBox(width: 16),
              Text(title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  )),
              const Spacer(),
              Radio<MapType>(
                value: type,
                groupValue: _currentMapType,
                toggleable: true,
                fillColor: MaterialStateProperty.resolveWith<Color>(
                  (states) => isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
                onChanged: (value) {
                  setState(() {
                    _currentMapType = value!;
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateMapBearing(MapProvider provider, double heading) {
    if (provider.mapController != null) {
      provider.mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: provider.currentCameraTarget,
            bearing: heading,
            tilt: 0,
            zoom: provider.currentZoom,
          ),
        ),
      );
    }
  }

  String _formatTime(int seconds) {
    return '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  Future<BitmapDescriptor> _getIcon(String path, int width) async {
    final ui.Image image = await _loadImage(path, width);
    return BitmapDescriptor.fromBytes(
      await _getBytesFromImage(image),
      size: const Size(0.5, 1.0),
      // Set anchor to bottom center
    );
  }

  Future<ui.Image> _loadImage(String path, int width) async {
    final ByteData data = await rootBundle.load(path);
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    final ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  Future<Uint8List> _getBytesFromImage(ui.Image image) async {
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return byteData!.buffer.asUint8List();
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

  void distanceDialogue(BuildContext context, MapProvider provider,
      {bool isLocation = false}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return DistanceDialogue(
          provider: provider,
          // isLocation: isLocation,
          markers: provider.markers,
        );
      },
    );
  }

  bool isMarkerLoading = false;
  asyncInit() async {
    setState(() {
      isMarkerLoading = true;
    });
    final provider = Provider.of<MapProvider>(context, listen: false);
    final tripProvider = Provider.of<TripViewModel>(context, listen: false);
    await tripProvider.getAllMarker();

    // provider.updateMapMarkers(tripProvider.lstMarker);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (provider.isStartavigation) {
        provider.updateMapMarkers(provider.liveTripMarker);
      } else {
        provider.updateMapMarkers(tripProvider.lstMarker);
      }
    });
    setState(() {
      isMarkerLoading = false;
    });
  }

  @override
  void initState() {
    _loadMarkers();

    asyncInit();
    // _initCompass();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  final List<String> _windDirections = [
    "North",
    "South",
    "East",
    "West",
    "Northeast",
    "Northwest",
    "Southeast",
    "Southwest"
  ];

  List<String> _selectedDirections = [];

  @override
  Widget build(BuildContext context) {
    return Consumer<MapProvider>(
      builder: (context, provider, child) {
        // for (var item in tripProvider.lstMarker) {
        //   provider.mapMarkers.add(Marker(
        //     markerId: MarkerId(item.id),
        //     position: item.position,
        //     //icon: icons[item.icon] ?? icons["markerIcon"]!,
        //     infoWindow: InfoWindow(title: item.title, snippet: item.snippet),
        //   ));
        // }
        provider.context = context;
        return provider.isLoading || isMarkerLoading
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
                          child: Stack(
                            children: [
                              GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: provider.initialPosition,
                                  zoom: 12,
                                ),
                                myLocationEnabled: true,
                                mapType: _currentMapType,
                                compassEnabled: true,
                                onCameraMove: (position) =>
                                    provider.onCameraMove(position),
                                myLocationButtonEnabled:
                                    provider.isTripStart ? true : false,
                                buildingsEnabled: true,
                                mapToolbarEnabled: false,
                                fortyFiveDegreeImageryEnabled: false,
                                polylines: provider.polylines,
                                markers: provider.mapMarkers,
                                // onTap: (latLang) {
                                //   if (provider.isAddStopButton) {
                                //     provider.addStop(latLang);
                                //   } else if (provider.isSavedTrip) {
                                //     null;
                                //   } else {
                                //     provider.onMapTapped(latLang, context);
                                //   }
                                // },
                                onTap: provider.isSavedTrip
                                    ? null
                                    : (latlang) async {
                                        provider.onMapTapped(latlang, context);
                                      },
                                zoomGesturesEnabled: true,
                                onMapCreated: (controller) =>
                                    provider.onMapCreated(controller),
                              ),
                              Positioned(
                                  top: provider.isTripStart ? 40 : 70,
                                  right: 5,
                                  child: IconButton(
                                      onPressed: _showLayerDialog,
                                      icon: const Icon(
                                        Icons.layers,
                                        color: Colors.red,
                                      ))),
                            ],
                          ),
                        ),
                        if (provider.remainingStopTime > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.access_time_filled_rounded,
                                  color: provider.isRedText
                                      ? Colors.red
                                      : Colors.blueAccent,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Departing in: ${_formatTime(provider.remainingStopTime)}',
                                  style: TextStyle(
                                    color: provider.isRedText
                                        ? Colors.red
                                        : Colors.black87,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (provider.isTripStart)
                          SizedBox(
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

                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: SizedBox(
                                                height: 35,
                                                child: BrandedPrimaryButton(
                                                  isEnabled: true,
                                                  isUnfocus: true,
                                                  name: "Add Photos",
                                                  onPressed: () {
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder: (context) {
                                                      return AddPhotoScreen(
                                                        isRestart:
                                                            widget.isRestart!,
                                                      );
                                                    }));
                                                  },
                                                  borderRadius: 20,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Expanded(
                                              child: SizedBox(
                                                height: 35,
                                                child: BrandedPrimaryButton(
                                                  isEnabled: true,
                                                  isUnfocus: false,
                                                  name: "Finish Trip",
                                                  onPressed: () {
                                                    final tripProvider =
                                                        Provider.of<
                                                                TripViewModel>(
                                                            context,
                                                            listen: false);
                                                    tripProvider
                                                        .showFinishWarningDialog(
                                                            provider, context);
                                                  },
                                                  borderRadius: 20,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
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
                                          GestureDetector(
                                            onTap: () {
                                              distanceDialogue(
                                                  context, provider,
                                                  isLocation: true);
                                            },
                                            child: Image.asset(
                                              "assets/images/distance.png",
                                              height: 30,
                                              width: 30,
                                            ),
                                          ),
                                          Column(
                                            children: [
                                              Text(
                                                "Estimated Time: ",
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Icon(Icons.timeline,
                                                      color:
                                                          Colors.blue.shade600,
                                                      size: 16),
                                                  SizedBox(width: 5),
                                                  Text(
                                                    DateFormat('h:mm a').format(
                                                        provider.currentEstimate ??
                                                            DateTime.now()),
                                                    style: TextStyle(
                                                      color:
                                                          Colors.green.shade700,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  if (provider.currentEstimate !=
                                                          null &&
                                                      provider.originalEstimate !=
                                                          null)
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 8),
                                                      child: Icon(
                                                        provider.currentEstimate!
                                                                .isBefore(provider
                                                                    .originalEstimate!)
                                                            ? Icons
                                                                .arrow_downward
                                                            : Icons
                                                                .arrow_upward,
                                                        color: provider
                                                                .currentEstimate!
                                                                .isBefore(provider
                                                                    .originalEstimate!)
                                                            ? Colors.green
                                                            : Colors.red,
                                                        size: 14,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          // Column(
                                          //   children: [
                                          //     Text(
                                          //       "Estimated Time: ",
                                          //       style: TextStyle(
                                          //         color: Colors.grey.shade600,
                                          //         fontSize: 14,
                                          //       ),
                                          //     ),
                                          //     const SizedBox(width: 8),
                                          //     Row(
                                          //       children: [
                                          //         Icon(Icons.timeline,
                                          //             color:
                                          //                 Colors.blue.shade600,
                                          //             size: 16),
                                          //         SizedBox(
                                          //           width: 5,
                                          //         ),
                                          //         Text(
                                          //           DateFormat('h:mm a').format(
                                          //               provider
                                          //                   .estimatedCompletionTime!),
                                          //           style: TextStyle(
                                          //             color:
                                          //                 Colors.green.shade700,
                                          //             fontSize: 14,
                                          //             fontWeight:
                                          //                 FontWeight.bold,
                                          //           ),
                                          //         ),
                                          //       ],
                                          //     ),
                                          //   ],
                                          // ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Row(
                                                children: [
                                                  Icon(Icons.access_time,
                                                      color: Colors.blue,
                                                      size: 20),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    "Trip Time",
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.blue,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                provider.totalTravelTime,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.green.shade700,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(Icons.place,
                                                      color: Colors.blue,
                                                      size: 18),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    provider.formattedDistance,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color:
                                                          Colors.grey.shade700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              const Row(
                                                children: [
                                                  Icon(Icons.timer,
                                                      color: Colors.blue,
                                                      size: 20),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    "Total Time",
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.blue,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              // Column(c)
                                              SizedBox(height: 4),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 8.0),
                                                child: Text(
                                                  provider
                                                      .totalStopWithTravelTime,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        Colors.orange.shade700,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                            ],
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                // Start Button
                                const SizedBox(height: 20),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Row(
                                    children: [
                                      Flexible(
                                        flex: 3,
                                        child: SizedBox(
                                          height: 35,
                                          child: BrandedPrimaryButton(
                                            isEnabled: true,
                                            isUnfocus: false,
                                            name: provider.isStartavigation
                                                ? "Stop Navigation"
                                                : "Start Navigation",
                                            onPressed: () {
                                              if (provider.isStartavigation) {
                                                provider.resetFields();
                                                Navigator.of(context).pop();
                                                Navigator.of(context).pop();
                                              } else {
                                                provider.launchGoogleMaps(
                                                    provider.selectedTripModel);
                                                provider.isStartavigation =
                                                    true;
                                              }
                                            },
                                            borderRadius: 20,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Flexible(
                                        flex: 2,
                                        child: SizedBox(
                                          height: 35,
                                          child: BrandedPrimaryButton(
                                            isEnabled: true,
                                            isUnfocus: false,
                                            name: "Add Stop",
                                            onPressed: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) {
                                                return AddStopMap();
                                              })).then((onValue) {
                                                provider.isStartavigation =
                                                    false;
                                                setState(() {});
                                              });
                                              // provider.addStop();
                                            },
                                            borderRadius: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                if (widget.isRestart!)
                                  const SizedBox(
                                    height: 30,
                                  )
                              ],
                            ),
                          ),
                        if (provider.isSave) tripCard(provider, context),
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
                            if (!provider.onTapOnMap && !provider.isSavedTrip ||
                                provider.markers.isEmpty)
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
                                    onTap: () async {
                                      showDialog(
                                        context: context,
                                        builder: (context) => FilterDialog(
                                          windDirections: _windDirections,
                                          selectedDirections:
                                              _selectedDirections,
                                          onApply: (selected) {
                                            setState(() =>
                                                _selectedDirections = selected);

                                            final tripProvider =
                                                Provider.of<TripViewModel>(
                                                    context,
                                                    listen: false);
                                            final mapProvider =
                                                Provider.of<MapProvider>(
                                                    context,
                                                    listen: false);

                                            // Filter markers based on selected wind directions
                                            final filtered = tripProvider
                                                .lstMarker
                                                .where((marker) {
                                              if (selected.isEmpty) return true;
                                              return selected.any((dir) =>
                                                  marker.wind_direction
                                                      .contains(dir));
                                            }).toList();
                                            // provider.liveTripMarker = filtered;
                                            mapProvider.updateMapMarkers(
                                                filtered); // Update map with filtered markers
                                          },
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                            color: Colors.red, width: 2),
                                      ),
                                      child: const Icon(
                                        Icons.filter_alt,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(
                              height: 10,
                            ),
                            if (provider.markers.length >= 2 &&
                                !provider.isSavedTrip &&
                                provider.onTapOnMap)
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
                            if (provider.startController.text.isNotEmpty &&
                                provider.trips.isEmpty)
                              const SizedBox(
                                height: 10,
                              ),
                            if (provider.startController.text.isNotEmpty &&
                                !provider.onTapOnMap)
                              Container(
                                height: (provider.destinationCount + 1) *
                                            (40 + 10) >
                                        MediaQuery.of(context).size.height * 0.3
                                    ? MediaQuery.of(context).size.height * 0.3
                                    : (provider.destinationCount + 1) *
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
                                            GestureDetector(
                                              onTap: () {
                                                // provider.onRemove(_marker.position);
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
                                                  Icons.close,
                                                  color: Colors.red,
                                                ),
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
                  ],
                ),
              );
      },
    );
  }

  // Positioned tripCard(
  //   MapProvider provider,
  //   BuildContext context,
  // ) {
  //   return Positioned(
  //     bottom: 20,
  //     left: 10,
  //     right: 10,
  //     child: Container(
  //       width: MediaQuery.of(context).size.width,
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
  //                   Image.asset(
  //                     "assets/images/logo.png",
  //                     width: 50,
  //                     height: 50,
  //                   ),
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
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Row(
  //                         children: [
  //                           Text(
  //                             "${provider.weather.main.temp}\u00B0",
  //                             style: TextStyle(fontSize: 22),
  //                           ),
  //                           SizedBox(width: 5),
  //                           Text(
  //                               "(${provider.weather.weather.first.description})"),
  //                         ],
  //                       ),
  //                       Text(
  //                         DateFormat('MMM d yyyy').format(DateTime.now()),
  //                         style: const TextStyle(fontSize: 15),
  //                       ),
  //                       Row(
  //                         children: [
  //                           const Icon(Icons.location_on_outlined, size: 13),
  //                           const SizedBox(width: 8),
  //                           Text(
  //                             provider.weather.base,
  //                             style: const TextStyle(fontSize: 12),
  //                           ),
  //                         ],
  //                       ),
  //                     ],
  //                   ),
  //                   Column(
  //                     crossAxisAlignment: CrossAxisAlignment.end,
  //                     children: [
  //                       Row(
  //                         children: [
  //                           GestureDetector(
  //                             onTap: () {
  //                               showCustomDialog(context, provider);
  //                             },
  //                             child: const Text(
  //                               'Break Time',
  //                               style: TextStyle(fontWeight: FontWeight.bold),
  //                             ),
  //                           ),
  //                           SizedBox(width: 10),
  //                           GestureDetector(
  //                             onTap: () {
  //                               distanceDialogue(context, provider,
  //                                   isLocation: true);
  //                             },
  //                             child: Image.asset(
  //                               "assets/images/distance.png",
  //                               height: 30,
  //                               width: 30,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                       SizedBox(height: 5),
  //                       Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Text(
  //                               "Humidity: ${provider.weather.main.humidity}%"),
  //                           Text(
  //                               'BP: ${(provider.weather.main.pressure * 0.02953).toStringAsFixed(2)} inHg')
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
  //     ),
  //   );
  // }
  Widget tripCard(MapProvider provider, BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.34,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Card(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bottom sheet handle
              // Center(
              //   child: Container(
              //     width: 40,
              //     height: 4,
              //     decoration: BoxDecoration(
              //       color: Colors.grey.shade300,
              //       borderRadius: BorderRadius.circular(2),
              //     ),
              //   ),
              // ),
              // const SizedBox(height: 8),

              // Header Row
              Row(
                children: [
                  Icon(Icons.forest, color: Colors.red.shade700, size: 24),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "HUNTING TRIP",
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        provider.formatDistance(provider.distance, context),
                        style: TextStyle(
                          color: Colors.grey.shade900,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          distanceDialogue(context, provider, isLocation: true);
                        },
                        child: Image.asset(
                          "assets/images/distance.png",
                          height: 20,
                          width: 20,
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      IconButton(
                        icon: Icon(Icons.close,
                            color: Colors.grey.shade600, size: 20),
                        padding: EdgeInsets.zero,
                        onPressed: () => provider.resetFields(),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTimeMetric(
                    icon: Icons.access_time,
                    label: "Trip Time",
                    value: provider.totalTravelTime,
                    color: Colors.green.shade600,
                  ),
                  _buildTimeMetric(
                    icon: Icons.timer,
                    label: "Total Time",
                    value: provider.totalStopWithTravelTime,
                    color: Colors.orange.shade600,
                  ),
                  GestureDetector(
                    onTap: () => showCustomDialog(context, provider),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.timer_off,
                              color: Colors.red.shade600, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            "Break Time",
                            style: TextStyle(
                              color: Colors.red.shade600,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Weather & Conditions
              Divider(color: Colors.grey.shade300, height: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.thermostat,
                          color: Colors.grey.shade600, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${provider.weather.main.temp}°F',
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.air),
                      Text(
                        '${provider.weather.wind.speed} mph',
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Icon(Icons.water_drop,
                          color: Colors.grey.shade600, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${provider.weather.main.humidity}%',
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.speed, color: Colors.grey.shade600, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${(provider.weather.main.pressure * 0.02953).toStringAsFixed(2)} inHg',
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Action Buttons
              if (provider.providerLetsHuntButton)
                SizedBox(
                  height: 35,
                  child: BrandedPrimaryButton(
                    isEnabled: true,
                    name: "Let's Hunt",
                    onPressed: () => provider.letsHunt(),
                  ),
                ),

              if (!provider.isSavedTrip) const SizedBox(height: 6),

              if (!provider.isSavedTrip)
                SizedBox(
                  height: 35,
                  child: BrandedPrimaryButton(
                    isEnabled: true,
                    name: "Save Trip",
                    onPressed: () => provider.saveTrip(context),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeMetric({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade400,
              ),
            ),
            Row(
              children: [
                Icon(icon, color: color, size: 22),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        )
      ],
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
