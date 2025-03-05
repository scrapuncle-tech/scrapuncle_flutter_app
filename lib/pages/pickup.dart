import 'package:flutter/material.dart';
import 'package:scrapuncle/pages/add_item.dart';
import 'package:scrapuncle/service/database.dart'; // Import DatabaseMethods
import 'package:scrapuncle/service/shared_pref.dart';

class PickupPage extends StatefulWidget {
  const PickupPage({Key? key}) : super(key: key);

  @override
  State<PickupPage> createState() => _PickupPageState();
}

class _PickupPageState extends State<PickupPage> {
  TextEditingController phoneController = TextEditingController();
  List<Map<String, dynamic>> items = []; // List to store added items
  String? userId;

  @override
  void initState() {
    super.initState();
    getUserId();
  }

  Future<void> getUserId() async {
    userId = await SharedPreferenceHelper().getUserId();
    setState(() {});
  }

  Future<void> uploadItem(Map<String, dynamic> item) async {
    String phoneNumber = phoneController.text.trim(); // Trim whitespace

    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a phone number.")),
      );
      return;
    }

    if (userId == null || userId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User ID not found. Please login again.")),
      );
      return;
    }

    // Upload the item to Firestore with the phone number
    try {
      await DatabaseMethods().addItem(item, phoneNumber, userId!);
      print(
          "Uploaded item ${item['Name']} for phone number $phoneNumber"); // Log success
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Added Successfully")));
    } catch (e) {
      print(
          "Error uploading item ${item['Name']} for phone number $phoneNumber: $e"); // Log failure
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading item: $e")),
      );
      return; // Stop if any upload fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pickup"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter Customer Phone Number",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10.0),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Enter Customer Phone Number",
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                textStyle: const TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onPressed: () async {
                String phoneNumber = phoneController.text.trim();
                if (phoneNumber.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Please enter a phone number.")),
                  );
                  return;
                }
                // Navigate to AddItem page and wait for the result
                final newItem = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddItem(
                      phoneNumber: phoneNumber, // Pass the phone number
                    ),
                  ),
                );

                // If an item was added, update the items list
                if (newItem != null) {
                  uploadItem(newItem);
                }
              },
              child:
                  const Text('Add Item', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 30.0),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: () {
                  // Call the uploadItems method here
                  //uploadItems();
                  Navigator.pop(context);
                },
                child: const Text('Complete Pickup',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
