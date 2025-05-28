import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  ///handles the login flow
  ///if succeeds pushes into homescreen, failure shows a popup
  void login() async {
    // pass email and password into auth service that are recieved from ui textfield
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    final success = await AuthService.signIn(email, password);
    if (!mounted) return;
    
    if (success) {
      // After login, check isProvider from Firestore
      final user = AuthService.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('user_data').doc(user.uid).get();
        final data = doc.data() ?? {};
        final isProvider = data['isProvider'] == true;
        if (isProvider) {
          Navigator.pushReplacementNamed(context, '/serviceProviderDashboard');
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } else {
        // fallback: go to home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else {
      showDialog(
        context: context,
        builder:
            (_) => const AlertDialog(
              title: Text("Login Failed"),
              content: Text("Invalid email or password."),
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Image.asset(
              'assets/homely_logo.png', // or .webp, .jpg, etc.
              height: 100, // Adjust as needed
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: login, child: const Text("Login")),
            TextButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  ),
              child: const Text("Register"),
            ),
            TextButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ForgotPasswordScreen(),
                    ),
                  ),
              child: const Text("Forgot Password?"),
            ),
          ],
        ),
      ),
    );
  }
}
