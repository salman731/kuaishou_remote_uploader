
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsUtil
{
  static final KEY_SELECTED_FOLDER = "SP_SELECTED_FOLDER";
  static final KEY_SELECTED_FOLDER_ID = "SP_SELECTED_FOLDER_ID";
  static final KEY_STREAMTAPE_COOKIE = "SP_STREAMTAPE_COOKIE";
  static final KEY_STREAMTAPE_CSRF_TOKEN = "SP_STREAMTAPE_CSRF_TOKEN";
  static final KEY_IS_CONCURRENT_PROCESS = "SP_IS_CONCURRENT_PROCESS";
  static final KEY_IS_WEB_PAGE_PROCESS = "SP_IS_WEB_PAGE_PROCESS";
  static final KEY_IS_AUTO_UPLOADING= "SP_IS_AUTO_UPLOADING";
  static final KEY_CURRENT_COOKIE= "SP_CURRENT_COOKIE";
  static final KEY_MIDNIGHT_SLIDER= "SP_MIDNIGHT_SLIDER";
  static final KEY_MORNINGAFTERNOON_SLIDER= "SP_MORNINGAFTERNOON_SLIDER";
  static final KEY_EVENINGNIGHT_SLIDER= "SP_EVENINGNIGHT_SLIDER";
  static final KEY_BACKGROUNDMODE_ENABLE= "SP_BACKGROUNDMODE_ENABLE";
  static final KEY_BACKGROUNDMODE_TIME= "SP_BACKGROUNDMODE_TIME";
  static final KEY_BACKGROUNDMODE_TIME_RANGE= "SP_BACKGROUNDMODE_TIME_RANGE";
  static final KEY_UNFOLLOW_USER_TIMER= "SP_UNFOLLOW_USER_TIMER";
  static final KEY_IS_NEW_FOLDER_CREATED= "SP_IS_NEW_FOLDER_CREATED";
  static final KEY_CURRENT_UNFOLLOW_MIN = "SP_CURRENT_UNFOLLOW_MIN";
  static final KEY_KUAISHOU_COOKIE = "SP_KUAISHOU_COOKIE";
  static final KEY_IS_CAPTCHA_VERFICATION_REQUIRED = "SP_IS_CAPTCHA_VERFICATION_REQUIRED";
  static final KEY_IS_FIRST_TIME = "SP_IS_FIRST_TIME";
  static final KEY_FOLLOW_LIVE_COOKIE = "SP_FOLLOW_LIVE_COOKIE";
  static final KEY_UNFOLLOW_API_INTERVAL = "SP_UNFOLLOW_API_INTERVAL";
  static final KEY_DOWNLOADING_FOLDER = "SP_DOWNLOADING_FOLDER";
  static final KEY_ENABLE_CONCURRENT_UNFOLLOW_USER_UPLOADING = "SP_ENABLE_CONCURRENT_UNFOLLOW_USER_UPLOADING";
  static final KEY_ENABLE_UPLOADING = "SP_ENABLE_UPLOADING";
  static final KEY_VERIFY_CAPTCHA_MANUAL = "SP_VERIFY_CAPTCHA_MANUAL";
  static final KEY_ENABLE_STREAMTAPE_FETCH_FROM_EMBEDED = "KEY_ENABLE_STREAMTAPE_FETCH_FROM_EMBEDED";

  static late SharedPreferences sharedPreferences;

  static Future<void> initSharedPreference() async
  {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  static Future<void> reloadSharedPreferences() async
  {
    await sharedPreferences.reload();
  }

  static void setBool (String key,bool value)
  {
    sharedPreferences.setBool(key, value);
  }

  static void setInt (String key,int value)
  {
    sharedPreferences.setInt(key, value);
  }

  static void setDouble (String key,double value)
  {
    sharedPreferences.setDouble(key, value);
  }

  static void setString (String key,String value)
  {
    sharedPreferences.setString(key, value);
  }

  static String getString (String key, {String defaultValue = ""})
  {
     return sharedPreferences.getString(key) ?? defaultValue;
  }

  static int getInt (String key, {int defaultValue = 0})
  {
    return sharedPreferences.getInt(key) ?? defaultValue;
  }

  static bool getBool (String key, {bool defaultValue = false})
  {
    return sharedPreferences.getBool(key) ?? defaultValue;
  }

  static double getDouble (String key, {double defaultValue = 0.0})
  {
    return sharedPreferences.getDouble(key) ?? defaultValue;
  }

}