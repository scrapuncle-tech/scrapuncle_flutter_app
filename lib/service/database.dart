import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Future addUserDetail(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .set(userInfoMap);
  }

  // Add Item to Firestore under the user's document and phone number
  Future addItem(
      Map<String, dynamic> itemInfo, String phoneNumber, String userId) async {
    // Ensure the phone number is valid
    if (phoneNumber == null || phoneNumber.isEmpty) {
      print("Error: Phone number is null or empty.");
      return null; // Or throw an exception
    }

    // Construct the document path using the user's ID and phone number
    return await FirebaseFirestore.instance
        .collection("users") // Top-level collection for all users
        .doc(userId) // Document ID is the user's ID
        .collection("phoneNumbers")
        .doc(phoneNumber)
        .collection("items")
        .doc(itemInfo['itemId'])
        .set(itemInfo);
  }

  // Get Items Uploaded under the specified phone number by the user
  Future<Stream<QuerySnapshot>> getUploadedItems(String userId) async {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("phoneNumbers")
        .snapshots();
  }
}
