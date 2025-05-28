import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isProvider = false; // Add this to track the switch

  ///main registration flow
  void register() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    final success = await AuthService.signUp(email, password);
    if (!mounted) return;
    
    if (success) {
      // Set isProvider in Firestore after successful signup
      final user = AuthService.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('user_data').doc(user.uid).set({
          'email': user.email,
          'isProvider': isProvider,
        });
      }
      Navigator.pop(context); // Go back to login
    } else {
      showError("Registration failed. Email may already be in use or password is too weak.");
    }
  }

  void showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
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
            // Add the switch UI here
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('Service Receiver'),
                  selected: !isProvider,
                  onSelected: (selected) {
                    setState(() {
                      isProvider = false;
                    });
                  },
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('Service Provider'),
                  selected: isProvider,
                  onSelected: (selected) {
                    setState(() {
                      isProvider = true;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: register,
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
