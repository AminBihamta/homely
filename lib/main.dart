import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; //login screen
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());

//   try {
//     // Ensure Flutter is initialized before Firebase
//     WidgetsFlutterBinding.ensureInitialized();

//     // Initialize Firebase with platform-specific options
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );

//     // Test Firestore connection (optional)
//     // await testFirestoreConnection();

//     // Run the app
//     runApp(const MyApp());
//   } catch (e) {
//     print('Error during initialization: $e');
//     // Still run the app even if there are Firebase errors
//     runApp(const MyApp());
//   }
// >>>>>>> main
}

/// Tests the connection to Firestore by making a simple query
/// This is just a diagnostic function and doesn't modify any data
// Future<void> testFirestoreConnection() async {
//   try {
//     // Get a reference to the Firestore instance
//     final firestore = FirebaseFirestore.instance;

//     // Try to get a collection as a simple connection test
//     // Using limit(1) to minimize data transfer
//     final querySnapshot = await firestore.collection('test').limit(1).get();

//     print('Firestore connection successful! Found ${querySnapshot.docs.length} documents in test collection.');
//   } catch (e) {
//     // Just log the error but don't crash the app
//     print('Error connecting to Firestore: $e');
//     // You might want to log this to a monitoring service in a real app
//   }
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Homely',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
