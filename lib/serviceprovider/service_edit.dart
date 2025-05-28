import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/colors.dart';

class ServiceFormScreen extends StatefulWidget {
  const ServiceFormScreen({super.key});

  @override
  _ServiceFormScreenState createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _description = '';
  double _hourlyRate = 0.0;
  String? _selectedCategory;

  Future<List<String>> _fetchCategories() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('service_categories').get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      _formKey.currentState!.save();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not logged in.')));
        return;
      }

      await FirebaseFirestore.instance.collection('services').add({
        'name': _name,
        'description': _description,
        'category': _selectedCategory,
        'hourly_rate': _hourlyRate,
        'user_id': user.uid,
        'created_at': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Add Service',
          style: TextStyle(color: AppColors.background),
        ),
        iconTheme: const IconThemeData(color: AppColors.background),
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: FutureBuilder<List<String>>(
            future: _fetchCategories(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              final categories = snapshot.data!;
              return Form(
                key: _formKey,
                child: ListView(
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        labelStyle: TextStyle(color: AppColors.text),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.highlight,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                      ),
                      value: _selectedCategory,
                      items:
                          categories
                              .map(
                                (cat) => DropdownMenuItem(
                                  value: cat,
                                  child: Text(
                                    cat,
                                    style: const TextStyle(
                                      color: AppColors.text,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged:
                          (val) => setState(() => _selectedCategory = val),
                      validator:
                          (val) =>
                              val == null ? 'Please select a category' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Service Name',
                        labelStyle: TextStyle(color: AppColors.text),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.highlight,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                      ),
                      style: const TextStyle(color: AppColors.text),
                      onSaved: (value) => _name = value ?? '',
                      validator:
                          (value) =>
                              value!.isEmpty ? 'Please enter a name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        labelStyle: TextStyle(color: AppColors.text),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.highlight,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                      ),
                      style: const TextStyle(color: AppColors.text),
                      onSaved: (value) => _description = value ?? '',
                      validator:
                          (value) =>
                              value!.isEmpty
                                  ? 'Please enter a description'
                                  : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Hourly Rate',
                        labelStyle: TextStyle(color: AppColors.text),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.highlight,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                      ),
                      style: const TextStyle(color: AppColors.text),
                      keyboardType: TextInputType.number,
                      onSaved:
                          (value) =>
                              _hourlyRate =
                                  double.tryParse(value ?? '0') ?? 0.0,
                      validator:
                          (value) =>
                              value!.isEmpty
                                  ? 'Please enter an hourly rate'
                                  : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.background,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _submitForm,
                        child: const Text(
                          'Add Service',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
