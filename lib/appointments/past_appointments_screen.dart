import 'package:flutter/material.dart';
import '../services/appointment_service.dart';
import 'edit_appointment_screen.dart';
import '../theme/colors.dart';

class RecentAppointmentsPage extends StatelessWidget {
  const RecentAppointmentsPage({super.key});

  bool _isPastAppointment(Map<String, dynamic> appt) {
    try {
      final today = DateTime.now();
      final date = DateTime.parse(appt['date']);
      return date.isBefore(today);
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Past Appointments'),
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
          final pastAppointments =
              allAppointments.where(_isPastAppointment).toList();

          if (pastAppointments.isEmpty) {
            return const Center(
              child: Text(
                'No past appointments',
                style: TextStyle(color: AppColors.text),
              ),
            );
          }

          return ListView.builder(
            itemCount: pastAppointments.length,
            itemBuilder: (context, index) {
              final appt = pastAppointments[index];
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
