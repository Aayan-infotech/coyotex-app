import 'package:coyotex/core/utills/branded_primary_button.dart';
import 'package:flutter/material.dart';

class GoogleMapsBottomSheet extends StatefulWidget {
  const GoogleMapsBottomSheet({super.key});

  @override
  State<GoogleMapsBottomSheet> createState() => _GoogleMapsBottomSheetState();
}

class _GoogleMapsBottomSheetState extends State<GoogleMapsBottomSheet> {
  int selectedMode = 0;
  final List<String> modes = ["Drive", "Bike", "Bus", "Walk"];
  final List<IconData> modeIcons = [
    Icons.directions_car,
    Icons.two_wheeler,
    Icons.directions_bus,
    Icons.directions_walk,
  ];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.3,
      maxChildSize: 0.6,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
          ),
          child: Column(
            children: [
              // Drag Handle
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              // Horizontal Mode Selector
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                child: Row(
                  children: List.generate(modes.length, (index) {
                    final isSelected = selectedMode == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedMode = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              modeIcons[index],
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              modes[index],
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              // Route Info
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Icon(modeIcons[selectedMode], size: 28, color: Colors.blue),
                    const SizedBox(width: 10),
                     const Expanded(
                      child: Text(
                        "4 hr 57 min (257 km)\n₹370.00 | Saves 14% petrol",
                        style: TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              // Start Button
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  children: [
                    Expanded(
                      child: BrandedPrimaryButton(
                        isEnabled: true,
                        name: "Start",
                        onPressed: () {},
                        borderRadius: 20,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: BrandedPrimaryButton(
                        isEnabled: true,
                        isUnfocus: true,
                        name: "Add Stop",
                        onPressed: () {},
                        borderRadius: 20,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
