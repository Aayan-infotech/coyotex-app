import 'package:flutter/material.dart';

class AppDialog {
  static void showErrorDialog(
      BuildContext context, String message, VoidCallback? onOkPressed) {
    _showDialog(
      context: context,
      title: "Error",
      message: message,
      icon: Icons.error,
      iconColor: Colors.red,
      buttonColor: Colors.red,
      showSecondary: false,
      onOkPressed: onOkPressed,
    );
  }

  static void showSuccessDialog(
      BuildContext context, String message, VoidCallback? onOkPressed,
      {
        String title = "Success",
        bool showSecondary = false,
      IconData icon = Icons.check_circle,
      Color iconClr = Colors.green}) {
    _showDialog(
      context: context,
      title: title,
      message: message,
      icon: icon,
      iconColor: iconClr,
      buttonColor: Colors.green,
      showSecondary: showSecondary,
      onOkPressed: onOkPressed,
    );
  }

  static void _showDialog({
    required BuildContext context,
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
    required Color buttonColor,
    required bool showSecondary,
    VoidCallback? onOkPressed,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            if (showSecondary)
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () {
                  if (onOkPressed != null) {
                    Navigator.pop(context);
                  }
                },
                child: const Text("Cancel"),
              ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: buttonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () {
                if (onOkPressed != null) {
                  onOkPressed();
                }
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
