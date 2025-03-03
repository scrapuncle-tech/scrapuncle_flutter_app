import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:scrapuncle/pages/login.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SCRAPUNCLE',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white, // Set white background
        primaryColor: Colors.green, // Primary green color
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.green),
      ),
      home: const Login(), // Start with the Login page
    );
  }
}
