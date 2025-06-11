import 'package:flutter/material.dart';
import '../services/appointment_service.dart';
import '../theme/colors.dart'; // update this path based on your structure

class BookAppointmentPage extends StatefulWidget {
  const BookAppointmentPage({super.key});

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String? _selectedStartTime;
  String? _selectedEndTime;

  final List<String> _timeSlots = [
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '1:00 PM',
    '2:00 PM',
    '3:00 PM'
  ];

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      await AppointmentService.addAppointment({
        'date': _dateController.text,
        'startTime': _selectedStartTime,
        'endTime': _selectedEndTime,
        'notes': _notesController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment booked')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Book Appointment'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  labelStyle: TextStyle(color: AppColors.text),
                ),
                style: const TextStyle(color: AppColors.text),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter a date' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedStartTime,
                decoration: const InputDecoration(
                  labelText: 'Start Time',
                  labelStyle: TextStyle(color: AppColors.text),
                ),
                items: _timeSlots
                    .map((time) => DropdownMenuItem(
                          value: time,
                          child: Text(time, style: const TextStyle(color: AppColors.text)),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedStartTime = value),
                validator: (value) =>
                    value == null ? 'Select a start time' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedEndTime,
                decoration: const InputDecoration(
                  labelText: 'End Time',
                  labelStyle: TextStyle(color: AppColors.text),
                ),
                items: _timeSlots
                    .map((time) => DropdownMenuItem(
                          value: time,
                          child: Text(time, style: const TextStyle(color: AppColors.text)),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedEndTime = value),
                validator: (value) => value == null ? 'Select end time' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  labelStyle: TextStyle(color: AppColors.text),
                ),
                maxLines: 3,
                style: const TextStyle(color: AppColors.text),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.highlight,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
