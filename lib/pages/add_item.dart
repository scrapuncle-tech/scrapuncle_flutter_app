import 'dart:io';
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';
import 'package:scrapuncle/pages/home.dart';
import 'package:scrapuncle/service/database.dart';
import 'package:scrapuncle/service/shared_pref.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:path_provider/path_provider.dart'; // Import for local storage

class AddItem extends StatefulWidget {
  const AddItem({Key? key}) : super(key: key);

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  TextEditingController phoneController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
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

  Future<void> getImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage = File(image.path);
      setState(() {});
    }
  }

  Future<void> uploadItem() async {
    if (selectedImage != null &&
        phoneController.text.isNotEmpty &&
        nameController.text.isNotEmpty &&
        weightController.text.isNotEmpty &&
        userId != null) {
      String addId = randomAlphaNumeric(10);
      String fileName = '$userId/$addId';

      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child("itemImages").child(fileName);

      try {
        await firebaseStorageRef.putFile(selectedImage!);
        final String downloadUrl = await firebaseStorageRef.getDownloadURL();

        Map<String, dynamic> addItem = {
          "Image": downloadUrl,
          "PhoneNumber": phoneController.text,
          "Name": nameController.text,
          "WeightOrQuantity": weightController.text,
          "userId": userId,
          "itemId": addId,
        };

        // Try to add item to Firebase
        try {
          // Add item data to Firestore
          await DatabaseMethods().addItem(addItem, userId!);

          // Add item data to Realtime Database
          await addDataToRealtimeDatabase(addItem);

          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.green,
              content: Text(
                "Item has been added Successfully",
                style: TextStyle(fontSize: 18.0, color: Colors.white),
              )));

          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const HomePage()));
        } catch (firestoreError) {
          // If adding to Firebase fails, store locally
          print(
              "Failed to upload to Firestore/Realtime DB: $firestoreError. Storing locally.");
          await storeItemLocally(addItem);
        }
      } catch (e) {
        print("Error uploading item: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "Failed to upload item: $e",
              style: const TextStyle(fontSize: 18.0, color: Colors.white),
            ),
          ),
        );
      }
    } else {
      String message = "Please fill all the fields and select an image";
      if (userId == null) {
        message = "User ID not found. Please login again.";
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          message,
          style: const TextStyle(fontSize: 18.0, color: Colors.white),
        ),
      ));
    }
  }

  // Function to add data to Firebase Realtime Database
  Future<void> addDataToRealtimeDatabase(Map<String, dynamic> itemData) async {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref(); // Get reference to the root
    try {
      await ref
          .child('items')
          .child(userId!)
          .child(itemData['itemId'])
          .set(itemData);
      print("Data added to Realtime Database successfully!");
    } catch (e) {
      print("Error adding data to Realtime Database: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Failed to upload item to Realtime Database: $e",
            style: const TextStyle(fontSize: 18.0, color: Colors.white),
          ),
        ),
      );
    }
  }

  // Function to store item data locally as JSON
  Future<void> storeItemLocally(Map<String, dynamic> itemData) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/pending_items.json');

      // Read existing data, if any
      List<dynamic> existingItems = [];
      if (await file.exists()) {
        String contents = await file.readAsString();
        if (contents.isNotEmpty) {
          existingItems = jsonDecode(contents);
        }
      }

      // Add the new item to the list
      existingItems.add(itemData);

      // Write the updated list back to the file
      await file.writeAsString(jsonEncode(existingItems));

      print('Item stored locally for later upload.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.yellow,
          content: Text(
            "Item stored locally. Will be uploaded when online.",
            style: TextStyle(fontSize: 18.0, color: Colors.black),
          ),
        ),
      );
    } catch (e) {
      print("Error storing item locally: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Failed to store item locally: $e",
            style: const TextStyle(fontSize: 18.0, color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Item"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Upload the Item Picture",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20.0),
            GestureDetector(
              onTap: () {
                getImage();
              },
              child: Center(
                child: Material(
                  elevation: 4.0,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green, width: 1.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: selectedImage == null
                        ? const Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.green,
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.file(
                              selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30.0),
            const Text(
              "Customer Phone Number",
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
            const SizedBox(height: 30.0),
            const Text(
              "Item Name",
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
                controller: nameController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Enter Item Name",
                ),
              ),
            ),
            const SizedBox(height: 30.0),
            const Text(
              "Item Weight or Quantity",
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
                controller: weightController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Enter Item Weight or Quantity",
                ),
              ),
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
                  uploadItem();
                },
                child: const Text('Add Item',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
