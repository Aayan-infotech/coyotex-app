import 'package:coyotex/core/services/server_calls/trip_apis.dart';
import 'package:coyotex/feature/map/data/trip_model.dart';
import 'package:coyotex/feature/map/view_model/map_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomDialog extends StatefulWidget {
  final bool isLocation;
  MapProvider mapProvider;

  CustomDialog({Key? key, required this.isLocation, required this.mapProvider})
      : super(key: key);

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
                    const Text(
                      "Enter Animal Details",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: animalSeenController,
                      decoration: InputDecoration(
                        labelText: "Animals Seen",
                        prefixIcon: const Icon(Icons.remove_red_eye_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: animalKilledController,
                      decoration: InputDecoration(
                        labelText: "Animals Killed",
                        prefixIcon: const Icon(Icons.warning_amber_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.number,
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
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () async {
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
                                        fontWeight: FontWeight.bold)),
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
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.isLocation ? "Animals Details" : "Stop Duration",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: widget.mapProvider.markers.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                MarkerData markerData = widget.mapProvider.markers[index];
                return widget.isLocation
                    ? ListTile(
                        title: Text(
                          markerData.snippet,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              children: [
                                const Text("Killed",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                Text(markerData.animalKilled,
                                    style: const TextStyle(fontSize: 14)),
                              ],
                            ),
                            const SizedBox(width: 10),
                            Column(
                              children: [
                                const Text("Seen",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                Text(markerData.animalSeen,
                                    style: TextStyle(fontSize: 14)),
                              ],
                            ),
                          ],
                        ),
                        onTap: () => _showAnimalDialog(context, markerData),
                      )
                    : ListTile(
                        title: Text(
                          markerData.snippet,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        trailing: Text(
                          "${markerData.duration} min",
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      );
              },
            ),
          ),
        ],
      ),
    );
  }
}
