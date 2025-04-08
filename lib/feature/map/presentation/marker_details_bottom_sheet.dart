import 'package:coyotex/core/utills/app_colors.dart';
import 'package:coyotex/core/utills/branded_primary_button.dart';
import 'package:coyotex/core/utills/branded_text_filed.dart';
import 'package:coyotex/feature/map/data/trip_model.dart';
import 'package:coyotex/feature/map/view_model/map_provider.dart';
import 'package:coyotex/feature/trip/view_model/trip_view_model.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class DurationPickerBottomSheet extends StatefulWidget {
  final bool isStop;
  Marker? mapMarker;

  DurationPickerBottomSheet({this.mapMarker, super.key, this.isStop = false});

  @override
  // ignore: library_private_types_in_public_api
  _DurationPickerBottomSheetState createState() =>
      _DurationPickerBottomSheetState();
}

class _DurationPickerBottomSheetState extends State<DurationPickerBottomSheet> {
  final TextEditingController _minuteController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _tripNameController = TextEditingController();
  String? _selectedWindDirection;
  bool _isFormValid = false;
  bool isLoading = false;
  bool isMarkerDeletable = false;

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

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _tripNameFocusNode = FocusNode();
  final FocusNode _minuteFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _minuteController.addListener(_validateForm);
    if (widget.mapMarker != null) {
      searchMarker(context);
    }
  }

  MarkerData? markerData;

  searchMarker(BuildContext context) {
    setState(() {
      isLoading = true;
    });
    final tripProvider = Provider.of<TripViewModel>(context, listen: false);
    MapProvider mapProvider = Provider.of<MapProvider>(context, listen: false);
    if (widget.mapMarker!.markerId.value.isEmpty) {
    } else {}

    if (mapProvider.isTripStart && !widget.isStop) {
      isMarkerDeletable = mapProvider.selectedTripModel.markers
          .any((element) => element.position == widget.mapMarker!.position);
    }

    markerData = tripProvider.lstMarker.firstWhere(
      (i) => i.id == widget.mapMarker!.markerId.value,
      // ignore: cast_from_null_always_fails
      orElse: () => null as MarkerData, // hacky way, not recommended
    );
    // mapProvider.selectedOldMarker = markerData;
    _minuteController.text = markerData!.duration.toString();
    _nameController.text = markerData!.title;
    _selectedWindDirection = markerData!.wind_direction;
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _minuteFocusNode.dispose();
    _minuteController.removeListener(_validateForm);
    _minuteController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  String formatDuration(int totalMinutes) {
    if (totalMinutes < 0) throw ArgumentError("Duration cannot be negative");

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    final List<String> parts = [];

    if (hours > 0) parts.add('${hours}h');
    if (minutes > 0 || totalMinutes == 0) parts.add('${minutes}m');

    return parts.join(' ');
  }

// Example usage:

  void _validateForm() {
    setState(() {
      _isFormValid =
          _minuteController.text.isNotEmpty && _selectedWindDirection != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    MapProvider mapProvider = Provider.of<MapProvider>(context, listen: false);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.7,
        maxChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) {
          return mapProvider.isTripStart && !widget.isStop
              ? Container(
                  width: MediaQuery.of(context).size.width,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 10)
                    ],
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator.adaptive(
                          backgroundColor: Colors.black,
                        )
                      : Column(
                          children: [
                            Container(
                              width: 60,
                              height: 6,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Marker Details",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Pallete.accentColor,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    _buildDetailItem(
                                      icon: Icons.flag,
                                      title: "Marker Name",
                                      value: markerData?.title ??
                                          "Unnamed Location",
                                    ),
                                    _buildDetailItem(
                                      icon: Icons.access_time,
                                      title: "Duration",
                                      value:
                                          formatDuration(markerData!.duration),
                                    ),
                                    _buildDetailItem(
                                      icon: Icons.air,
                                      title: "Wind Direction",
                                      value: markerData?.wind_direction ??
                                          "Not specified",
                                    ),
                                    const SizedBox(height: 30),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: !isMarkerDeletable
                                          ? Expanded(
                                              child: BrandedPrimaryButton(
                                                isEnabled: true,
                                                name: "Close",
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                              ),
                                            )
                                          : Row(
                                              children: [
                                                Expanded(
                                                  child: BrandedPrimaryButton(
                                                    isUnfocus: true,
                                                    isEnabled: true,
                                                    name: "Delete",
                                                    onPressed: () async {
                                                      setState(() {
                                                        isLoading = true;
                                                      });
                                                      final tripProvider =
                                                          Provider.of<
                                                                  TripViewModel>(
                                                              context,
                                                              listen: false);
                                                      final mapProvider =
                                                          Provider.of<
                                                                  MapProvider>(
                                                              context,
                                                              listen: false);
                                                      var response = await tripProvider
                                                          .deleteMarker(
                                                              widget
                                                                  .mapMarker!
                                                                  .markerId
                                                                  .value,
                                                              mapProvider
                                                                  .selectedTripModel
                                                                  .id);
                                                      response = await tripProvider
                                                          .deleteWayPoints(
                                                              widget.mapMarker!
                                                                  .position,
                                                              mapProvider
                                                                  .selectedTripModel
                                                                  .id);
                                                      tripProvider
                                                          .getAllMarker();
                                                      if (response.success) {
                                                        await mapProvider
                                                            .removeMarker(
                                                                widget
                                                                    .mapMarker!,
                                                                context);
                                                      }

                                                      setState(() {
                                                        isLoading = false;
                                                      });
                                                      Navigator.pop(context);
                                                    },
                                                    // color: Colors.red,
                                                    // textColor: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: BrandedPrimaryButton(
                                                    isEnabled: true,
                                                    name: "Close",
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                )
              : Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 10)
                    ],
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.black,
                        )
                      : Column(
                          children: [
                            Container(
                              width: 60,
                              height: 6,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(height: 10),
                            widget.isStop
                                ? const Text(
                                    "Add Stop",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey,
                                    ),
                                  )
                                : const Text(
                                    "Add Marker",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                            const SizedBox(height: 20),
                            Expanded(
                              child: SingleChildScrollView(
                                controller: scrollController,
                                keyboardDismissBehavior:
                                    ScrollViewKeyboardDismissBehavior.onDrag,
                                child: Column(
                                  children: [
                                    if (mapProvider.tripName.isEmpty &&
                                        !widget.isStop)
                                      BrandedTextField(
                                        controller: _tripNameController,
                                        focusNode: _tripNameFocusNode,
                                        labelText: "Enter Trip name ",
                                        onChanged: (value) {
                                          setState(() {});
                                        },
                                        onTap: () {
                                          scrollController.jumpTo(
                                              scrollController
                                                  .position.maxScrollExtent);
                                        },
                                      ),
                                    const SizedBox(height: 16),
                                    BrandedTextField(
                                      controller: _nameController,
                                      focusNode: _nameFocusNode,
                                      onChanged: (value) {},
                                      labelText: "Enter marker name (Optional)",
                                      onTap: () {
                                        scrollController.jumpTo(scrollController
                                            .position.maxScrollExtent);
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    BrandedTextField(
                                      controller: _minuteController,
                                      focusNode: _minuteFocusNode,
                                      labelText: "Enter time in minutes",
                                      keyboardType: TextInputType.number,
                                      onTap: () {
                                        scrollController.jumpTo(scrollController
                                            .position.maxScrollExtent);
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    const Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "Wind Direction",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Wrap(
                                      spacing: 10.0,
                                      runSpacing: 5.0,
                                      children:
                                          _windDirections.map((direction) {
                                        return ChoiceChip(
                                          label: Text(direction),
                                          selected: _selectedWindDirection ==
                                              direction,
                                          onSelected: (bool selected) {
                                            setState(() {
                                              _selectedWindDirection =
                                                  selected ? direction : null;
                                              mapProvider
                                                      .selectedWindDirection =
                                                  (selected
                                                      ? direction
                                                      : null)!;
                                              _validateForm();
                                            });
                                          },
                                          selectedColor: Pallete.accentColor,
                                          labelStyle: TextStyle(
                                            color: _selectedWindDirection ==
                                                    direction
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                    child: isLoading
                                        ? const Center(
                                            child: CircularProgressIndicator())
                                        : BrandedPrimaryButton(
                                            isEnabled: true,
                                            isUnfocus: true,
                                            name: "Cancel",
                                            onPressed: () async {
                                              if (mapProvider.markers.length ==
                                                  1) {
                                                mapProvider.tripName = '';
                                              }

                                              if (widget.mapMarker == null) {
                                                mapProvider.points.removeLast();
                                                mapProvider.path.removeLast();
                                                mapProvider.markers
                                                    .removeLast();
                                              }
                                              List<LatLng> locations =
                                                  List.from(mapProvider.points);
                                              Navigator.of(context).pop();
                                              await mapProvider
                                                  .fetchRouteWithWaypoints(
                                                      locations,
                                                      isRemove: true)
                                                  .then((value) {});
                                            })),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: BrandedPrimaryButton(
                                      isEnabled: (_isFormValid ||
                                              widget.mapMarker != null) &&
                                          (widget.isStop ||
                                              _tripNameController
                                                  .text.isNotEmpty ||
                                              mapProvider.tripName.isNotEmpty),
                                      name: "Set",
                                      onPressed: _setMarker),
                                ),
                              ],
                            ),
                            const SizedBox(height: 50),
                          ],
                        ),
                );
        },
      ),
    );
  }

  Future<void> _setMarker() async {
    try {
      final mapProvider = Provider.of<MapProvider>(context, listen: false);

      if (widget.isStop) {
        mapProvider.stopName = _nameController.text;
      }
      if (_minuteController.text.isNotEmpty && _selectedWindDirection != null) {
        if (widget.mapMarker != null) {
          if (mapProvider.tripName.isEmpty) {
            mapProvider.tripName = _tripNameController.text;
          }
          markerData!.duration = int.parse(_minuteController.text);
          markerData!.title = _nameController.text;
          markerData!.wind_direction = _selectedWindDirection!;
          markerData!.animalKilled = "0";
          markerData!.animalSeen = "0";
          mapProvider.markers.add(markerData!);
          mapProvider.points.add(markerData!.position);
          mapProvider.path.add(markerData!.position);

          if (mapProvider.markers.length >= 2) {
            mapProvider.fetchRouteWithWaypoints(mapProvider.path);
          }
          mapProvider.isSave = true;
          Navigator.of(context).pop(true);
        } else {
          int minutes = int.parse(_minuteController.text);
          MapProvider mapProvider =
              Provider.of<MapProvider>(context, listen: false);
          if (mapProvider.tripName.isEmpty) {
            mapProvider.tripName = _tripNameController.text;
          }
          await mapProvider.setTimeDuration(minutes, _nameController.text);
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid number"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildDetailItem(
      {required IconData icon, required String title, required String value}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Pallete.accentColor, size: 28),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalStat(
      {required IconData icon,
      required String count,
      required String label,
      bool isRed = false}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                isRed ? Pallete.accentColor.withOpacity(0.1) : Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Icon(icon,
              color: isRed ? Pallete.accentColor : Colors.grey[600], size: 32),
        ),
        const SizedBox(height: 8),
        Text(
          count,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isRed ? Pallete.accentColor : Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
