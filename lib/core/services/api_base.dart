import 'package:coyotex/core/utills/constant.dart';
import 'package:coyotex/core/utills/shared_pref.dart';

class ApiBase {
  String accessToken = '';
  String refreshToken = '';
  ApiBase() {
    accessToken = SharedPrefUtil.getValue(accessTokenPref, "") as String;
    refreshToken = SharedPrefUtil.getValue(refreshTokenPref, "") as String;
    // city =
    //     SharedPrefUtil.getValue(loggedInUserCitySharedPrefName, "") as String;
    // industry =
    //     SharedPrefUtil.getValue(loggedInIndustrySharedPrefName, "") as String;
    // companySymbol =
    //     SharedPrefUtil.getValue(companySymbolSharedPrefName, "") as String;
  }
}
