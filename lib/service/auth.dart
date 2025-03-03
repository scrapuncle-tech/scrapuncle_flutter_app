import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scrapuncle/pages/login.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> SignOut() async {
    await auth.signOut();
  }

  Future<void> deleteUser() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.delete();
        print("User deleted successfully!");
      } else {
        print("No user currently signed in.");
      }
    } catch (e) {
      print("Error deleting user: $e");
    }
  }
}
