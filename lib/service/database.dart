import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Future addUserDetail(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .set(userInfoMap);
  }

  Future addItem(Map<String, dynamic> itemInfo) async {
    return await FirebaseFirestore.instance.collection("items").add(itemInfo);
  }

  Future<Stream<QuerySnapshot>> getUploadedItems() async {
    return FirebaseFirestore.instance.collection("items").snapshots();
  }
}
