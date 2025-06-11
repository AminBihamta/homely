import 'package:cloud_firestore/cloud_firestore.dart'; // <-- Add this line
import 'package:flutter/material.dart';
import '../services/appointment_service.dart';
import '../theme/colors.dart';
import 'edit_appointment_screen.dart';
import '../widgets/homely_scaffold.dart';

class CurrentAppointmentsPage extends StatelessWidget {
  const CurrentAppointmentsPage({super.key});

  bool _isUpcoming(Map<String, dynamic> appt) {
    try {
      final now = DateTime.now();
      final dateField = appt['date'];
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
      return date.isAfter(now) || date.isAtSameMomentAs(now);
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
      selectedIndex: 2,
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
              final status = (appt['status'] ?? 'to be accepted').toString();
              return Card(
                color: Colors.white,
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${_formatDate(appt['date'])} — ${appt['startTime']} to ${appt['endTime']}',
                          style: const TextStyle(color: AppColors.text),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.circle, color: _statusColor(status), size: 12),
                          const SizedBox(width: 4),
                          Text(
                            status[0].toUpperCase() + status.substring(1),
                            style: TextStyle(
                              color: _statusColor(status),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
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
