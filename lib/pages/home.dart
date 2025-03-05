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
              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('items')
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Text('No items added yet.');
                    }

                    //phoneStreams.clear();

                    // Create a map to group items by phone number
                    Map<String, List<DocumentSnapshot>> groupedItems = {};
                    for (var doc in snapshot.data!.docs) {
                      String phoneNumber = doc.id;
                      if (!groupedItems.containsKey(phoneNumber)) {
                        groupedItems[phoneNumber] = [];
                      }
                      groupedItems[phoneNumber]!.add(doc);
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: groupedItems.length,
                      itemBuilder: (context, index) {
                        String phoneNumber = groupedItems.keys.elementAt(index);
                        List<DocumentSnapshot> itemsForNumber =
                            groupedItems[phoneNumber]!;
                        return ExpansionTile(
                          title: Text('Phone Number: $phoneNumber'),
                          children: itemsForNumber.map((doc) {
                            return FutureBuilder<QuerySnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection('items')
                                    .doc(phoneNumber)
                                    .collection('userItems')
                                    .get(),
                                builder: (context,
                                    AsyncSnapshot<QuerySnapshot> userItems) {
                                  if (userItems.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  }

                                  if (userItems.hasError) {
                                    return Text('Error: ${userItems.error}');
                                  }

                                  if (!userItems.hasData ||
                                      userItems.data!.docs.isEmpty) {
                                    return const Text('No items added yet.');
                                  }

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: userItems.data!.docs.map((doc) {
                                      DocumentSnapshot ds = doc;
                                      Item item = Item.fromDocumentSnapshot(
                                          ds); // Create Item object
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Details(
                                                  item:
                                                      item), // Fixed: Pass 'item'
                                            ),
                                          );
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                              bottom: 10.0),
                                          decoration: BoxDecoration(
                                            color: Colors.green[100],
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          padding: const EdgeInsets.all(10.0),
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
                                });
                          }).toList(),
                        );
                      },
                    );
                  }),
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
