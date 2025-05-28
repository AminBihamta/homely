import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/colors.dart';

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Edit Service',
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
                      initialValue: _name,
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
                      initialValue: _description,
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
                      initialValue: _hourlyRate.toString(),
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
                          'Save Changes',
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
