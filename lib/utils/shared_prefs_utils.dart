
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

  static late SharedPreferences sharedPreferences;

  static Future<void> initSharedPreference() async
  {
    sharedPreferences = await SharedPreferences.getInstance();
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