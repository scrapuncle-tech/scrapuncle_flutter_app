import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';
import 'package:scrapuncle/pages/home.dart';
import 'package:scrapuncle/service/database.dart';

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

  Future getImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);
    selectedImage = File(image!.path);
    setState(() {});
  }

  uploadItem() async {
    if (selectedImage != null &&
        phoneController.text != "" &&
        nameController.text != "" &&
        weightController.text != "") {
      // Changed
      String addId = randomAlphaNumeric(10);

      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child("itemImages").child(addId);
      final UploadTask task = firebaseStorageRef.putFile(selectedImage!);

      final TaskSnapshot snapshot = await task.whenComplete(() {});

      var downloadUrl = await snapshot.ref.getDownloadURL();

      Map<String, dynamic> addItem = {
        "Image": downloadUrl,
        "PhoneNumber": phoneController.text,
        "Name": nameController.text,
        "WeightOrQuantity": weightController.text,
      };
      await DatabaseMethods().addItem(addItem).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "Item has been added Successfully",
              style: TextStyle(fontSize: 18.0, color: Colors.white),
            )));
      });
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomePage()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Please fill all the fields and select an image",
            style: TextStyle(fontSize: 18.0, color: Colors.white),
          )));
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
