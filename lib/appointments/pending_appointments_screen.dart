import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/homely_scaffold.dart';

class PendingAppointmentsPage extends StatelessWidget {
  const PendingAppointmentsPage({super.key});

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

  Future<void> _updateAppointmentStatus(
    BuildContext context,
    String appointmentId,
    String status,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .update({'status': status});

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Appointment ${status.toLowerCase()}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update appointment status')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return HomelyScaffold(
      selectedIndex: 2,
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('appointments')
                .where('status', isEqualTo: 'pending')
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No pending appointments',
                style: TextStyle(color: AppColors.text),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final appt = doc.data() as Map<String, dynamic>;

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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Pending',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'Client: ${appt['homeownerEmail'] ?? 'Unknown'}',
                        style: const TextStyle(color: AppColors.text),
                      ),
                      if (appt['notes'] != null &&
                          appt['notes'].toString().isNotEmpty)
                        Text(
                          'Notes: ${appt['notes']}',
                          style: const TextStyle(color: AppColors.text),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        tooltip: 'Accept Appointment',
                        onPressed:
                            () => _updateAppointmentStatus(
                              context,
                              doc.id,
                              'accepted',
                            ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        tooltip: 'Reject Appointment',
                        onPressed:
                            () => _updateAppointmentStatus(
                              context,
                              doc.id,
                              'cancelled',
                            ),
                      ),
                    ],
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
