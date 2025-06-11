import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; //login screen
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'service_provider_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Homely',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/serviceProviderDashboard':
            (context) => const ServiceProviderDashboard(),
      },
    );
  }
}
