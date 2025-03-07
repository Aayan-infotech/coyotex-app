String accessTokenPref = "accessToken-pref";
String getDeviceToken = "deviceToken-pref";
String refreshTokenPref = "refreshToken-pref";
String isLoginPref = "is_login";
String userIdPref = "is_userId-pref";
String publishableKey =
    "pk_test_51QzXeEB3q6LM1zdiXrU09LWORSx1JJHKm8vmfMce6r5QvFnc2d8grRqg3KOsr0d2cObfAi1xuKu5j15MnsggAto900L3rs6wSU";
String capitalizeFirstLetter(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

bool checkIfVideo(String url) {
  return url.endsWith('.mp4') ||
      url.endsWith('.mov') ||
      url.endsWith('.avi') ||
      url.endsWith('.MP4') ||
      url.endsWith('.MOV') ||
      url.endsWith('.AVI');
}
