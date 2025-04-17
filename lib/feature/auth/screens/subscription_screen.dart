import 'package:coyotex/core/utills/app_colors.dart';
import 'package:coyotex/core/utills/branded_primary_button.dart';
import 'package:coyotex/feature/auth/data/model/pref_model.dart';
import 'package:coyotex/feature/auth/data/view_model/user_view_model.dart';
import 'package:coyotex/feature/auth/screens/prefrence_dstance_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String? _selectedPlanId;
  String? _selectedPlanPrice = ""; // Store selected plan ID

  @override
  void initState() {
    super.initState();
    getPlans();
  }

  void getPlans() {
    final authProvider = Provider.of<UserViewModel>(context, listen: false);
    authProvider.getSubscriptionPlan(); // Fetch plans from the provider
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Consumer<UserViewModel>(
            builder: (context, userViewModel, child) {
              if (userViewModel.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Pallete.primaryColor,
                  ),
                );
              }

              // Ensure lstPlan is populated
              if (userViewModel.lstPlan.isEmpty) {
                return const Center(
                  child: Text(
                    "No plans available",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/logo.png",
                          width: MediaQuery.of(context).size.width * 0.3,
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          "Coyotex",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Text(
                          "Stay on top of your hunting adventures with our all-in-one tracking app!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          "Select Suitable Plan",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // GridView to display subscription plans
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio:
                                3 / 2, // Adjusted aspect ratio for plan cards
                          ),
                          itemCount: userViewModel.lstPlan.length,
                          itemBuilder: (context, index) {
                            final plan = userViewModel.lstPlan[index];
                            return _buildPlanCard(plan.id, plan.planName,
                                plan.planAmount.toString());
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 40,
            left: 16,
            right: 16,
            child: BrandedPrimaryButton(
                isEnabled: _selectedPlanId !=
                    null, // Disable button if no plan is selected
                suffixIcon: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                ),
                name: "Make Payment",
                onPressed: () async {
                  if (_selectedPlanId != null) {
                    final userViewModel =
                        Provider.of<UserViewModel>(context, listen: false);

                    final paymentIntentResponse = await userViewModel
                        .createPaymentIntent(_selectedPlanPrice!, "usd");

                    if (paymentIntentResponse.success) {
                      String paymentId =
                          paymentIntentResponse.data["paymentId"];
                      final clientSecret =
                          paymentIntentResponse.data["clientSecret"];

                      try {
                        await Stripe.instance.initPaymentSheet(
                          paymentSheetParameters: SetupPaymentSheetParameters(
                            paymentIntentClientSecret: clientSecret,
                            merchantDisplayName: 'Coyotex',
                            style: ThemeMode.dark,
                          ),
                        );

                        await Stripe.instance.presentPaymentSheet();

                        var response =
                            await userViewModel.paymentStatus(paymentId);
                        if (response.success) {
                          UserPreferences userPreferences = UserPreferences(
                            userPlan: _selectedPlanId!,
                            userUnit: '',
                            userWeatherPref: '',
                          );

                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return PrefernceDistanceScreen(
                              userPreferences: userPreferences,
                            );
                          }));
                        }
                      } on StripeException catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Payment canceled: ${e.error.localizedMessage}')),
                        );
                      } catch (e) {
                        print(e);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Error: ${paymentIntentResponse.message}')),
                      );
                      print(paymentIntentResponse.message);
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please select a plan."),
                      ),
                    );
                  }
                }),
          )
        ],
      ),
    );
  }

  Widget _buildPlanCard(
    String planId,
    String title,
    String price,
  ) {
    final isSelected = _selectedPlanId == planId;

    return GestureDetector(
      onTap: () {
        _selectedPlanPrice = price;
        setState(() {
          _selectedPlanId = planId; // Update selected plan ID
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Pallete.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Pallete.primaryColor : Colors.transparent,
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
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "\$$price", //price,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
