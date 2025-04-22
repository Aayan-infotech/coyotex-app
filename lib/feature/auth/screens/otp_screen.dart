import 'package:coyotex/core/utills/app_colors.dart';
import 'package:coyotex/core/utills/branded_primary_button.dart';
import 'package:coyotex/core/utills/constant.dart';
import 'package:coyotex/core/utills/shared_pref.dart';
import 'package:coyotex/feature/auth/data/view_model/user_view_model.dart';
import 'package:coyotex/feature/auth/screens/passowrd_screen.dart';
import 'package:coyotex/feature/auth/screens/subscription_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:provider/provider.dart';

class OtpScreen extends StatefulWidget {
  bool isResetPassward;
  final String email;

  OtpScreen({this.isResetPassward = false, required this.email, super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String otpNumber = ''; // Track the entered OTP

  void _showIncorrectPasswordSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Pallete.primaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return const SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline,
                  color: Colors.white,
                  size: 40,
                ),
                SizedBox(height: 10),
                Text(
                  "Incorrect OTP",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<UserViewModel>(
        builder: (context, authProvider, child) {
          return authProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/logo.png",
                            width: MediaQuery.of(context).size.width * 0.2,
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            "Enter OTP",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700),
                          ),
                          const Text(
                            "Stay on top of your hunting adventures with our all-in-one tracking app!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 30),
                          OtpTextField(
                            numberOfFields: 6,
                            // Set to 6 digits
                            borderColor: Colors.white,
                            // Set border color to white

                            focusedBorderColor: Colors.white,
                            showFieldAsBox: true,
                            // Enables rectangular border
                            textStyle: const TextStyle(color: Colors.white),
                            borderRadius: BorderRadius.circular(4),
                            // Subtle rounded corners
                            onSubmit: (String otp) async {
                              setState(() {
                                otpNumber = otp;
                              });
                            },
                            onCodeChanged: (value) {
                              setState(() {
                                otpNumber = value;
                              });
                            },
                          ),
                          const SizedBox(height: 30),
                          BrandedPrimaryButton(
                            isEnabled: otpNumber.length == 6,
                            name: "Continue",
                            onPressed: () async {
                              if (widget.isResetPassward) {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) {
                                  return PasswordScreen(
                                    email: widget.email,
                                    otp: otpNumber,
                                  );
                                }));
                              } else {
                                // Navigator.of(context)
                                //     .push(MaterialPageRoute(builder: (context) {
                                //   return const SubscriptionScreen();
                                // }));
                                final responce = await authProvider.verifyOTP(
                                    widget.email, otpNumber);
                                if (!responce.success) {
                                  _showIncorrectPasswordSheet(context);
                                } else {
                                  SharedPrefUtil.setValue(accessTokenPref,
                                      responce.data["accessToken"]);
                                  SharedPrefUtil.setValue(refreshTokenPref,
                                      responce.data["refreshToken"]);
                                  // SharedPrefUtil.setValue(isLoginPref, true);

                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return const SubscriptionScreen(
                                        from: "otp");
                                  }));
                                }
                              }
                            }, // Logic handled in OTP field's onSubmit
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.width * 0.3,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
        },
      ),
    );
  }
}
