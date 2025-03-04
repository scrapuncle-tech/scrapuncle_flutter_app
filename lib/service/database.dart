import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart'; // Import for Realtime Database

class DatabaseMethods {
  Future addUserDetail(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .set(userInfoMap);
  }

  // Add Item to Firestore under user's ID
  Future addItem(Map<String, dynamic> itemInfo, String userId) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("items")
        .add(itemInfo);
  }

  Future<Stream<QuerySnapshot>> getUploadedItems(String userId) async {
    print(
        "DatabaseMethods: getUploadedItems called for userId: $userId"); // Add this line

    return FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("items")
        .snapshots();
  }
}
