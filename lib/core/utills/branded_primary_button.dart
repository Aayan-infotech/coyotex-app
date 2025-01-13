import 'package:coyotex/core/utills/app_colors.dart';
import 'package:flutter/material.dart';

class BrandedPrimaryButton extends StatelessWidget {
  final String name;
  final VoidCallback onPressed;
  final bool isEnabled;
  final bool isUnfocus;
  final Widget? suffixIcon; // New parameter for suffix icon

  const BrandedPrimaryButton({
    super.key,
    this.isUnfocus = false,
    required this.name,
    required this.onPressed,
    this.isEnabled = false,
    this.suffixIcon, // Include suffixIcon in the constructor
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isEnabled
          ? SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isUnfocus ? Pallete.black87 : Pallete.primaryColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      color: Pallete.primaryColor,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: getButtonText(context),
              ),
            )
          : SizedBox(
              height: 46,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: null, // Disabled button, onPressed is null
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).disabledColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                ),
                child: getButtonText(context),
              ),
            ),
    );
  }

  Widget getButtonText(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          name,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: isUnfocus ? Pallete.primaryColor : Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: (MediaQuery.of(context).size.width < 380) ? 14 : 20,
              ),
        ),
        if (suffixIcon != null) ...[
          const SizedBox(width: 8), // Add space between text and icon
          suffixIcon!, // Display the suffix icon if it's provided
        ],
      ],
    );
  }
}
