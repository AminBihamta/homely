import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      appBar: AppBar(title: const Text('Add Service')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<String>>(
          future: _fetchCategories(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final categories = snapshot.data!;
            return Form(
              key: _formKey,
              child: ListView(
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Category'),
                    value: _selectedCategory,
                    items:
                        categories
                            .map(
                              (cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              ),
                            )
                            .toList(),
                    onChanged: (val) => setState(() => _selectedCategory = val),
                    validator:
                        (val) =>
                            val == null ? 'Please select a category' : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Service Name',
                    ),
                    onSaved: (value) => _name = value ?? '',
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Please enter a name' : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Description'),
                    onSaved: (value) => _description = value ?? '',
                    validator:
                        (value) =>
                            value!.isEmpty
                                ? 'Please enter a description'
                                : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Hourly Rate'),
                    keyboardType: TextInputType.number,
                    onSaved:
                        (value) =>
                            _hourlyRate = double.tryParse(value ?? '0') ?? 0.0,
                    validator:
                        (value) =>
                            value!.isEmpty
                                ? 'Please enter an hourly rate'
                                : null,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Add Service'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
