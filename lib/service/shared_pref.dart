import 'dart:convert'; // Added import for JSON decoding
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  static String userIdKey = 'USERKEY';
  static String userNameKey = 'USERNAMEKEY';
  static String userPhoneNumberKey = 'USERPHONENUMBERKEY';
  static String userEmailKey = 'USEREMAILKEY';
  static String userProfileKey = 'USERPROFILEKEY';

  Future<bool> saveUserId(String getUserId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userIdKey, getUserId);
  }

  Future<bool> saveUserName(String getUserName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userNameKey, getUserName);
  }

  Future<bool> saveUserPhoneNumber(String getUserPhoneNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userPhoneNumberKey, getUserPhoneNumber);
  }

  Future<bool> saveUserEmail(String getUserEmail) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userEmailKey, getUserEmail);
  }

  Future<bool> saveUserProfile(String getUserProfile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userProfileKey, getUserProfile);
  }

  Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userIdKey);
  }

  Future<String?> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userNameKey);
  }

  Future<String?> getUserPhoneNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userPhoneNumberKey);
  }

  Future<String?> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmailKey);
  }

  Future<String?> getUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userProfileKey);
  }

  // New function to retrieve phone numbers and their associated items
  Future<Map<String, dynamic>?> getUserPhoneNumbersAndItems() async {
    // Assuming the phone numbers and items are stored in a specific format

    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Assuming the phone numbers and items are stored in a specific format
    // This is a placeholder implementation; adjust as necessary
    String? phoneNumbersJson = prefs.getString('USERPHONENUMBERSKEY');
    if (phoneNumbersJson != null) {
      return Map<String, dynamic>.from(json.decode(phoneNumbersJson));
    }
    return null;
  }
}
