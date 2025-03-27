import 'dart:convert';

import 'package:coyotex/core/utills/constant.dart';
import 'package:coyotex/feature/trip/view_model/trip_view_model.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../view_model/map_provider.dart';
import 'package:http/http.dart' as http;

class AddStopMap extends StatefulWidget {
  const AddStopMap({super.key});

  @override
  State<AddStopMap> createState() => _AddStopMapState();
}

class _AddStopMapState extends State<AddStopMap> {
  TextEditingController searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  MapType _currentMapType = MapType.hybrid;

  void _showLayerDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).dialogBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                height: 4,
                width: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Text(
                      "Map Style",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ..._buildLayerOptions(),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildLayerOptions() {
    return [
      _buildLayerOption("Normal", MapType.normal, Icons.map_outlined),
      _buildLayerOption("Satellite", MapType.satellite, Icons.satellite_alt),
      _buildLayerOption("Terrain", MapType.terrain, Icons.terrain),
      _buildLayerOption("Hybrid", MapType.hybrid, Icons.layers),
    ];
  }

  Widget _buildLayerOption(String title, MapType type, IconData icon) {
    final isSelected = _currentMapType == type;
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _currentMapType = type;
            Navigator.pop(context);
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                isSelected ? theme.colorScheme.primary.withOpacity(0.1) : null,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: theme.colorScheme.primary.withOpacity(0.3))
                : null,
          ),
          child: Row(
            children: [
              Icon(icon,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface),
              const SizedBox(width: 16),
              Text(title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  )),
              const Spacer(),
              Radio<MapType>(
                value: type,
                groupValue: _currentMapType,
                toggleable: true,
                fillColor: MaterialStateProperty.resolveWith<Color>(
                  (states) => isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
                onChanged: (value) {
                  setState(() {
                    _currentMapType = value!;
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tripProvider = Provider.of<TripViewModel>(context, listen: false);
    Set<Marker> lstMarker = {};
    for (var item in tripProvider.lstMarker) {
      lstMarker.add(Marker(
        markerId: MarkerId(item.id),
        position: item.position,
        //icon: icons[item.icon] ?? icons["markerIcon"]!,
        infoWindow: InfoWindow(title: item.title, snippet: item.snippet),
      ));
    }
    return Theme(
      data: ThemeData(
        primaryColor: Colors.red,
        colorScheme:
            ColorScheme.fromSwatch().copyWith(secondary: Colors.redAccent),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Add Stop', style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: Colors.red[800],
          elevation: 0,
          shadowColor: Colors.red[900],
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Consumer<MapProvider>(
          builder: (context, mapProvider, child) {
            return mapProvider.isLoading
                ? Center(child: CircularProgressIndicator.adaptive())
                : Stack(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: mapProvider.initialPosition,
                                zoom: 12,
                              ),
                              markers: lstMarker,
                              onMapCreated: (controller) =>
                                  mapProvider.onMapCreated(controller),
                              onTap: (LatLng position) {
                                mapProvider.isAddStopButton = true;
                                mapProvider.addStop(position);
                              },
                              myLocationButtonEnabled: true,
                              myLocationEnabled: true,
                              mapToolbarEnabled: true,
                              buildingsEnabled: true,
                              mapType: _currentMapType,
                            ),
                            if (mapProvider.startSuggestions.isNotEmpty)
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                top: _searchFocusNode.hasFocus ? 80 : -300,
                                left: 10,
                                right: 10,
                                child: Material(
                                  elevation: 8,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    height: 250,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border:
                                          Border.all(color: Colors.red[100]!),
                                    ),
                                    child: ListView.builder(
                                      itemCount:
                                          mapProvider.startSuggestions.length,
                                      itemBuilder: (context, index) {
                                        final suggestion =
                                            mapProvider.startSuggestions[index];
                                        return InkWell(
                                          onTap: () async {
                                            await onSuggestionSelected(
                                                suggestion['place_id'],
                                                context,
                                                mapProvider);
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                    color: Colors.red[50]!),
                                              ),
                                            ),
                                            child: ListTile(
                                              leading: Icon(Icons.location_on,
                                                  color: Colors.red[700]),
                                              title: Text(
                                                suggestion['description'],
                                                style: TextStyle(
                                                    color: Colors.grey[800],
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              trailing: Icon(
                                                  Icons.arrow_forward_ios,
                                                  size: 16,
                                                  color: Colors.red[300]),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(15),
                        child: TextField(
                          controller: searchController,
                          focusNode: _searchFocusNode,
                          decoration: InputDecoration(
                            hintText: 'Search for a place...',
                            hintStyle: TextStyle(color: Colors.grey[600]),
                            prefixIcon:
                                Icon(Icons.search, color: Colors.red[700]),
                            suffixIcon: searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.clear,
                                        color: Colors.red[700]),
                                    onPressed: () {
                                      searchController.clear();
                                      mapProvider.getPlaceSuggestions('', true);
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide:
                                  BorderSide(color: Colors.red[700]!, width: 2),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onChanged: (value) {
                            mapProvider.getPlaceSuggestions(value, true);
                          },
                        ),
                      ),
                      Positioned(
                        top: 70,
                        right: 5,
                        child: IconButton(
                          onPressed: _showLayerDialog,
                          icon: const Icon(
                            Icons.layers,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  );
          },
        ),

        // body: Stack(
        //   children: [

        //     Expanded(
        //       child: Stack(
        //         children: [
        //           Consumer<MapProvider>(
        //             builder: (context, mapProvider, child) {
        //               return GoogleMap(
        //                 initialCameraPosition: CameraPosition(
        //                   target: mapProvider.initialPosition,
        //                   zoom: 12,
        //                 ),
        //                 markers: lstMarker,
        //                 onMapCreated: (controller) =>
        //                     mapProvider.onMapCreated(controller),
        //                 onTap: (LatLng position) {
        //                   mapProvider.isAddStopButton = true;

        //                   mapProvider.addStop(
        //                     position,
        //                   );
        //                 },
        //                 myLocationButtonEnabled: true,
        //                 myLocationEnabled: true,
        //                 mapToolbarEnabled: true,
        //                 buildingsEnabled: true,
        //                 mapType: _currentMapType,
        //               );
        //             },
        //           ),
        //           Consumer<MapProvider>(
        //             builder: (context, mapProvider, child) {
        //               if (mapProvider.startSuggestions.isEmpty) {
        //                 return const SizedBox.shrink();
        //               }
        //               return AnimatedPositioned(
        //                 duration: const Duration(milliseconds: 300),
        //                 curve: Curves.easeInOut,
        //                 top: _searchFocusNode.hasFocus ? 80 : -300,
        //                 left: 10,
        //                 right: 10,
        //                 child: Material(
        //                   elevation: 8,
        //                   borderRadius: BorderRadius.circular(12),
        //                   child: Container(
        //                     height: 250,
        //                     padding: const EdgeInsets.all(8),
        //                     decoration: BoxDecoration(
        //                       color: Colors.white,
        //                       borderRadius: BorderRadius.circular(12),
        //                       border: Border.all(color: Colors.red[100]!),
        //                     ),
        //                     child: ListView.builder(
        //                       itemCount: mapProvider.startSuggestions.length,
        //                       itemBuilder: (context, index) {
        //                         final suggestion =
        //                             mapProvider.startSuggestions[index];
        //                         return InkWell(
        //                           onTap: () {
        //                             // Handle suggestion selection
        //                           },
        //                           child: Container(
        //                             decoration: BoxDecoration(
        //                               border: Border(
        //                                 bottom:
        //                                     BorderSide(color: Colors.red[50]!),
        //                               ),
        //                             ),
        //                             child: ListTile(
        //                               leading: Icon(Icons.location_on,
        //                                   color: Colors.red[700]),
        //                               title: Text(
        //                                 suggestion['description'],
        //                                 style: TextStyle(
        //                                     color: Colors.grey[800],
        //                                     fontWeight: FontWeight.w500),
        //                               ),
        //                               trailing: Icon(Icons.arrow_forward_ios,
        //                                   size: 16, color: Colors.red[300]),
        //                             ),
        //                           ),
        //                         );
        //                       },
        //                     ),
        //                   ),
        //                 ),
        //               );
        //             },
        //           ),
        //         ],
        //       ),
        //     ),
        //     Material(
        //       elevation: 4,
        //       borderRadius: BorderRadius.circular(15),
        //       child: TextField(
        //         controller: searchController,
        //         focusNode: _searchFocusNode,
        //         decoration: InputDecoration(
        //           hintText: 'Search for a place...',
        //           hintStyle: TextStyle(color: Colors.grey[600]),
        //           prefixIcon: Icon(Icons.search, color: Colors.red[700]),
        //           suffixIcon: searchController.text.isNotEmpty
        //               ? IconButton(
        //                   icon: Icon(Icons.clear, color: Colors.red[700]),
        //                   onPressed: () {
        //                     searchController.clear();
        //                     Provider.of<MapProvider>(context, listen: false)
        //                         .getPlaceSuggestions('', true);
        //                   },
        //                 )
        //               : null,
        //           filled: true,
        //           fillColor: Colors.white,
        //           border: OutlineInputBorder(
        //             borderRadius: BorderRadius.circular(15),
        //             borderSide: BorderSide.none,
        //           ),
        //           focusedBorder: OutlineInputBorder(
        //             borderRadius: BorderRadius.circular(15),
        //             borderSide: BorderSide(color: Colors.red[700]!, width: 2),
        //           ),
        //           contentPadding: const EdgeInsets.symmetric(vertical: 16),
        //         ),
        //         onChanged: (value) {
        //           // Moved outside InputDecoration
        //           Provider.of<MapProvider>(context, listen: false)
        //               .getPlaceSuggestions(value, true);
        //         },
        //       ),
        //     ),
        //     Positioned(
        //         top: 70,
        //         right: 5,
        //         child: IconButton(
        //             onPressed: _showLayerDialog,
        //             icon: const Icon(
        //               Icons.layers,
        //               color: Colors.red,
        //             ))),
        //   ],
        // ),
      ),
    );
  }

  Future<void> onSuggestionSelected(String placeId, BuildContext buildContext,
      MapProvider mapProvider) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$kGoogleApiKey';

    try {
      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);

      if (data['status'] == 'OK') {
        final location = data['result']['geometry']['location'];
        final latAndLng = LatLng(location['lat'], location['lng']);

        mapProvider.isAddStopButton = true;
        mapProvider.addStop(latAndLng);
      }
    } catch (e) {
      debugPrint("Error fetching place details: $e");
    }
  }
}
