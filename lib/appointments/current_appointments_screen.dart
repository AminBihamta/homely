import 'package:flutter/material.dart';
import '../services/appointment_service.dart';
import '../theme/colors.dart';
import 'edit_appointment_screen.dart';

class CurrentAppointmentsPage extends StatelessWidget {
  const CurrentAppointmentsPage({super.key});

  bool _isUpcoming(Map<String, dynamic> appt) {
    try {
      final now = DateTime.now();
      final date = DateTime.parse(appt['date']);
      return date.isAfter(now) || date.isAtSameMomentAs(now);
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Upcoming Appointments'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: AppointmentService.getUserAppointments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allAppointments = snapshot.data ?? [];
          final upcoming = allAppointments.where(_isUpcoming).toList();

          if (upcoming.isEmpty) {
            return const Center(
              child: Text(
                'No upcoming appointments',
                style: TextStyle(color: AppColors.text),
              ),
            );
          }

          return ListView.builder(
            itemCount: upcoming.length,
            itemBuilder: (context, index) {
              final appt = upcoming[index];
              return Card(
                color: Colors.white,
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  title: Text(
                    '${appt['date']} — ${appt['startTime']} to ${appt['endTime']}',
                    style: const TextStyle(color: AppColors.text),
                  ),
                  subtitle: Text(
                    appt['notes'] ?? '',
                    style: const TextStyle(color: AppColors.text),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: AppColors.highlight),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EditAppointmentPage(appointment: appt),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
