import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:random_string/random_string.dart';

class DatabaseMethods {
  Future addUserDetail(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .set(userInfoMap);
  }

  Future<void> addItem(
      Map<String, dynamic> itemInfo, String phoneNumber, String userId) async {
    // Ensure the phone number is valid
    if (phoneNumber == null || phoneNumber.isEmpty) {
      print("Error: Phone number is null or empty.");
      return;
    }

    // Add a unique item ID to the item info
    String itemId = randomAlphaNumeric(10);
    itemInfo['itemId'] = itemId;

    // Construct the document path using the user's ID and phone number and Item ID
    try {
      await FirebaseFirestore.instance
          .collection("users") // Top-level collection for all users
          .doc(userId) // Document ID is the user's ID
          .collection("phoneNumbers")
          .doc(phoneNumber)
          .collection("items")
          .doc(itemId)
          .set(itemInfo);
      print(
          "Item data added successfully to Firestore (User: $userId, Phone Number: $phoneNumber)");
    } catch (e) {
      print("Error adding item data to Firestore: $e");
    }
  }

  Stream<QuerySnapshot> getUploadedItems(String userId) {
    if (userId == null || userId.isEmpty) {
      print("Warning: User ID is null or empty. Returning empty stream.");
      return const Stream<QuerySnapshot>.empty();
    }
    try {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection("phoneNumbers")
          .snapshots();
    } catch (e) {
      print("Error getting uploaded items stream: $e");
      return const Stream<
          QuerySnapshot>.empty(); // Return an empty stream on error
    }
  }
}
