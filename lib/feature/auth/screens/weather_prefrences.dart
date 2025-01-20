import 'package:coyotex/core/utills/app_colors.dart';
import 'package:coyotex/core/utills/branded_primary_button.dart';
import 'package:coyotex/feature/homeScreen/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class WeatherPrefernceScreen extends StatefulWidget {
  const WeatherPrefernceScreen({super.key});

  @override
  State<WeatherPrefernceScreen> createState() => _WeatherPrefernceScreenState();
}

class _WeatherPrefernceScreenState extends State<WeatherPrefernceScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _referralController = TextEditingController();
  List<String> lstWeatherImage = [
    "assets/images/1.png",
    "assets/images/2.png",
    "assets/images/3.png",
    "assets/images/4.png",
    "assets/images/5.png",
    "assets/images/6.png",
  ];

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

  void _onSignupPressed() {
    if (_selectedDistance == null) {
      _showErrorSheet(context, "Please select a subscription plan.");
      return;
    }

    final username = _usernameController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      _showErrorSheet(context, "Passwords do not match. Please try again.");
    } else if (username.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showErrorSheet(context, "Please fill out all fields.");
    } else {
      print("Signup successful with plan: $_selectedDistance");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Weather Prefrences",
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

                    // Using GridView.builder for lstWeatherImage
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Number of columns in the grid
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.0, // Aspect ratio of each grid item
                      ),
                      itemCount: lstWeatherImage.length,
                      itemBuilder: (context, index) {
                        return _buildPlanCard(
                          "Weather $index", // Use dynamic weather name if needed
                          lstWeatherImage[index],
                        );
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
            child: Row(
              children: [
                Flexible(
                  flex: 3,
                  child: BrandedPrimaryButton(
                    isEnabled: true,
                    suffixIcon: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                    name: "Save",
                    onPressed: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return HomeScreen();
                      }));
                    },
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
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
