import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/appointment_service.dart';
import 'edit_appointment_screen.dart';
import '../theme/colors.dart';
import '../widgets/homely_scaffold.dart';

class RecentAppointmentsPage extends StatelessWidget {
  const RecentAppointmentsPage({super.key});

  bool _isPastAcceptedAppointment(Map<String, dynamic> appt) {
    try {
      final today = DateTime.now();
      final dateField = appt['date'];
      final status = (appt['status'] ?? '').toString().toLowerCase();
      DateTime date;
      if (dateField is Timestamp) {
        date = dateField.toDate();
      } else if (dateField is DateTime) {
        date = dateField;
      } else if (dateField is String) {
        date = DateTime.parse(dateField);
      } else {
        return false;
      }
      // Only show if status is accepted and date is before today
      return status == 'accepted' && date.isBefore(today);
    } catch (_) {
      return false;
    }
  }

  String _formatDate(dynamic dateField) {
    DateTime date;
    if (dateField is Timestamp) {
      date = dateField.toDate();
    } else if (dateField is DateTime) {
      date = dateField;
    } else if (dateField is String) {
      date = DateTime.parse(dateField);
    } else {
      return '-';
    }
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'to be accepted':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return HomelyScaffold(
      selectedIndex: 3,
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: AppointmentService.getUserAppointments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allAppointments = snapshot.data ?? [];
          final pastAppointments =
              allAppointments.where(_isPastAcceptedAppointment).toList();

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
              // status is NOT displayed here
              return Card(
                color: Colors.white,
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  title: Text(
                    '${_formatDate(appt['date'])} — ${appt['startTime']} to ${appt['endTime']}',
                    style: const TextStyle(color: AppColors.text),
                  ),
                  subtitle: Text(
                    appt['notes'] ?? '',
                    style: const TextStyle(color: AppColors.text),
                  ),
                  // Remove the trailing edit button for past appointments
                ),
              );
            },
          );
        },
      ),
    );
  }
}
