import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../theme/colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final addressController = TextEditingController(); // Add address controller
  bool isProvider = false; // Add this to track the switch

  ///main registration flow
  void register() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final name = nameController.text.trim();
    final address = addressController.text.trim();

    if (name.isEmpty) {
      showError("Please enter your name.");
      return;
    }
    if (address.isEmpty) {
      showError("Please enter your address.");
      return;
    }

    final success = await AuthService.signUp(email, password);
    if (!mounted) return;

    if (success) {
      final user = AuthService.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('user_data').doc(user.uid).set({
          'email': user.email,
          'name': name,
          'address': address,
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Register", style: TextStyle(color: AppColors.background)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: AppColors.background),
      ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('Homeowner'),
                  selected: !isProvider,
                  onSelected: (selected) {
                    setState(() {
                      isProvider = false;
                    });
                  },
                  selectedColor: AppColors.highlight,
                  backgroundColor: AppColors.background,
                  labelStyle: TextStyle(
                    color: !isProvider ? AppColors.background : AppColors.primary,
                  ),
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
                  selectedColor: AppColors.highlight,
                  backgroundColor: AppColors.background,
                  labelStyle: TextStyle(
                    color: isProvider ? AppColors.background : AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: AppColors.text),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.highlight, width: 2),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                filled: true,
                fillColor: AppColors.background,
              ),
              style: const TextStyle(color: AppColors.text),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: AppColors.text),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.highlight, width: 2),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                filled: true,
                fillColor: AppColors.background,
              ),
              style: const TextStyle(color: AppColors.text),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: AppColors.text),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.highlight, width: 2),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                filled: true,
                fillColor: AppColors.background,
              ),
              style: const TextStyle(color: AppColors.text),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: "Address",
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: AppColors.text),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.highlight, width: 2),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                filled: true,
                fillColor: AppColors.background,
              ),
              style: const TextStyle(color: AppColors.text),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: register,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
                minimumSize: const Size.fromHeight(50),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              child: const Text("Register"),
            ),
          ],
        ),
      ),
    );
  }
}
