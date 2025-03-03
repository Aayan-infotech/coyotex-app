import 'package:carousel_slider/carousel_slider.dart';
import 'package:coyotex/core/utills/media_widget.dart';
import 'package:coyotex/feature/map/data/trip_model.dart';
import 'package:flutter/material.dart';

class TripMediaScreen extends StatelessWidget {
  final List<MarkerData> markerData;

  TripMediaScreen({required this.markerData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Trip Images',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
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
              Text(
                marker.title, // Assuming MarkerData has a 'title' field
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              if (marker.media != null && marker.media!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: 280,
                      aspectRatio: 16 / 9,
                      viewportFraction: 0.85,
                      enableInfiniteScroll: true,
                      autoPlay: true,
                      autoPlayCurve: Curves.easeInOut,
                      enlargeCenterPage: true,
                      scrollPhysics: const BouncingScrollPhysics(),
                    ),
                    items: marker.media!.map((url) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8.0,
                              spreadRadius: 2.0,
                              offset: const Offset(2, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: MediaItemWidget(url: url),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              const SizedBox(height: 16),
              Divider(color: Colors.grey.shade400, thickness: 1.5),
              const SizedBox(height: 12),
            ],
          );
        },
      ),
    );
  }
}
