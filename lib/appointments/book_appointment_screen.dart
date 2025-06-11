import 'package:flutter/material.dart';
import '../services/appointment_service.dart';
import '../theme/colors.dart';
import 'current_appointments_screen.dart';

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

  // App color constants
  static const Color primaryDark = Color(0xFF222222);
  static const Color secondaryGreen = Color(0xFF3F4F44);
  static const Color accentBrown = Color(0xFFA27B5C);
  static const Color backgroundLight = Color(0xFFFFFEFA);

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
              primary: accentBrown, // Header background and selected date
              onPrimary: backgroundLight, // Header text color
              onSurface: primaryDark, // Calendar text color
              surface: backgroundLight, // Calendar background
              background: backgroundLight, // Picker background
            ),
            textTheme: const TextTheme(
              titleLarge: TextStyle(color: primaryDark),
              bodyLarge: TextStyle(color: primaryDark),
              bodyMedium: TextStyle(color: primaryDark),
              labelLarge: TextStyle(color: primaryDark),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: accentBrown, // Button text color
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            dialogBackgroundColor: backgroundLight,
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

  Future<void> _pickTime(BuildContext context, {required bool isStart}) async {
    final initialTime = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: accentBrown, // Header background and selected time
              onPrimary: backgroundLight, // Header text color
              onSurface: primaryDark, // Time text color
              surface: backgroundLight, // Picker background
              background: backgroundLight,
            ),
            textTheme: const TextTheme(
              titleLarge: TextStyle(color: primaryDark),
              bodyLarge: TextStyle(color: primaryDark),
              bodyMedium: TextStyle(color: primaryDark),
              labelLarge: TextStyle(color: primaryDark),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: accentBrown,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            dialogBackgroundColor: backgroundLight,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _selectedStartTime = picked.format(context);
          // Reset end time if it's before the new start time
          if (_selectedEndTime != null &&
              _selectedDate != null &&
              _parseTime(_selectedEndTime!, _selectedDate!).compareTo(
                    _parseTime(_selectedStartTime!, _selectedDate!),
                  ) <=
                  0) {
            _selectedEndTime = null;
          }
        } else {
          _selectedEndTime = picked.format(context);
        }
      });
    }
  }

  DateTime _parseTime(String time, DateTime date) {
    // Parse a formatted time string (e.g., '10:00 AM') to DateTime
    final timeOfDay = _parseTimeOfDay(time);
    return DateTime(
      date.year,
      date.month,
      date.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
  }

  TimeOfDay _parseTimeOfDay(String time) {
    // Handles both 24h and 12h formats
    final parts = time.split(' ');
    final hm = parts[0].split(':');
    int hour = int.parse(hm[0]);
    int minute = int.parse(hm[1]);
    if (parts.length > 1 && parts[1].toLowerCase() == 'pm' && hour < 12)
      hour += 12;
    if (parts.length > 1 && parts[1].toLowerCase() == 'am' && hour == 12)
      hour = 0;
    return TimeOfDay(hour: hour, minute: minute);
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: backgroundLight,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, size: 60, color: accentBrown),
                  const SizedBox(height: 16),
                  const Text(
                    'Booking Successful!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryDark,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context); // close dialog
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => const CurrentAppointmentsPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryDark,
                              foregroundColor: backgroundLight,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Active Bookings',
                              style: TextStyle(
                                color: backgroundLight,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context); // close dialog
                              Navigator.pop(context); // go back
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(
                                color: primaryDark,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: Colors.transparent,
                            ),
                            child: const Text(
                              'Go Back Home',
                              style: TextStyle(
                                color: primaryDark,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
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
      backgroundColor: backgroundLight,
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
                        color: primaryDark,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: backgroundLight,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Center(
                  child: Column(
                    children: [
                      Text(
                        "Book An Appointment",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryDark,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Please fill up the form to confirm your booking with us",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: secondaryGreen),
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
                        text:
                            _selectedDate == null
                                ? ''
                                : "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}",
                      ),
                      decoration: InputDecoration(
                        hintText: 'Date',
                        hintStyle: const TextStyle(color: secondaryGreen),
                        prefixIcon: const Icon(
                          Icons.calendar_today,
                          color: accentBrown,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: secondaryGreen),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: secondaryGreen),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: accentBrown,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: backgroundLight,
                      ),
                      style: const TextStyle(color: primaryDark),
                      validator:
                          (_) => _selectedDate == null ? 'Select a date' : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _pickTime(context, isStart: true),
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: TextEditingController(
                              text: _selectedStartTime ?? '',
                            ),
                            decoration: InputDecoration(
                              hintText: 'Start Time',
                              hintStyle: const TextStyle(color: secondaryGreen),
                              prefixIcon: const Icon(
                                Icons.access_time,
                                color: accentBrown,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: secondaryGreen,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: secondaryGreen,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: accentBrown,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: backgroundLight,
                            ),
                            style: const TextStyle(color: primaryDark),
                            validator:
                                (_) =>
                                    _selectedStartTime == null
                                        ? 'Select a start time'
                                        : null,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _pickTime(context, isStart: false),
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: TextEditingController(
                              text: _selectedEndTime ?? '',
                            ),
                            decoration: InputDecoration(
                              hintText: 'End Time',
                              hintStyle: const TextStyle(color: secondaryGreen),
                              prefixIcon: const Icon(
                                Icons.access_time,
                                color: accentBrown,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: secondaryGreen,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: secondaryGreen,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: accentBrown,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: backgroundLight,
                            ),
                            style: const TextStyle(color: primaryDark),
                            validator:
                                (_) =>
                                    _selectedEndTime == null
                                        ? 'Select end time'
                                        : null,
                          ),
                        ),
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
                    hintStyle: const TextStyle(color: secondaryGreen),
                    prefixIcon: const Icon(
                      Icons.note_alt_outlined,
                      color: accentBrown,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: secondaryGreen),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: secondaryGreen),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: accentBrown,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: backgroundLight,
                  ),
                  style: const TextStyle(color: primaryDark),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryDark,
                    foregroundColor: backgroundLight,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
