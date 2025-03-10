import 'package:coyotex/core/services/server_calls/trip_apis.dart';
import 'package:coyotex/feature/map/data/trip_model.dart';
import 'package:coyotex/feature/map/view_model/map_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DistanceDialogue extends StatefulWidget {
  final bool isLocation;
  final MapProvider mapProvider;

  const DistanceDialogue({
    Key? key,
    required this.isLocation,
    required this.mapProvider,
  }) : super(key: key);

  @override
  _DistanceDialogueState createState() => _DistanceDialogueState();
}

class _DistanceDialogueState extends State<DistanceDialogue> {
  @override
  Widget build(BuildContext context) {
    final markers = widget.mapProvider.markers;
    final distanceOfSegments = widget.mapProvider.distanceOfSegments;

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
            "Distance Details",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: markers.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final markerData = markers[index];
                return ListTile(
                  title: Text(
                    markerData.snippet,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  subtitle: index > 0
                      ? Text(
                          'Distance from previous: ${widget.mapProvider.formatDistance(double.parse(distanceOfSegments[index - 1].values.first), context)}',
                          style: const TextStyle(fontSize: 12),
                        )
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
