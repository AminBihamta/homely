import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart'; 

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

///handles registration flow
///checks if emails exists already, if not then passes email and password to
///auth service. if registration succeeds then UI is popped back to login screen
  void register() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Check if email already exists
    final emailExists = users.any((user) => user.email == email);
    if (emailExists) {
      showDialog(
        context: context,
        builder:
            (_) => const AlertDialog(
              title: Text("Login Failed"),
              content: Text(
                "Email already exists. Please use a different email.",
              ),
            ),
      );
      return;
    }

    final success = AuthService.signUp( //pass password and email to auth service
      email,
      password,
    );
    if (success) {
      Navigator.pop(context); // Go back to login
    } else {
      showError("Registration failed.");
    }
  }

  void showError(String msg) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Error"),
            content: Text(msg),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Image.asset(
                'assets/homely_logo.png', 
                height: 100, 
              ),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: register, //goes to registration flow
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text("Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
