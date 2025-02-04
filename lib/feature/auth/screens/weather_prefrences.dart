import 'package:coyotex/core/utills/app_colors.dart';
import 'package:coyotex/core/utills/branded_primary_button.dart';
import 'package:coyotex/feature/auth/data/model/pref_model.dart';
import 'package:coyotex/feature/auth/data/view_model/user_view_model.dart';
import 'package:coyotex/feature/homeScreen/screens/home_screen.dart';
import 'package:coyotex/utils/app_dialogue_box.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WeatherPreferenceScreen extends StatefulWidget {
  final bool? isProfile;
  final UserPreferences? userPreferences;

  WeatherPreferenceScreen(
      {this.userPreferences, this.isProfile = false, super.key});

  @override
  State<WeatherPreferenceScreen> createState() =>
      _WeatherPreferenceScreenState();
}

class _WeatherPreferenceScreenState extends State<WeatherPreferenceScreen> {
  final Map<String, String> weatherOptions = {
    'sunny': "assets/images/1.png",
    'monsoon': "assets/images/2.png",
    'cloudy': "assets/images/3.png",
    'rainy': "assets/images/4.png",
  };

  String? selectedWeatherId = '';

  void _onWeatherTap(String weatherId) {
    setState(() {
      selectedWeatherId = weatherId;
    });
  }

  @override
  void initState() {
    final userProvider = Provider.of<UserViewModel>(context, listen: false);
    selectedWeatherId = userProvider.user.userWeatherPref;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<UserViewModel>(
        builder: (context, userViewModel, child) {
          return userViewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Weather Preferences",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Select your preferred weather condition.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: GridView.builder(
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.0,
                          ),
                          itemCount: weatherOptions.keys.length,
                          itemBuilder: (context, index) {
                            final weatherId =
                                weatherOptions.keys.elementAt(index);
                            final imageUrl = weatherOptions[weatherId]!;
                            return _buildWeatherCard(weatherId, imageUrl);
                          },
                        ),
                      ),
                      if (widget.isProfile!) ...[
                        BrandedPrimaryButton(
                          isEnabled: selectedWeatherId?.isNotEmpty ?? false,
                          name: "Save",
                          onPressed: () async {
                            UserPreferences userPreferences = UserPreferences(
                              userPlan: '',
                              userUnit: '',
                              userWeatherPref: selectedWeatherId!,
                            );

                            try {
                              var response = await userViewModel
                                  .updatePref(userPreferences);
                              if (response.success) {
                                AppDialog.showSuccessDialog(
                                    context, response.message, () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                });
                              } else {
                                AppDialog.showErrorDialog(
                                    context, response.message, () {
                                  Navigator.of(context).pop();
                                });
                              }
                            } catch (e) {
                              AppDialog.showErrorDialog(
                                  context, 'An error occurred: $e', () {
                                Navigator.of(context).pop();
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        BrandedPrimaryButton(
                          isUnfocus: true,
                          isEnabled: true,
                          name: "Cancel",
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ] else ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: BrandedPrimaryButton(
                                isEnabled:
                                    selectedWeatherId?.isNotEmpty ?? false,
                                suffixIcon: const Icon(Icons.arrow_forward,
                                    color: Colors.white),
                                name: "Save",
                                onPressed: () async {
                                  widget.userPreferences!.userWeatherPref =
                                      selectedWeatherId!;
                                  try {
                                    var response = await userViewModel
                                        .updatePref(widget.userPreferences!);
                                    if (response.success) {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  HomeScreen()));
                                    } else {
                                      AppDialog.showErrorDialog(
                                          context,
                                          response.message ??
                                              'Failed to update preferences',
                                          () {
                                        Navigator.of(context).pop();
                                      });
                                    }
                                  } catch (e) {
                                    AppDialog.showErrorDialog(
                                        context, 'An error occurred: $e', () {
                                      Navigator.of(context).pop();
                                    });
                                  }
                                },
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text(
                                "Skip",
                                style: TextStyle(
                                  color: Pallete.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                );
        },
      ),
    );
  }

  Widget _buildWeatherCard(String weatherId, String imageUrl) {
    final isSelected = selectedWeatherId == weatherId;

    return GestureDetector(
      onTap: () => _onWeatherTap(weatherId),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.black.withOpacity(.9)
              : Colors.black.withOpacity(.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected ? Colors.white : Colors.grey, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imageUrl),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }
}
