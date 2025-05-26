import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();

  //incase user clicked on reset password button without putting in the email 
  void resetPassword() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      showError("Please enter your email.");
      return;
    }

    // Prompt for new password
    final newPassword = await showDialog<String>(
      context: context,
      builder: (context) {
        final newPasswordController = TextEditingController();
        return AlertDialog(
          title: const Text("Enter New Password"),
          content: TextField(
            controller: newPasswordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: "New Password"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancel
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed:
                  () => Navigator.pop(context, newPasswordController.text),
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );

    if (newPassword == null || newPassword.isEmpty) {
      showError("Password reset cancelled or empty password.");
      return;
    }

    ///responsibel for updating the old password with new
    ///gets the new password from Ui textfield and sends it to auth service
    ///if successful goes back to login screen, else displays error msg
    final success = AuthService.overwritePassword(email, newPassword);
    if (success) {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Success"),
              content: const Text("Password has been reset."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context), //back to login
                  child: const Text("OK"),
                ),
              ],
            ),
      );
    } else {
      showError("Email not found.");
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
      appBar: AppBar(title: const Text("Forgot Password")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: resetPassword,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text("Reset Password"),
            ),
          ],
        ),
      ),
    );
  }
}
