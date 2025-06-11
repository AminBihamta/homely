import 'package:flutter/material.dart';
import '../services/appointment_service.dart';
import '../theme/colors.dart';

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

  List<String> _generateTimeSlots(DateTime date) {
    final now = DateTime.now();
    final slots = <String>[];
    for (int hour = 5; hour <= 22; hour++) {
      final slotTime = DateTime(date.year, date.month, date.day, hour);
      if (date.isAfter(DateTime(now.year, now.month, now.day)) ||
          (date.year == now.year &&
              date.month == now.month &&
              date.day == now.day &&
              slotTime.isAfter(now))) {
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
        'date': _selectedDate,
        'startTime': _selectedStartTime,
        'endTime': _selectedEndTime,
        'notes': _notesController.text,
      });

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, size: 60, color: Colors.green),
                  const SizedBox(height: 16),
                  const Text(
                    'Booking Successful!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // close dialog
                            Navigator.pop(context); // go back to previous screen
                            // Navigate to active bookings if needed
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('View Active Bookings', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context); // close dialog
                            Navigator.pop(context); // go back
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: Colors.black),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Go Back Home', style: TextStyle(color: Colors.black)),
                        ),
                      ),
                    ],
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Center(
                  child: Column(
                    children: [
                      Text(
                        "Book An Appointment",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Please fill up the form to confirm your booking with us",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: () => _pickDate(context),
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: TextEditingController(
                        text: _selectedDate == null
                            ? ''
                            : "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}",
                      ),
                      decoration: InputDecoration(
                        hintText: 'Date',
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (_) => _selectedDate == null ? 'Select a date' : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStartTime,
                        decoration: InputDecoration(
                          hintText: 'Start Time',
                          prefixIcon: const Icon(Icons.access_time),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: _timeSlots
                            .map((time) => DropdownMenuItem(value: time, child: Text(time)))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStartTime = value;
                            // Reset end time if it's before the new start time
                            if (_selectedEndTime != null &&
                                _timeSlots.indexOf(_selectedEndTime!) <= _timeSlots.indexOf(value!)) {
                              _selectedEndTime = null;
                            }
                          });
                        },
                        validator: (value) => value == null ? 'Select a start time' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedEndTime,
                        decoration: InputDecoration(
                          hintText: 'End Time',
                          prefixIcon: const Icon(Icons.access_time),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: _selectedStartTime == null
                            ? []
                            : _timeSlots
                                .where((time) =>
                                    _timeSlots.indexOf(time) > _timeSlots.indexOf(_selectedStartTime!))
                                .map((time) => DropdownMenuItem(value: time, child: Text(time)))
                                .toList(),
                        onChanged: (value) => setState(() => _selectedEndTime = value),
                        validator: (value) => value == null ? 'Select end time' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Additional Notes',
                    prefixIcon: const Icon(Icons.note_alt_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Submit', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
