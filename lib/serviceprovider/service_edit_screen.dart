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
    final snapshot = await FirebaseFirestore.instance.collection('service_categories').get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      _formKey.currentState!.save();
      await FirebaseFirestore.instance.collection('services').doc(widget.serviceId).update({
        'name': _name,
        'description': _description,
        'hourly_rate': _hourlyRate,
        'category': _selectedCategory,
        'updated_at': FieldValue.serverTimestamp(),
      });

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_outline, size: 60, color: Colors.black87),
                  const SizedBox(height: 20),
                  const Text(
                    'Changes Saved!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context, true); // Return to previous screen
                    },
                    child: const Text('View My Services'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: FutureBuilder<List<String>>(
            future: _fetchCategories(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final categories = snapshot.data!;

              return SingleChildScrollView(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(height: 8),
                          const Center(
                            child: Text(
                              'Edit Service',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 20),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFF7F7F7),
                              labelText: 'Category',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            value: _selectedCategory,
                            items: categories.map((cat) {
                              return DropdownMenuItem(value: cat, child: Text(cat));
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedCategory = val),
                            validator: (val) => val == null ? 'Please select a category' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            initialValue: _name,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFF7F7F7),
                              prefixIcon: const Icon(Icons.edit),
                              labelText: 'Service Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onSaved: (val) => _name = val ?? '',
                            validator: (val) => val!.isEmpty ? 'Please enter a service name' : null,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  initialValue: _hourlyRate.toString(),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: const Color(0xFFF7F7F7),
                                    labelText: 'Hourly Rate',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onSaved: (val) => _hourlyRate = double.tryParse(val ?? '0') ?? 0.0,
                                  validator: (val) => val!.isEmpty ? 'Enter hourly rate' : null,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF7F7F7),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(child: Text('/hr')),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            initialValue: _description,
                            maxLines: 3,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFF7F7F7),
                              prefixIcon: const Icon(Icons.lock_outline),
                              labelText: 'Service Details',
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onSaved: (val) => _description = val ?? '',
                            validator: (val) => val!.isEmpty ? 'Please enter service details' : null,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _submitForm,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Save Changes'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    side: const BorderSide(color: Colors.black),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Cancel'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
