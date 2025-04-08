import 'package:coyotex/core/utills/app_colors.dart';
import 'package:flutter/material.dart';

class BrandedPrimaryButton extends StatelessWidget {
  final String name;
  final VoidCallback onPressed;
  final bool isEnabled;
  final bool isUnfocus;
  final Widget? suffixIcon;
  final double borderRadius; // New parameter for border radius

  const BrandedPrimaryButton({
    super.key,
    this.isUnfocus = false,
    required this.name,
    required this.onPressed,
    this.isEnabled = false,
    this.suffixIcon,
    this.borderRadius = 10.0, // Default border radius
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 45,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isEnabled
                ? (isUnfocus ? Pallete.whiteColor : Pallete.primaryColor)
                : Theme.of(context).disabledColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: isEnabled
                  ? const BorderSide(color: Pallete.primaryColor)
                  : BorderSide.none,
              borderRadius: BorderRadius.circular(borderRadius),
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
                fontSize: (MediaQuery.of(context).size.width < 380) ? 14 : 16,
              ),
        ),
        if (suffixIcon != null) ...[
          const SizedBox(width: 8),
          suffixIcon!,
        ],
      ],
    );
  }
}
