import 'package:coyotex/core/utills/app_colors.dart';
import 'package:coyotex/core/utills/branded_primary_button.dart';
import 'package:coyotex/feature/auth/data/model/pref_model.dart';
import 'package:coyotex/feature/auth/data/view_model/user_view_model.dart';
import 'package:coyotex/feature/auth/screens/weather_prefrences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _referralController = TextEditingController();

  String? _selectedDistance;

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
  void initState() {
    // TODO: implement initState
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    _selectedDistance = userViewModel.user.userUnit!;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: userViewModel.isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
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
                            "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.2,
                          ),
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
                            height: MediaQuery.of(context).size.height * 0.15,
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
                                    // Show success feedback to the user
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Preferences updated successfully!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    Navigator.pop(context);
                                  } else {
                                    // Show error message from response or a generic one
                                    ScaffoldMessenger.of(context).showSnackBar(
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
                            const SizedBox(
                              height: 10,
                            ),
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
                                suffixIcon: const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                ),
                                name: "Save",
                                onPressed: () {
                                  widget.userPreferences?.userUnit =
                                      _selectedDistance!;
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return WeatherPreferenceScreen(
                                      userPreferences: widget.userPreferences,
                                    );
                                  }));
                                },
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: TextButton(
                                onPressed: () {
                                  widget.userPreferences?.userUnit = '';
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return WeatherPreferenceScreen(
                                      userPreferences: widget.userPreferences,
                                    );
                                  }));
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
          color: isSelected
              ? Colors.black.withOpacity(.7)
              : Colors.black.withOpacity(.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.black.withOpacity(.7)
                : Colors.black.withOpacity(.7),
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
            Center(child: Image.asset(imageUrl))
          ],
        ),
      ),
    );
  }
}
