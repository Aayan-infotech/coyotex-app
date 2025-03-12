import 'package:coyotex/feature/map/data/trip_model.dart';
import 'package:coyotex/feature/map/view_model/map_provider.dart';
import 'package:flutter/material.dart';

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
  final Color _primaryColor = Colors.blue.shade800;
  final Color _accentColor = Colors.teal.shade600;
  final Color _backgroundColor = Colors.grey.shade100;

  @override
  Widget build(BuildContext context) {
    final markers = widget.mapProvider.markers;
    final distanceOfSegments = widget.mapProvider.distanceOfSegments;
    final totalDistance = distanceOfSegments.fold<double>(
      0.0,
      (sum, segment) => sum + double.parse(segment.values.first),
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.zoom_out_map, color: _primaryColor, size: 28),
              const SizedBox(width: 10),
              Text(
                "Journey Overview",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: _primaryColor.withOpacity(0.3), thickness: 1.5),
          const SizedBox(height: 16),
          if (markers.length < 2)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Add at least two points to see route details',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            _buildRouteVisualization(markers, distanceOfSegments),
          const SizedBox(height: 16),
          _buildTotalSection(totalDistance, markers.length),
        ],
      ),
    );
  }

  Widget _buildRouteVisualization(
      List<MarkerData> markers, List<Map<String, String>> distances) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: markers.length * 2 - 1, // Adjusted item count
        itemBuilder: (context, index) {
          int markerIndex = index ~/ 2;
          if (index.isEven) {
            return _buildMarkerPoint(markerIndex, markers[markerIndex]);
          } else {
            return _buildConnectionLine(
                markerIndex < distances.length ? distances[markerIndex] : {});
          }
        },
      ),
    );
  }

  Widget _buildMarkerPoint(int index, MarkerData marker) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _accentColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: Text(
            marker.snippet ?? 'Point ${index + 1}',
            textAlign: TextAlign.center,
            maxLines: 3,
            style: TextStyle(
              color: _primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionLine(Map<String, String> distanceData) {
    final distance = double.parse(distanceData.values.first);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 2,
            color: _accentColor,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: _accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.mapProvider.formatDistance(distance, context),
              style: TextStyle(
                color: _accentColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSection(double totalDistance, int pointCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Distance',
                style: TextStyle(
                  color: _primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.mapProvider.formatDistance(totalDistance, context),
                style: TextStyle(
                  color: _accentColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Points',
                style: TextStyle(
                    color: _primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                '$pointCount',
                style: TextStyle(
                  color: _accentColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
