
import 'package:shared_preferences/shared_preferences.dart';

//This wrapper over SharedPreferences is needed as flutter doesn't provide
//non-async method for getting preferences. This is becoming a problem as
//at some places getting pref in constructor is required and constructors
//can't be async in flutter.
class SharedPrefUtil {
  static late final SharedPreferences preferences;
  static bool _init = false;
  static Future init() async {
    if (_init) return;
    preferences = await SharedPreferences.getInstance();
    _init = true;
    return preferences;
  }

  static void setPushNotiicationRelatedPermissions(bool value) {
    // setValue(pushNotificationsRelatedPermissionsGranted, value);
  }

  static void logIn(companyId, userRole, user, domain, email, number) {
    // SharedPrefUtil.setValue(companySymbolSharedPrefName, companyId);
    // SharedPrefUtil.setValue(isLogedinSharedPrefName, true);
    // SharedPrefUtil.setValue(roleSharedPref, userRole);
    // SharedPrefUtil.setValue(loggedInUserMobileSharedPrefName, user);
    // SharedPrefUtil.setValue(domainSharedPref, domain);
    // SharedPrefUtil.setValue(emailPref, email);
    // SharedPrefUtil.setValue(adminNumber, number);
  }

  static void addLoggedInUserNameAndCompanyImage(userName, image) {
    // SharedPrefUtil.setValue(loggedInUserName, userName);
    // SharedPrefUtil.setValue(companyImage, image);
  }

  static void logOut() {
    // clearValue(isLogedIn);

    // clearValue(isLogedinSharedPrefName);
    // clearValue(loggedInUserCitySharedPrefName);
    // clearValue(roleSharedPref);
    // clearValue(loggedInIndustrySharedPrefName);
    // clearValue(loggedInUserMobileSharedPrefName);
    // clearValue(loggedInUserName);
    // clearValue(companyImage);
    // clearValue(moreFunctionTilesSharedPref);
    // clearValue(visibleTilesSharedPref);
    // clearValue(teamAdded);
    // clearValue(modelAdded);
    // clearValue(letterHeadAdded);
    // clearValue(rgisteredSubdomainSharedPref);
    // clearValue(isOnBoardingSkip);
    // clearValue(areAllLeadsCachedCachePrefix);
    // clearValue(areAllOpetatorCachedCachePrefix);
    // clearValue(isAllInventoryCachedPrefix);
    // clearValue(isAllBookingCachedPrefix);
    // clearValue(lasBookingIdCacheKey);
    // clearValue(isShowToutrial);
    // clearValue(adminImage);
    // clearValue(adminSharedPref);
    // clearValue(tokenSharedPrefUserId);
    // clearValue(tokenSharedPref);
    // clearValue(adminNumber);
    // clearValue(adminImage);

    //DbManager().deleteFullLocalCache();
    // PDFApi.deleteFile(userDetailsLocalFilePath);
    // PDFApi.deleteFile(product_category);
    // PDFApi.deleteFile(salonServicesLocalFilePath);
    // LoginWith().googleLogout();
  }

  static setValue(String key, Object value) {
    switch (value.runtimeType) {
      case String:
        preferences.setString(key, value as String);
        break;
      case bool:
        preferences.setBool(key, value as bool);
        break;
      case int:
        preferences.setInt(key, value as int);
        break;
      default:
        throw Exception("Not implemented.");
    }
  }

  static clearValue(String key) {
    preferences.remove(key);
  }

  static Object getValue(String key, Object defaultValue) {
    switch (defaultValue.runtimeType) {
      case String:
        return preferences.getString(key) ?? defaultValue;
      case bool:
        return preferences.getBool(key) ?? defaultValue as bool;
      case int:
        return preferences.getInt(key) ?? defaultValue as int;
      default:
        return defaultValue;
    }
  }

  static setStringListValue(String key, List<String> value) {
    preferences.setStringList(key, value);
  }

  static List<String>? getStringListValue(String key) {
    return preferences.getStringList(key);
  }

  static List<String>? getStringListNotALead(String key) {
    preferences.reload();
    return preferences.getStringList(key);
  }
}
