import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Details extends StatelessWidget {
  final Item item;

  const Details({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Item Details"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.network(
                item.image,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              item.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Phone Number: ${item.phoneNumber}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Weight or Quantity: ${item.weightOrQuantity}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 30),
            // Center(
            //   child: ElevatedButton(
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: Colors.green,
            //       padding:
            //           const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            //       textStyle: const TextStyle(fontSize: 18),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(10.0),
            //       ),
            //     ),
            //     onPressed: () {
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         const SnackBar(
            //           content: Text("Action button pressed!"),
            //         ),
            //       );
            //     },
            //     child: const Text("Express Interest",
            //         style: TextStyle(color: Colors.white)),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class Item {
  final String name;
  final String image;
  final String phoneNumber;
  final String weightOrQuantity;

  Item({
    required this.name,
    required this.image,
    required this.phoneNumber,
    required this.weightOrQuantity,
  });

  factory Item.fromDocumentSnapshot(DocumentSnapshot ds) {
    return Item(
      name: ds["Name"] ?? "",
      image: ds["Image"] ?? "",
      phoneNumber: ds["PhoneNumber"] ?? "",
      weightOrQuantity: ds["WeightOrQuantity"] ?? "",
    );
  }
}
