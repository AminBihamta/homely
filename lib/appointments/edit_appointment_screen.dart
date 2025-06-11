import 'package:flutter/material.dart';
import '../services/appointment_service.dart';
import '../theme/colors.dart';

class EditAppointmentPage extends StatefulWidget {
  final Map<String, dynamic> appointment;

  const EditAppointmentPage({super.key, required this.appointment});

  @override
  State<EditAppointmentPage> createState() => _EditAppointmentPageState();
}

class _EditAppointmentPageState extends State<EditAppointmentPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _dateController;
  late TextEditingController _notesController;
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

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(text: widget.appointment['date'] ?? '');
    _notesController = TextEditingController(text: widget.appointment['notes'] ?? '');
    _selectedStartTime = widget.appointment['startTime'];
    _selectedEndTime = widget.appointment['endTime'];
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      await AppointmentService.updateAppointment(widget.appointment['id'], {
        'date': _dateController.text,
        'startTime': _selectedStartTime,
        'endTime': _selectedEndTime,
        'notes': _notesController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment updated')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _delete() async {
    await AppointmentService.deleteAppointment(widget.appointment['id']);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Appointment deleted')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Appointment'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _delete,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(children: [
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
              ),
              child: const Text('Save Changes'),
            )
          ]),
        ),
      ),
    );
  }
}
