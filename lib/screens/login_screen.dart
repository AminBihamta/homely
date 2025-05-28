import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/colors.dart';

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Login", style: TextStyle(color: AppColors.background)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: AppColors.background),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
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
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
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
              obscureText: true,
              style: const TextStyle(color: AppColors.text),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: login,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
                minimumSize: const Size.fromHeight(50),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              child: const Text("Login"),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterScreen()),
              ),
              child: const Text("Register"),
              style: ElevatedButton.styleFrom(
                foregroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(50),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ForgotPasswordScreen(),
                ),
              ),
              child: const Text("Forgot Password?"),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
