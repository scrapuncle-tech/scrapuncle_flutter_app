import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Future addUserDetail(Map<String, dynamic> userInfoMap, String id) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(id)
          .set(userInfoMap);
      print("User data added successfully to Firestore (ID: $id)");
    } catch (e) {
      print("Error adding user data to Firestore: $e");
    }
  }

  // Add Item to Firestore under the user's document and WITH the phone number document
  Future<void> addItem(
      Map<String, dynamic> itemInfo, String phoneNumber, String userId) async {
    // Ensure the phone number is valid
    if (phoneNumber == null || phoneNumber.isEmpty) {
      print("Error: Phone number is null or empty.");
      return; // Or throw an exception
    }
    try {
      // Construct the document path using the user's ID and DIRECTLY to the  phone number
      await FirebaseFirestore.instance
          .collection("users") // Top-level collection for all users
          .doc(userId) // Document ID is the user's ID
          .collection("phoneNumbers")
          .doc(phoneNumber)
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
      return const Stream.empty();
    }
    try {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection("phoneNumbers")
          .snapshots();
    } catch (e) {
      print("Error getting uploaded items stream: $e");
      return const Stream.empty(); // Return an empty stream on error
    }
  }
}
