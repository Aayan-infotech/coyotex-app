import 'package:coyotex/core/services/server_calls/trip_apis.dart';
import 'package:coyotex/feature/map/data/trip_model.dart';
import 'package:coyotex/feature/map/view_model/map_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomDialog extends StatefulWidget {
  final bool isLocation;
  final MapProvider mapProvider;

  const CustomDialog({
    super.key,
    required this.isLocation,
    required this.mapProvider,
  });

  @override
  _CustomDialogState createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  bool isLoading = false;

  void _showAnimalDialog(BuildContext context, MarkerData markerData) {
    TextEditingController animalSeenController = TextEditingController();
    TextEditingController animalKilledController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Animal Details",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => Navigator.pop(context),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: animalSeenController,
                      enabled: markerData.isVisited,
                      decoration: InputDecoration(
                        labelText: "Animals Seen",
                        labelStyle: const TextStyle(color: Colors.black54),
                        prefixIcon: Icon(Icons.remove_red_eye_outlined,
                            color: markerData.isVisited
                                ? Colors.red
                                : Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.black),
                    ),
                    if (!markerData.isVisited)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: Colors.red, size: 16),
                            SizedBox(width: 4),
                            Text(
                              "Visit location to enable editing",
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: animalKilledController,
                      enabled: markerData.isVisited,
                      decoration: InputDecoration(
                        labelText: "Animals Killed",
                        labelStyle: const TextStyle(color: Colors.black54),
                        prefixIcon: Icon(Icons.warning_amber_rounded,
                            color: markerData.isVisited
                                ? Colors.red
                                : Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        isLoading
                            ? const CircularProgressIndicator(color: Colors.red)
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () async {
                                  if (!markerData.isVisited) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        icon: const Icon(
                                            Icons.warning_amber_rounded,
                                            color: Colors.red,
                                            size: 40),
                                        title: const Text(
                                            "Location Not Visited",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold)),
                                        content: const Text(
                                            "You must visit this location before saving animal details.",
                                            style: TextStyle(
                                                color: Colors.black54)),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text("OK",
                                                style: TextStyle(
                                                    color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() => isLoading = true);
                                  markerData.animalKilled =
                                      animalKilledController.text;
                                  markerData.animalSeen =
                                      animalSeenController.text;

                                  await updateMarker(markerData, setState)
                                      .then((value) {
                                    Navigator.of(context).pop();
                                  });
                                },
                                child: const Text("Save",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                              ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> updateMarker(
      MarkerData markerData, void Function(void Function()) setState) async {
    var response = await TripAPIs().addAnimalSeenAndKilled(
        markerData, widget.mapProvider.selectedTripModel.id);

    if (response.success) {
      widget.mapProvider.getTrips();
      setState(() => isLoading = false);
      Navigator.pop(context);
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.isLocation ? "Animal Sightings" : "Stop Durations",
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: widget.mapProvider.markers.length,
              separatorBuilder: (_, __) =>
                  Divider(color: Colors.red.withOpacity(0.2)),
              itemBuilder: (context, index) {
                MarkerData markerData = widget.mapProvider.markers[index];
                return widget.isLocation
                    ? ListTile(
                        leading: Icon(
                          markerData.isVisited
                              ? Icons.location_on
                              : Icons.location_off,
                          color:
                              markerData.isVisited ? Colors.red : Colors.grey,
                        ),
                        title: Text(
                          markerData.snippet,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildCountColumn(
                                "Killed", markerData.animalKilled),
                            const SizedBox(width: 10),
                            _buildCountColumn("Seen", markerData.animalSeen),
                          ],
                        ),
                        onTap: () => _showAnimalDialog(context, markerData),
                      )
                    : ListTile(
                        leading: const Icon(Icons.timer, color: Colors.red),
                        title: Text(
                          markerData.snippet,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black),
                        ),
                        trailing: Text(
                          "${markerData.duration} min",
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                        ),
                      );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountColumn(String title, String value) {
    return Column(
      children: [
        Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black54)),
        Text(value, style: const TextStyle(fontSize: 14, color: Colors.red)),
      ],
    );
  }
}
