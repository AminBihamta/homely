import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceEditScreen extends StatefulWidget {
  final String serviceId;
  final String initialName;
  final String initialDescription;
  final double initialHourlyRate;
  final String initialCategory;

  const ServiceEditScreen({
    super.key,
    required this.serviceId,
    required this.initialName,
    required this.initialDescription,
    required this.initialHourlyRate,
    required this.initialCategory,
  });

  @override
  _ServiceEditScreenState createState() => _ServiceEditScreenState();
}

class _ServiceEditScreenState extends State<ServiceEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _description;
  late double _hourlyRate;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _name = widget.initialName;
    _description = widget.initialDescription;
    _hourlyRate = widget.initialHourlyRate;
    _selectedCategory = widget.initialCategory;
  }

  Future<List<String>> _fetchCategories() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('service_categories').get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      _formKey.currentState!.save();
      await FirebaseFirestore.instance
          .collection('services')
          .doc(widget.serviceId)
          .update({
            'name': _name,
            'description': _description,
            'hourly_rate': _hourlyRate,
            'category': _selectedCategory,
            'updated_at': FieldValue.serverTimestamp(),
          });
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Service')),
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
                    initialValue: _name,
                    decoration: const InputDecoration(
                      labelText: 'Service Name',
                    ),
                    onSaved: (value) => _name = value ?? '',
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Please enter a name' : null,
                  ),
                  TextFormField(
                    initialValue: _description,
                    decoration: const InputDecoration(labelText: 'Description'),
                    onSaved: (value) => _description = value ?? '',
                    validator:
                        (value) =>
                            value!.isEmpty
                                ? 'Please enter a description'
                                : null,
                  ),
                  TextFormField(
                    initialValue: _hourlyRate.toString(),
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
                    child: const Text('Save Changes'),
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
