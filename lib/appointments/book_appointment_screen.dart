import 'package:flutter/material.dart';
import '../services/appointment_service.dart';
import '../theme/colors.dart'; // update this path based on your structure

class BookAppointmentPage extends StatefulWidget {
  final String serviceId;
  final String providerId;
  final String? serviceName;

  const BookAppointmentPage({
    super.key,
    required this.serviceId,
    required this.providerId,
    this.serviceName,
  });

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  final TextEditingController _notesController = TextEditingController();
  String? _selectedStartTime;
  String? _selectedEndTime;

  // Generate time slots from 5am to 10pm, only allowing future times for today
  List<String> _generateTimeSlots(DateTime date) {
    final now = DateTime.now();
    final slots = <String>[];
    for (int hour = 5; hour <= 22; hour++) {
      final slotTime = DateTime(date.year, date.month, date.day, hour);
      if (date.isAfter(DateTime(now.year, now.month, now.day)) ||
          (date.year == now.year && date.month == now.month && date.day == now.day && slotTime.isAfter(now))) {
        final formatted = TimeOfDay(hour: hour, minute: 0).format(context);
        slots.add(formatted);
      }
    }
    return slots;
  }

  List<String> get _timeSlots {
    if (_selectedDate == null) return [];
    return _generateTimeSlots(_selectedDate!);
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedStartTime = null;
        _selectedEndTime = null;
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      await AppointmentService.addAppointment({
        'serviceId': widget.serviceId,
        'providerId': widget.providerId,
        'serviceName': widget.serviceName,
        'date': _selectedDate, // Store as DateTime
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
              GestureDetector(
                onTap: () => _pickDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      labelStyle: TextStyle(color: AppColors.text),
                    ),
                    controller: TextEditingController(
                      text: _selectedDate == null
                          ? ''
                          : "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}",
                    ),
                    style: const TextStyle(color: AppColors.text),
                    validator: (_) =>
                        _selectedDate == null ? 'Select a date' : null,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
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
                      validator: (value) => value == null ? 'Select a start time' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
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
                  ),
                ],
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
