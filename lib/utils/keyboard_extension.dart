
import 'package:flutter/widgets.dart';

extension KeyboardUtils on BuildContext {
  // Method to hide the keyboard
  void hideKeyboard() {
    FocusScope.of(this).unfocus();
  }

  // Method to show the keyboard for a specific focus node
  void showKeyboard(FocusNode focusNode) {
    FocusScope.of(this).requestFocus(focusNode);
  }

  // Method to check if the keyboard is currently visible
  bool isKeyboardVisible() {
    return MediaQuery.of(this).viewInsets.bottom != 0;
  }
}
