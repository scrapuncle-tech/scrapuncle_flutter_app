import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Future addUserDetail(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .set(userInfoMap);
  }

  // Add Item to Firestore under the specified phone number
  Future addItem(
      Map<String, dynamic> itemInfo, String phoneNumber, String userId) async {
    // Ensure the phone number is valid
    if (phoneNumber == null || phoneNumber.isEmpty) {
      print("Error: Phone number is null or empty.");
      return null; // Or throw an exception
    }

    // Construct the document path using the phone number
    return await FirebaseFirestore.instance
        .collection("items") // Top-level collection for all items
        .doc(phoneNumber) // Document ID is the phone number
        .collection("userItems") // Subcollection to store user-specific items
        .doc(itemInfo['itemId']) // Using itemID as docID
        .set(itemInfo);
  }

  // Get Items Uploaded under the specified phone number by the user
  Future<Stream<QuerySnapshot>> getUploadedItems(String userId) async {
    return FirebaseFirestore.instance
        .collection("items")
        .where('userId', isEqualTo: userId) // Filter by user ID
        .snapshots();
  }
}
