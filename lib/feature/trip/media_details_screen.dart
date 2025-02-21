import 'package:coyotex/feature/auth/data/view_model/user_view_model.dart';
import 'package:coyotex/feature/map/data/trip_model.dart';
import 'package:coyotex/feature/map/view_model/map_provider%20copy.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class MediaDetailsScreen extends StatefulWidget {
  final String url;
  MarkerData markerData;
  TripModel tripModel;

  MediaDetailsScreen(
      {required this.tripModel,
      required this.markerData,
      super.key,
      required this.url});

  @override
  State<MediaDetailsScreen> createState() => _MediaDetailsScreenState();
}

class _MediaDetailsScreenState extends State<MediaDetailsScreen> {
  VideoPlayerController? _controller;
  bool _isVideo = false;
  bool _isPlaying = false;
  double totalDistance = 0.0;

  @override
  void initState() {
    super.initState();
    calculateTotalDistance();
    _isVideo = _checkIfVideo(widget.url);
    if (_isVideo) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
        ..initialize().then((_) {
          setState(() {});
          _controller!.setLooping(true);
          _controller!.addListener(() {
            if (!_controller!.value.isPlaying &&
                _controller!.value.position == _controller!.value.duration) {
              setState(() => _isPlaying = false);
            }
          });
        });
    }
  }

  calculateTotalDistance() {
    totalDistance += Geolocator.distanceBetween(
      widget.tripModel.markers.first.position.latitude,
      widget.tripModel.markers.first.position.longitude,
      widget.markerData.position.latitude,
      widget.markerData.position.longitude,
    );
  }

  String _calculateTotalTime(double distanceInKm) {
    double totalHours = distanceInKm / 40.0; // Assuming average speed = 40 km/h
    int hours = totalHours.floor();
    int minutes = ((totalHours - hours) * 60).round();
    return "$hours hr $minutes min";
  }

  bool _checkIfVideo(String url) {
    return url.endsWith('.mp4') ||
        url.endsWith('.mov') ||
        url.endsWith('.avi') ||
        url.endsWith('.MP4') ||
        url.endsWith('.MOV') ||
        url.endsWith('.AVI');
  }

  void _togglePlayPause() {
    if (_controller!.value.isPlaying) {
      _controller!.pause();
      setState(() => _isPlaying = false);
    } else {
      _controller!.play();
      setState(() => _isPlaying = true);
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(() {});
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserViewModel>(context, listen: false);
    if (userProvider.user.userUnit == "KM") {
      totalDistance = totalDistance / 1000; // Convert meters to kilometers
    } else if (userProvider.user.userUnit == "Miles") {
      totalDistance = totalDistance / 1609.34; // Convert meters to miles
    }
    String totalTime = _calculateTotalTime(totalDistance);
    return Scaffold(
      backgroundColor: Colors.black, // Set background color to black
      appBar: AppBar(
        title: Text(
          "${widget.tripModel.name}",
          style: TextStyle(
            color:
                Colors.white, // Change text color to white for better contrast
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: Colors.black, // Set AppBar color to black
        iconTheme:
            IconThemeData(color: Colors.white), // Change back button color
      ),
      body: Column(
        children: [
          Center(
            child: _isVideo
                ? _controller == null || !_controller!.value.isInitialized
                    ? Center(child: CircularProgressIndicator.adaptive())
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              height: 200,
                              width: MediaQuery.of(context).size.width,
                              child: AspectRatio(
                                aspectRatio: _controller!.value.aspectRatio,
                                child: VideoPlayer(_controller!),
                              ),
                            ),
                            Positioned(
                              child: GestureDetector(
                                onTap: _togglePlayPause,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: Icon(
                                    _isPlaying ? Icons.pause : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.url,
                      width: 300,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: Row(
                    children: [
                      Image.asset("assets/images/distance_icons.png"),
                      const SizedBox(width: 5),
                      Column(
                        children: [
                          const Text(
                            "Distance",
                            style: TextStyle(
                              color: Colors.white, // Change text color
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${totalDistance.toStringAsFixed(2)} ${userProvider.user.userUnit}",
                            style: TextStyle(
                              color: Colors
                                  .white70, // Adjust text color for contrast
                              fontSize: 12,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Column(
                  children: [
                    Text(
                      "Total Time",
                      style: TextStyle(
                        color: Colors.white, // Change text color
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      totalTime,
                      style: TextStyle(
                        color: Colors.white70, // Adjust text color
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Card(
            color: Colors.black, // Set Card color to black
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Trip 1",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Change text color
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.white70),
                          SizedBox(width: 5),
                          Text(
                            "Location",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70, // Adjust text color
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // Description
                  Text(
                    "Borem ipsum dolor sit amet, consectetur adipiscing elit. "
                    "Nunc vulputate libero et velit interdum, ac aliquet odio mattis.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70, // Adjust text color
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white54, // Adjust underline color
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
