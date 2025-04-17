import 'package:coyotex/core/utills/media_widget.dart';
import 'package:coyotex/feature/map/data/trip_model.dart';
import 'package:coyotex/feature/trip/presentation/add_photos.dart';
import 'package:coyotex/feature/trip/presentation/media_details_screen.dart';
import 'package:coyotex/feature/trip/view_model/trip_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MarkerMediaScreen extends StatefulWidget {
  TripModel tripModel;

  MarkerMediaScreen({super.key, required this.tripModel});

  @override
  State<MarkerMediaScreen> createState() => _MarkerMediaScreenState();
}

class _MarkerMediaScreenState extends State<MarkerMediaScreen> {
  bool isLoading = false;
  getTripDetails() async {
    final provider = Provider.of<TripViewModel>(context, listen: false);
    setState(() {
      isLoading = true;
    });
    var response = await provider.getTripById(widget.tripModel.id);
    if (response.success) {
      widget.tripModel = TripModel.fromJson(response.data["data"]);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    getTripDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background to black
      appBar: AppBar(
        title: const Text(
          'Photos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        forceMaterialTransparency: true,
        backgroundColor: Colors.black, // Set AppBar background to black
        elevation: 4.0,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator.adaptive(
                backgroundColor: Colors.white,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              itemCount: widget.tripModel.markers.length,
              itemBuilder: (context, markerIndex) {
                final marker = widget.tripModel.markers[markerIndex];

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
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: Text(
                            marker.snippet, // Marker name
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                overflow: TextOverflow
                                    .ellipsis // Change text color to white
                                ),
                          ),
                        ),
                        const Spacer(),
                        if (marker.media!.length <= 3)
                          TextButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return AddPhotoScreen(
                                  markerData: marker,
                                );
                              })).then((value) async {
                                if (value) await getTripDetails();
                              });
                            },
                            child: const Text(
                              'Add Photo',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14), // Change text color to white
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
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
                                tripModel: widget.tripModel,
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
                  ],
                );
              },
            ),
    );
  }
}
