


const kEmailPattern =
    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

String? validateMobileNumber(String? value) {
  if (value == null) {
    return null;
  } else if (value.trim().isEmpty) {
    return "Please enter mobile number!";
  } else if (value.length < 7 || value.length > 11) {
    return "Please enter valid mobile number!";
  } else {
    return null;
  }
}

String? validateMobileNumberReg(String? value) {
  if (value == null || value.isEmpty) {
    // Mobile number is optional, so just return null if it's empty
    return null;
  }
  // Add your existing validation logic here
  final regex = RegExp(r'^\d+$');
  if (!regex.hasMatch(value)) {
    return 'Please enter a valid mobile number';
  }
  return null;
}



String? validatePassword(String? value) {
  if (value == null) {
    return null;
  } else if (value.isEmpty) {
    return "Please enter password!";
  } else if (value.length < 8){
    return "Password must be min eight digits!";
  } else{
    return null;
  }
}


String? validateOldPassword(String? value) {
  if (value == null) {
    return null;
  } else if (value.isEmpty) {
    return "Please enter old password!";
  } else {
    return null;
  }
}

String? validateConfirmPassword(String? value, String password) {
  if (value == null) {
    return null;
  } else if (value.isEmpty) {
    return "Please enter confirm password!";
  }  else if (value!=password) {
    return "New and confirm password must be same!";
  }else {
    return null;
  }
}

String? validateEmail(String? value) {
  if (value == null) {
    return null;
  } else if (value.isEmpty) {
    return "Please enter email address!";
  } else if (!RegExp(kEmailPattern).hasMatch(value.trim())) {
    return "Please enter valid email address!";
  } else {
    return null;
  }
}


String? validateFiled(String? value, String? error) {
  if (value == null) {
    return null;
  } else if (value.trim().isEmpty) {
    return error;
  } else {
    return null;
  }
}



String? validateCharacterLength(String? value, int length) {
  if (value == null) {
    return null;
  } else if (value.trim().isEmpty) {
    return "This field is empty";
  } else if (value.length < length) {
    return "It should be more then $length character";
  }
  return null;
}

String? validateSSNNumber(String? value) {
  if (value == null) {
    return null;
  } else if (value.isEmpty) {
    return "Enter the SSN number";
  } else if (value.length != 9) {
    return "Enter Valid SSN number 9 character";
  } else {
    return null;
  }
}


String? validateName(String? value) {
  if (value == null) {
    return null;
  } else if (value.trim().isEmpty) {
    return "Please enter name!";
  } else {
    return null;
  }
}


String? nameValidateFiled(String? value, String? error) {
  if (value == null) {
    return null;
  } else if (value.trim().isEmpty) {
    return error;
  }/* else if (value.length < 4) {
    return "It should be more then 3 letter";
  }*/ else {
    return null;
  }
}



String? validateDate(String? value) {
  if (value == null) {
    return null;
  } else if (value.trim().isEmpty) {
    return "Please enter date!";
  } else {
    return null;
  }
}
