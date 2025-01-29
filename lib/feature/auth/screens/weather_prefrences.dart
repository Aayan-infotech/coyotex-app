import 'package:coyotex/core/utills/app_colors.dart';
import 'package:coyotex/core/utills/branded_primary_button.dart';
import 'package:coyotex/feature/auth/data/model/pref_model.dart';
import 'package:coyotex/feature/auth/data/view_model/user_view_model.dart';
import 'package:coyotex/feature/homeScreen/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WeatherPrefernceScreen extends StatefulWidget {
  final bool? isProfile;
  final UserPreferences? userPreferences;

  WeatherPrefernceScreen(
      {this.userPreferences, this.isProfile = false, super.key});

  @override
  State<WeatherPrefernceScreen> createState() => _WeatherPrefernceScreenState();
}

class _WeatherPrefernceScreenState extends State<WeatherPrefernceScreen> {
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

  void _showErrorSheet(BuildContext context, String message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.red,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 40,
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Dismiss"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<UserViewModel>(
        builder: (context, userViewModel, child) {
          return userViewModel.isLoading
              ? Center(child: CircularProgressIndicator.adaptive())
              : Stack(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                              GridView.builder(
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
                                  return _buildPlanCard(weatherId, imageUrl);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 16,
                      right: 16,
                      child: widget.isProfile!
                          ? Column(
                              children: [
                                const SizedBox(height: 30),
                                BrandedPrimaryButton(
                                  isEnabled:
                                      selectedWeatherId?.isNotEmpty ?? false,
                                  name: "Save",
                                  onPressed: () async {
                                    UserPreferences userPreferences =
                                        UserPreferences(
                                      userPlan: '',
                                      userUnit: '',
                                      userWeatherPref: selectedWeatherId!,
                                    );

                                    try {
                                      var response = await userViewModel
                                          .updatePref(userPreferences);
                                      if (response.success) {
                                        // Show success feedback to the user
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Preferences updated successfully!'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                        Navigator.pop(context);
                                      } else {
                                        // Show error message from response or a generic one
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(response.message ??
                                                'Failed to update preferences'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      _showErrorSheet(
                                          context, 'An error occurred: $e');
                                    }
                                  },
                                ),
                                const SizedBox(height: 10),
                                BrandedPrimaryButton(
                                  isUnfocus: true,
                                  isEnabled: true,
                                  name: "Cancel",
                                  onPressed: () {},
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Flexible(
                                  flex: 3,
                                  child: BrandedPrimaryButton(
                                    isEnabled:
                                        selectedWeatherId?.isNotEmpty ?? false,
                                    suffixIcon: const Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                    ),
                                    name: "Save",
                                    onPressed: () async {
                                      widget.userPreferences!.userWeatherPref =
                                          selectedWeatherId!;
                                      try {
                                        var response =
                                            await userViewModel.updatePref(
                                                widget.userPreferences!);
                                        if (response.success) {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return HomeScreen();
                                          }));
                                        } else {
                                          _showErrorSheet(
                                              context,
                                              response.message ??
                                                  'Failed to update preferences');
                                        }
                                      } catch (e) {
                                        _showErrorSheet(
                                            context, 'An error occurred: $e');
                                      }
                                    },
                                  ),
                                ),
                                Flexible(
                                  flex: 1,
                                  child: TextButton(
                                    onPressed: () {},
                                    child: const Text(
                                      "Skip",
                                      style: TextStyle(
                                          color: Pallete.primaryColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                );
        },
      ),
    );
  }

  Widget _buildPlanCard(String weatherId, String imageUrl) {
    final isSelected = selectedWeatherId == weatherId;

    return GestureDetector(
      onTap: () => _onWeatherTap(weatherId),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        height: 160,
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.black.withOpacity(.9)
              : Colors.black.withOpacity(.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.grey,
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            if (isSelected)
              const Positioned(
                top: 8,
                right: 6,
                child: Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            Center(child: Image.asset(imageUrl)),
          ],
        ),
      ),
    );
  }
}
