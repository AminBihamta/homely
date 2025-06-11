import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../serviceprovider/service_edit_screen.dart';
import '../serviceprovider/service_form.dart';
import '../screens/login_screen.dart';
import '../services/auth_service.dart';
import 'theme/colors.dart';
import 'widgets/homely_scaffold.dart';

class ServiceProviderDashboard extends StatefulWidget {
  const ServiceProviderDashboard({super.key});

  @override
  _ServiceProviderDashboardState createState() =>
      _ServiceProviderDashboardState();
}

class _ServiceProviderDashboardState extends State<ServiceProviderDashboard> {
  String? userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
  }

  Future<void> _addService() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ServiceFormScreen()),
    );
    if (result == true) {
      setState(() {}); // Refresh list
    }
  }

  Future<void> _editService(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => ServiceEditScreen(
              serviceId: doc.id,
              initialName: data['name'] ?? '',
              initialDescription: data['description'] ?? '',
              initialHourlyRate: (data['hourly_rate'] ?? 0).toDouble(),
              initialCategory: data['category'] ?? '',
            ),
      ),
    );
    if (result == true) {
      setState(() {});
    }
  }

  void _deleteService(String docId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Service'),
            content: const Text(
              'Are you sure you want to delete this service?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('services')
                      .doc(docId)
                      .delete();
                  Navigator.pop(context);
                  setState(() {});
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void logout(BuildContext context) {
    AuthService.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return HomelyScaffold(
        selectedIndex: 0,
        body: Center(
          child: Text(
            'User not logged in.',
            style: TextStyle(color: AppColors.text),
          ),
        ),
        showLogout: false,
      );
    }
    return HomelyScaffold(
      selectedIndex: 0, // Home/services tab for provider
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'My Services',
          style: TextStyle(color: AppColors.background),
        ),
        iconTheme: IconThemeData(color: AppColors.background),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.highlight),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('services')
                  .where('user_id', isEqualTo: userId)
                  .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  'No services available.',
                  style: TextStyle(color: AppColors.text),
                ),
              );
            }
            final docs = snapshot.data!.docs;
            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                final data = doc.data() as Map<String, dynamic>;
                return Card(
                  color: AppColors.background,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    title: Text(
                      data['name'] ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    subtitle: Text(
                      data['description'] ?? '',
                      style: TextStyle(color: AppColors.text),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'RM${(data['hourly_rate'] ?? 0).toString()}',
                          style: TextStyle(
                            color: AppColors.highlight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, color: AppColors.primary),
                          onPressed: () => _editService(doc),
                          tooltip: 'Edit',
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: AppColors.highlight),
                          onPressed: () => _deleteService(doc.id),
                          tooltip: 'Delete',
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _addService,
        tooltip: 'Add Service',
        child: Icon(Icons.add, color: AppColors.background),
      ),
    );
  }
}
