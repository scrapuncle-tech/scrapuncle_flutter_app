import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scrapuncle/pages/add_item.dart';
import 'package:scrapuncle/pages/pickup.dart';
import 'package:scrapuncle/pages/profile.dart';
import 'package:scrapuncle/service/database.dart';
import 'package:scrapuncle/service/shared_pref.dart';
import 'package:scrapuncle/pages/details.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userName;
  String? userId;

  Map<String, dynamic>? userPhoneNumbersAndItems;

  @override
  void initState() {
    super.initState();
    loadUserData(); // Use a combined function to load user data
    loadPhoneNumbersAndItems(); // Load phone numbers and items
  }

  Future<void> loadUserData() async {
    userId = await SharedPreferenceHelper().getUserId(); // get userId
    print("HomePage: UserId = $userId");

    if (userId != null && userId!.isNotEmpty) {
      try {
        userName = await SharedPreferenceHelper()
            .getUserName(); // Get userName from Shared Preferences
        print("HomePage: UserName from SharedPref = $userName");

        if (userName == null || userName!.isEmpty) {
          // If userName is not available in SharedPref Get User Info from Firestore
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

          if (userDoc.exists) {
            userName = userDoc['Name'] as String?;
            await SharedPreferenceHelper().saveUserName(
                userName ?? ''); // Save userName back to SharedPref

            print("HomePage: UserName from Firestore = $userName");
          } else {
            print("User document not found in Firestore");
            userName = 'Username Not Found';
          }
        }
      } catch (e) {
        print("Error getting user data: $e");
        userName = 'Error Loading User'; //handle to data
      }
    } else {
      userName = 'Please Login'; //If userid is not valid show error to the user
    }
    setState(() {});
  }

  Future<void> loadPhoneNumbersAndItems() async {
    userPhoneNumbersAndItems =
        await SharedPreferenceHelper().getUserPhoneNumbersAndItems();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Display the retrieved phone numbers and items

    return Scaffold(
      appBar: AppBar(
        title: const Text("SCRAPUNCLE"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Profile()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello $userName!",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            if (userPhoneNumbersAndItems != null) ...[
              for (var entry in userPhoneNumbersAndItems!.entries)
                ExpansionTile(
                  title: Text('Phone Number: ${entry.key}'),
                  children: [
                    for (var item in entry.value)
                      ListTile(
                        title: Text(item['Name'] ?? 'N/A'),
                        subtitle: Text(
                            'Weight: ${item['WeightOrQuantity'] ?? 'N/A'}, Date: ${item['DateTime'] ?? 'N/A'}'),
                      ),
                  ],
                ),
            ] else
              const Text('No items added yet.'),
            // Removed the StreamBuilder as we are now using data from shared preferences
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const PickupPage()));
        },
        backgroundColor: Colors.green,
        child: const Text("Pickup", style: TextStyle(color: Colors.black)),
      ),
    );
  }
}
//
