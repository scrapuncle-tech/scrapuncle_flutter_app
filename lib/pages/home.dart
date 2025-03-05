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

  @override
  void initState() {
    super.initState();
    loadUserData(); // Use a combined function to load user data
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

  @override
  Widget build(BuildContext context) {
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
            const Text(
              "Uploaded Items",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // Only proceed if userId is valid
            if (userId != null && userId!.isNotEmpty)
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .collection("phoneNumbers")
                    .snapshots(),
                builder: (context,
                    AsyncSnapshot<QuerySnapshot> phoneNumbersSnapshot) {
                  if (phoneNumbersSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (phoneNumbersSnapshot.hasError) {
                    return Text('Error: ${phoneNumbersSnapshot.error}');
                  }

                  if (!phoneNumbersSnapshot.hasData ||
                      phoneNumbersSnapshot.data!.docs.isEmpty) {
                    return const Text('No items added yet.');
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: phoneNumbersSnapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final phoneNumberDocument =
                          phoneNumbersSnapshot.data!.docs[index];
                      final itemData =
                          phoneNumberDocument.data() as Map<String, dynamic>;
                      // String phoneNumber = phoneNumbersSnapshot.data!.docs[index].id;
                      return ExpansionTile(
                        title: Text(
                            'Phone Number: ${itemData['PhoneNumber'] ?? 'N/A'}'),
                        children: [
                          ListTile(
                            title: Text(itemData['Name'] ?? 'N/A'),
                            subtitle: Text(
                                'Weight: ${itemData['WeightOrQuantity'] ?? 'N/A'}, Date: ${itemData['DateTime'] ?? 'N/A'}'),
                          ),
                        ],
                      );
                    },
                  );
                },
              )
            else
              const Text("User ID not found. Please log in again."),
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
