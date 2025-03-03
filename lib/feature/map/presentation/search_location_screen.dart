import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coyotex/feature/map/view_model/map_provider.dart';

class SearchLocationScreen extends StatefulWidget {
  TextEditingController controller;
  bool isStart;

  SearchLocationScreen(
      {required this.isStart, required this.controller, super.key});

  @override
  State<SearchLocationScreen> createState() => _SearchLocationScreenState();
}

class _SearchLocationScreenState extends State<SearchLocationScreen> {
  @override
  Widget build(BuildContext context) {
    // Wrapping the widget tree with ChangeNotifierProvider
    return Builder(
      builder: (context) {
        // Accessing the provider within the correct tree
        final mapProvider = context.watch<MapProvider>();

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Search Location',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: widget.controller,
                  decoration: InputDecoration(
                    hintText: 'Search location...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: const Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    mapProvider.getPlaceSuggestions(value, true);
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: mapProvider.startSuggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = mapProvider.startSuggestions[index];
                    return ListTile(
                      leading: const Icon(Icons.location_on),
                      title: Text(suggestion['description'] ?? ''),
                      onTap: () async {
                        widget.controller.text =
                            suggestion['description'] ?? '';
                        mapProvider.startSuggestions.clear();
                        // await mapProvider
                        //     .onSuggestionSelected(suggestion['place_id'],
                        //         widget.isStart, widget.controller)
                        //     .then((valueKey) {
                        //   Navigator.of(context).pop(true);
                        // });
                        Map<String, dynamic> mapData = {
                          "placeId": suggestion['place_id'],
                          "isStart": widget.isStart,
                          // "controller": widget.controller.text
                        };
                        String data = jsonEncode(mapData);
                        Navigator.of(context).pop(data);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
