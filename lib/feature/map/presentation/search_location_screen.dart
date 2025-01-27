import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coyotex/feature/map/view_model/map_provider.dart';

class SearchLocationScreen extends StatefulWidget {
  const SearchLocationScreen({super.key});

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
            title: const Text('Search Location'),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: mapProvider.startController,
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
                        mapProvider.startController.text =
                            suggestion['description'] ?? '';
                        mapProvider.startSuggestions.clear();
                        await mapProvider
                            .onSuggestionSelected(
                          suggestion['place_id'],
                          true, // Change to false if it's the destination field
                        )
                            .then((valueKey) {
                          Navigator.of(context).pop(true);
                        });
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
