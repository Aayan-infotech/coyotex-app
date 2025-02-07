import 'package:coyotex/core/utills/constant.dart';
import 'package:coyotex/core/utills/shared_pref.dart';

class ApiBase {
  String accessToken = '';
  String refreshToken = '';
  String userId = '';
  ApiBase() {
    accessToken = SharedPrefUtil.getValue(accessTokenPref, "") as String;
    refreshToken = SharedPrefUtil.getValue(refreshTokenPref, "") as String;
    userId = SharedPrefUtil.getValue(userIdPref, "") as String;
    print(accessToken);
  }
}
