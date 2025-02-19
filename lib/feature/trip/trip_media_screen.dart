import 'package:carousel_slider/carousel_slider.dart';
import 'package:coyotex/core/utills/media_widget.dart';
import 'package:coyotex/feature/map/data/trip_model.dart';
import 'package:coyotex/feature/trip/media_details_screen.dart';
import 'package:flutter/material.dart';

class MarkerMediaScreen extends StatelessWidget {
  final List<MarkerData> markerData;

  MarkerMediaScreen({required this.markerData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Photos',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        forceMaterialTransparency: true,
        backgroundColor: Colors.white,
        elevation: 4.0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        itemCount: markerData.length,
        itemBuilder: (context, markerIndex) {
          final marker = markerData[markerIndex];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    "assets/images/add_photo_icons.png",
                    height: 20,
                    width: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    marker.snippet, // Marker name
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: () {
                      // Implement view all functionality
                    },
                    child: const Text(
                      'View all',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Media grid layout
              if (marker.media != null && marker.media!.isNotEmpty)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: marker.media!.length.clamp(0, 3),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return MediaDetailsScreen(
                            url: marker.media![index],
                            markerData: marker,
                          );
                        }));
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: MediaItemWidget(url: marker.media![index]),
                      ),
                    );
                  },
                )
              else
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Implement add photo functionality
                    },
                    child: const Text("Add Photo"),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
