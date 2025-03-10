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

  DurationPickerBottomSheet({this.mapMarker, Key? key, this.isStop = false})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _DurationPickerBottomSheetState createState() =>
      _DurationPickerBottomSheetState();
}

class _DurationPickerBottomSheetState extends State<DurationPickerBottomSheet> {
  final TextEditingController _minuteController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String? _selectedWindDirection;
  bool _isFormValid = false;

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
  final FocusNode _minuteFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _minuteController.addListener(_validateForm);
    if (widget.mapMarker != null) {
      searchMarker(context);
    }
  }

  bool isLoading = false;
  MarkerData? markerData;

  searchMarker(BuildContext context) {
    setState(() {
      isLoading = true;
    });
    final tripProvider = Provider.of<TripViewModel>(context, listen: false);
    MapProvider mapProvider = Provider.of<MapProvider>(context, listen: false);

    markerData = tripProvider.lstMarker.firstWhere(
      (i) => i.id == widget.mapMarker!.markerId.value,
      orElse: () => null as MarkerData, // hacky way, not recommended
    );
    mapProvider.selectedOldMarker = markerData;
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
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
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
                      const Text(
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
                              BrandedTextField(
                                controller: _nameController,
                                focusNode: _nameFocusNode,
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
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Wrap(
                                spacing: 10.0,
                                runSpacing: 5.0,
                                children: _windDirections.map((direction) {
                                  return ChoiceChip(
                                    label: Text(direction),
                                    selected:
                                        _selectedWindDirection == direction,
                                    onSelected: (bool selected) {
                                      setState(() {
                                        _selectedWindDirection =
                                            selected ? direction : null;
                                        mapProvider.selectedWindDirection =
                                            (selected ? direction : null)!;
                                        _validateForm();
                                      });
                                    },
                                    selectedColor: Pallete.accentColor,
                                    labelStyle: TextStyle(
                                      color: _selectedWindDirection == direction
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
                              child: BrandedPrimaryButton(
                                  isEnabled: true,
                                  isUnfocus: true,
                                  name: "Cancel",
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  })),
                          const SizedBox(width: 10),
                          Expanded(
                            child: BrandedPrimaryButton(
                                isEnabled: _isFormValid,
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
      if (_minuteController.text.isNotEmpty && _selectedWindDirection != null) {
        final mapProvider = Provider.of<MapProvider>(context, listen: false);
        if (widget.mapMarker != null) {
          markerData!.duration = int.parse(_minuteController.text);
          markerData!.title = _nameController.text;
          markerData!.wind_direction = _selectedWindDirection!;
          mapProvider.markers.add(markerData!);
          mapProvider.points.add(markerData!.position);
          mapProvider.path.add(markerData!.position);
          Navigator.of(context).pop(true);
        } else {
          int minutes = int.parse(_minuteController.text);
          MapProvider mapProvider =
              Provider.of<MapProvider>(context, listen: false);
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
}
