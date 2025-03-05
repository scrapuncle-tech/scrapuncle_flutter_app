import 'package:flutter/material.dart';
import 'package:scrapuncle/pages/add_item.dart';
import 'package:scrapuncle/service/database.dart'; // Import DatabaseMethods

class PickupPage extends StatefulWidget {
  const PickupPage({Key? key}) : super(key: key);

  @override
  State<PickupPage> createState() => _PickupPageState();
}

class _PickupPageState extends State<PickupPage> {
  TextEditingController phoneController = TextEditingController();
  List<Map<String, dynamic>> items = []; // List to store added items

  Future<void> uploadItems() async {
    String phoneNumber = phoneController.text;

    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a phone number.")),
      );
      return;
    }

    // Upload all items to Firestore with the phone number
    for (var item in items) {
      try {
        await DatabaseMethods().addItem(item, phoneNumber, item['userId']);
        print(
            "Uploaded item ${item['Name']} for phone number $phoneNumber"); // Log success
      } catch (e) {
        print(
            "Error uploading item ${item['Name']} for phone number $phoneNumber: $e"); // Log failure
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error uploading item: $e")),
        );
        return; // Stop if any upload fails
      }
    }

    // After a successful upload, reset the items list
    setState(() {
      items.clear();
    });
    Navigator.pop(context); // Return to HomePage
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Items uploaded successfully!")),
    );
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
                // Navigate to AddItem page and wait for the result
                final newItem = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddItem(
                      phoneNumber:
                          phoneController.text, // Pass the phone number
                    ),
                  ),
                );

                // If an item was added, update the items list
                if (newItem != null) {
                  setState(() {
                    items.add(newItem);
                  });
                }
              },
              child:
                  const Text('Add Item', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20.0),
            const Text(
              "Added Items",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10.0),
            if (items.isEmpty)
              const Text("No items added yet.")
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10.0),
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Name: ${item['Name']}"),
                        Text("Weight: ${item['WeightOrQuantity']}"),
                        Text("Date/Time: ${item['DateTime']}"),
                        // Display other item details as needed
                      ],
                    ),
                  );
                },
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
                  uploadItems();
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
