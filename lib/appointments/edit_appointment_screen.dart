import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/appointment_service.dart';
//import '../theme/colors.dart';

class EditAppointmentPage extends StatefulWidget {
  final Map<String, dynamic> appointment;

  const EditAppointmentPage({super.key, required this.appointment});

  @override
  State<EditAppointmentPage> createState() => _EditAppointmentPageState();
}

class _EditAppointmentPageState extends State<EditAppointmentPage> {
  final _formKey = GlobalKey<FormState>();
  late DateTime? _selectedDate;
  late TextEditingController _notesController;
  String? _selectedStartTime;
  String? _selectedEndTime;

  @override
  void initState() {
    super.initState();
    final dateField = widget.appointment['date'];
    if (dateField is Timestamp) {
      _selectedDate = dateField.toDate();
    } else if (dateField is DateTime) {
      _selectedDate = dateField;
    } else if (dateField is String) {
      _selectedDate = DateTime.tryParse(dateField);
    } else {
      _selectedDate = null;
    }
    _notesController = TextEditingController(
      text: widget.appointment['notes'] ?? '',
    );
    _selectedStartTime = widget.appointment['startTime'];
    _selectedEndTime = widget.appointment['endTime'];
  }

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
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFA27B5C), // accentBrown
              onPrimary: Color(0xFFFFFEFA), // backgroundLight
              onSurface: Color(0xFF222222), // text color
              surface: Color(0xFFFFFEFA), // background
              background: Color(0xFFFFFEFA),
            ),
            textTheme: const TextTheme(
              titleLarge: TextStyle(color: Color(0xFF222222)),
              bodyLarge: TextStyle(color: Color(0xFF222222)),
              bodyMedium: TextStyle(color: Color(0xFF222222)),
              labelLarge: TextStyle(color: Color(0xFF222222)),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFFA27B5C),
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            dialogBackgroundColor: Color(0xFFFFFEFA),
          ),
          child: child!,
        );
      },
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
      await AppointmentService.editAppointment(widget.appointment['id'], {
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, size: 60, color: Colors.green),
                  const SizedBox(height: 16),
                  const Text(
                    'Changes Saved!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // close dialog
                            Navigator.pop(
                              context,
                            ); // go back to previous screen
                            // Navigate to active bookings if needed
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'View Active Bookings',
                            style: TextStyle(color: Colors.white),
                          ),
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
                          child: const Text(
                            'Go Back Home',
                            style: TextStyle(color: Colors.black),
                          ),
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
      backgroundColor: const Color(0xFFFDFBF9),
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Column(
                      children: [
                        Text(
                          'Edit Appointment',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Please fill up the form to confirm your\nbooking with us',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () => _pickDate(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: TextEditingController(
                          text:
                              _selectedDate == null
                                  ? ''
                                  : "${_selectedDate!.day} ${_monthName(_selectedDate!.month)}, ${_selectedDate!.year}",
                        ),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.calendar_today),
                          hintText: 'Date',
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (_) =>
                                _selectedDate == null ? 'Select a date' : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedStartTime,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.access_time),
                            hintText: 'Start Time',
                            border: OutlineInputBorder(),
                          ),
                          items:
                              _timeSlots
                                  .map(
                                    (time) => DropdownMenuItem(
                                      value: time,
                                      child: Text(time),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (value) =>
                                  setState(() => _selectedStartTime = value),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedEndTime,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.access_time_outlined),
                            hintText: 'End Time',
                            border: OutlineInputBorder(),
                          ),
                          items:
                              _timeSlots
                                  .map(
                                    (time) => DropdownMenuItem(
                                      value: time,
                                      child: Text(time),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (value) =>
                                  setState(() => _selectedEndTime = value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.note_alt_outlined),
                      hintText: 'I need support to fix my electrical sockets',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Submit',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Colors.black),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month];
  }
}
