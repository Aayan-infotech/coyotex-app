import 'package:coyotex/core/utills/app_colors.dart';
import 'package:coyotex/core/utills/branded_primary_button.dart';
import 'package:coyotex/core/utills/branded_text_filed.dart';
import 'package:coyotex/feature/map/view_model/map_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DurationPickerBottomSheet extends StatefulWidget {
  final bool isStop;

  const DurationPickerBottomSheet({Key? key, this.isStop = false})
      : super(key: key);

  @override
  _DurationPickerBottomSheetState createState() =>
      _DurationPickerBottomSheetState();
}

class _DurationPickerBottomSheetState extends State<DurationPickerBottomSheet> {
  final TextEditingController _minuteController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String? _selectedWindDirection;
  final List<String> _windDirections = [
    "North",
    "South",
    "East",
    "West",
    "Northeast",
    "Northwest",
    "Southeast",
    "Southwest"
  ];

  // Focus nodes for each text field
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _minuteFocusNode = FocusNode();

  @override
  void dispose() {
    // Dispose the focus nodes
    _nameFocusNode.dispose();
    _minuteFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MapProvider mapProvider = Provider.of<MapProvider>(context, listen: false);

    return GestureDetector(
      onTap: () {
        // Unfocus any active text field when tapping anywhere outside
        FocusScope.of(context).unfocus();
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.6,
        maxChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
            ),
            child: Column(
              children: [
                // Drag Handle
                Container(
                  width: 60,
                  height: 6,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 10),

                // Title
                const Text(
                  "Add Marker",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      children: [
                        // Name Input
                        BrandedTextField(
                          controller: _nameController,
                          focusNode: _nameFocusNode,
                          labelText: "Enter marker name (Optional)",
                          onTap: () {
                            // Scroll up when this field is tapped
                            scrollController.jumpTo(
                                scrollController.position.maxScrollExtent);
                          },
                        ),
                        const SizedBox(height: 16),

                        // Time Input
                        BrandedTextField(
                          controller: _minuteController,
                          focusNode: _minuteFocusNode,
                          labelText: "Enter time in minutes",
                          keyboardType: TextInputType.number,
                          onTap: () {
                            // Scroll up when this field is tapped
                            scrollController.jumpTo(
                                scrollController.position.maxScrollExtent);
                          },
                        ),
                        const SizedBox(height: 16),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Wind Direction",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        // Wind Direction Chips
                        Wrap(
                          spacing: 10.0, // Spacing between chips
                          runSpacing: 5.0, // Spacing between lines of chips
                          children: _windDirections.map((direction) {
                            return ChoiceChip(
                              label: Text(direction),
                              selected: _selectedWindDirection == direction,
                              onSelected: (bool selected) {
                                setState(() {
                                  _selectedWindDirection =
                                      selected ? direction : null;
                                });
                              },
                              selectedColor: Pallete.accentColor,
                              labelStyle: TextStyle(
                                color: _selectedWindDirection == direction
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                        child: BrandedPrimaryButton(
                            isEnabled: true,
                            isUnfocus: true,
                            name: "Cancel",
                            onPressed: () {})),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: BrandedPrimaryButton(
                          isEnabled: true,
                          name: "Set",
                          onPressed: () async {
                            if (_minuteController.text.isNotEmpty &&
                                _selectedWindDirection != null) {
                              try {
                                int minutes = int.parse(_minuteController.text);
                                await mapProvider.setTimeDuration(
                                    minutes, _nameController.text);
                                Navigator.of(context).pop(true);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text("Please enter a valid number"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("All fields are required"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }),
                    )
                  ],
                ),
                const SizedBox(height: 50),
              ],
            ),
          );
        },
      ),
    );
  }
}
