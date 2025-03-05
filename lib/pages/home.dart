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
  String? userId; // Add user ID
  //Stream<QuerySnapshot>? itemsStream;
  Map<String, Stream<QuerySnapshot>> phoneStreams = {};

  getUserName() async {
    userName = await SharedPreferenceHelper().getUserName();
    userId = await SharedPreferenceHelper().getUserId(); // Get user ID
    print("HomePage: UserName = $userName, UserId = $userId"); // Add this line

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getUserName();
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
        child: Container(
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
              // Only proceed if userId is not null or empty
              if (userId != null && userId!.isNotEmpty)
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .get(),
                  builder:
                      (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    if (userSnapshot.hasError) {
                      return Text('Error: ${userSnapshot.error}');
                    }

                    if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                      return const Text('No data found for this user.');
                    }

                    // Build the UI to display the items
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(userId)
                              .collection("phoneNumbers")
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return Text(
                                  'Something went wrong: ${snapshot.error}');
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Text("Loading");
                            }

                            if (snapshot.data!.docs.isEmpty) {
                              return const Text("No Items in here yet");
                            }

                            return ListView(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              children: snapshot.data!.docs
                                  .map((DocumentSnapshot phoneNumberDocument) {
                                //Map<String, dynamic> data =
                                //  document.data()! as Map<String, dynamic>;
                                String phoneNumber = phoneNumberDocument.id;
                                return ExpansionTile(
                                  title: Text('Phone Number: $phoneNumber'),
                                  children: [
                                    StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(userId)
                                          .collection("phoneNumbers")
                                          .doc(phoneNumber)
                                          .collection("items")
                                          .snapshots(),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<QuerySnapshot> items) {
                                        if (items.hasError) {
                                          return Text(
                                              'Something went wrong: ${items.error}');
                                        }

                                        if (items.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Text("Loading");
                                        }

                                        if (items.data!.docs.isEmpty) {
                                          return const Text(
                                              "No items added for this Phone Number yet");
                                        }

                                        return Column(
                                          children: items.data!.docs.map(
                                              (DocumentSnapshot itemDocument) {
                                            Map<String, dynamic> itemData =
                                                itemDocument.data()!
                                                    as Map<String, dynamic>;
                                            Item item = Item.fromDocumentSnapshot(
                                                itemDocument); // Create Item object
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
                                              child: Container(
                                                margin: const EdgeInsets.only(
                                                    bottom: 10.0),
                                                decoration: BoxDecoration(
                                                  color: Colors.green[100],
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Name: ${item.name}",
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(
                                                        "Phone Number: ${item.phoneNumber}"),
                                                    Text(
                                                        "Weight: ${item.weightOrQuantity}"),
                                                    if (item.image != null)
                                                      Image.network(
                                                        item.image,
                                                        height: 100,
                                                        width: double.infinity,
                                                        fit: BoxFit.cover,
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        );
                                      },
                                    ),
                                  ],
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    );
                  },
                )
              else
                const Text(
                    "User ID not found. Please log in again."), // Fallback message
            ],
          ),
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
