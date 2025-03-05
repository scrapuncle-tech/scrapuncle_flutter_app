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
    getUserName();
  }

  getUserName() async {
    userName = await SharedPreferenceHelper().getUserName();
    userId = await SharedPreferenceHelper().getUserId();
    print("HomePage: UserName = $userName, UserId = $userId");
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
                      String phoneNumber =
                          phoneNumbersSnapshot.data!.docs[index].id;
                      return ExpansionTile(
                        title: Text('Phone Number: $phoneNumber'),
                        children: [
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(userId)
                                .collection('phoneNumbers')
                                .doc(phoneNumber)
                                .collection('items')
                                .snapshots(),
                            builder: (context,
                                AsyncSnapshot<QuerySnapshot> itemsSnapshot) {
                              if (itemsSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }

                              if (itemsSnapshot.hasError) {
                                return Text('Error: ${itemsSnapshot.error}');
                              }

                              if (!itemsSnapshot.hasData ||
                                  itemsSnapshot.data!.docs.isEmpty) {
                                return const Text(
                                    'No items added for this phone number yet.');
                              }

                              return Column(
                                children: itemsSnapshot.data!.docs
                                    .map((DocumentSnapshot itemDoc) {
                                  Map<String, dynamic> itemData =
                                      itemDoc.data() as Map<String, dynamic>;

                                  // Extract item details and pass to Details page
                                  Item item = Item(
                                    name: itemData['Name'] ?? 'N/A',
                                    image: itemData['Image'] ?? '',
                                    phoneNumber:
                                        itemData['PhoneNumber'] ?? 'N/A',
                                    weightOrQuantity:
                                        itemData['WeightOrQuantity'] ?? 'N/A',
                                  );
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              Details(item: item),
                                        ),
                                      );
                                    },
                                    child: ListTile(
                                      title:
                                          Text(itemData['Name'] ?? 'Item Name'),
                                      subtitle: Text(
                                          'Weight: ${itemData['WeightOrQuantity'] ?? 'N/A'}, Date: ${itemData['DateTime'] ?? 'N/A'}'),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
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
