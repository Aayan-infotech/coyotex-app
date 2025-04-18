import 'package:coyotex/core/utills/app_colors.dart';
import 'package:coyotex/core/utills/branded_primary_button.dart';
import 'package:coyotex/feature/auth/data/model/pref_model.dart';
import 'package:coyotex/feature/auth/data/view_model/user_view_model.dart';
import 'package:coyotex/feature/auth/screens/weather_prefrences.dart';
import 'package:coyotex/feature/map/view_model/map_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PrefernceDistanceScreen extends StatefulWidget {
  bool? isProfile;
  UserPreferences? userPreferences;
  PrefernceDistanceScreen(
      {this.userPreferences, this.isProfile = false, super.key});

  @override
  State<PrefernceDistanceScreen> createState() =>
      _PrefernceDistanceScreenState();
}

class _PrefernceDistanceScreenState extends State<PrefernceDistanceScreen> {
  String? _selectedDistance;

  @override
  void initState() {
    super.initState();
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    _selectedDistance = userViewModel.user.userUnit;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, userViewModel, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: userViewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
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
                                "Distance Unit",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Text(
                                "Select your preferred unit of distance for tracking and display.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.2),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildPlanCard(
                                      "Miles", "assets/images/miles.png"),
                                  const SizedBox(width: 16),
                                  _buildPlanCard("KM", "assets/images/km.png"),
                                ],
                              ),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.15),
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
                                BrandedPrimaryButton(
                                  isEnabled: true,
                                  name: "Save",
                                  onPressed: () async {
                                    UserPreferences userPreferences =
                                        UserPreferences(
                                      userPlan: '',
                                      userUnit: _selectedDistance!,
                                      userWeatherPref: '',
                                    );
                                    try {
                                      var response = await userViewModel
                                          .updatePref(userPreferences);
                                      if (response.success) {
                                        final provider =
                                            Provider.of<MapProvider>(context,
                                                listen: false);
                                        provider.calculateTotalDistance(
                                            isRefresh: true);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Preferences updated successfully!'),
                                              backgroundColor: Colors.green),
                                        );
                                        Navigator.pop(context);
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(response.message ??
                                                  'Failed to update preferences'),
                                              backgroundColor: Colors.red),
                                        );
                                      }
                                    } catch (e) {
                                      // _showErrorSheet(context, 'An error occurred: $e');
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
                              ],
                            )
                          : Row(
                              children: [
                                Flexible(
                                  flex: 3,
                                  child: BrandedPrimaryButton(
                                    isEnabled: _selectedDistance != null,
                                    suffixIcon: const Icon(Icons.arrow_forward,
                                        color: Colors.white),
                                    name: "Save",
                                    onPressed: () {
                                      widget.userPreferences?.userUnit =
                                          _selectedDistance!;
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) =>
                                            WeatherPreferenceScreen(
                                                userPreferences:
                                                    widget.userPreferences),
                                      ));
                                    },
                                  ),
                                ),
                                Flexible(
                                  flex: 1,
                                  child: TextButton(
                                    onPressed: () {
                                      widget.userPreferences?.userUnit = '';
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) =>
                                            WeatherPreferenceScreen(
                                                userPreferences:
                                                    widget.userPreferences),
                                      ));
                                    },
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
                ),
        );
      },
    );
  }

  Widget _buildPlanCard(String unit, String imageUrl) {
    final isSelected = _selectedDistance == unit;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDistance = unit;
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.black.withOpacity(.7),
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            if (isSelected)
              const Positioned(
                top: 8,
                right: 8,
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
