import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/homely_scaffold.dart';
import 'package:intl/intl.dart';
import 'appointment_details_provider.dart';

class PendingAppointmentsPage extends StatelessWidget {
  const PendingAppointmentsPage({super.key});

  String _formatDate(dynamic dateField) {
    DateTime date;
    try {
      if (dateField is Timestamp) {
        date = dateField.toDate();
      } else if (dateField is DateTime) {
        date = dateField;
      } else if (dateField is String) {
        // Try to parse as ISO first
        try {
          date = DateTime.parse(dateField);
        } catch (_) {
          // Fallback to known formats like dd/MM/yyyy
          date = DateFormat('dd/MM/yyyy').parse(dateField);
        }
      } else {
        return '-';
      }

      return DateFormat('yyyy-MM-dd').format(date);
    } catch (e) {
      return '-';
    }
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
      body: Container(
        color: const Color(0xFFF5F5F5),
        child: StreamBuilder<QuerySnapshot>(
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
                  style: TextStyle(color: AppColors.text, fontSize: 16),
                ),
              );
            }

            final docs = snapshot.data!.docs;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                final appt = doc.data() as Map<String, dynamic>;
                final serviceName = appt['serviceName'] ?? '';
                final notes = appt['notes'] ?? '';
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (serviceName.isNotEmpty)
                          Text(
                            serviceName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        const SizedBox(height: 8),
                        Text(
                          '${_formatDate(appt['date'])} — ${appt['startTime']} to ${appt['endTime']}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (notes.isNotEmpty)
                          Text(
                            notes,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF666666),
                            ),
                          ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF9E9E9E),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Pending',
                                  style: TextStyle(
                                    color: Color(0xFF9E9E9E),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 18,
                                    ),
                                    tooltip: 'Accept Appointment',
                                    onPressed:
                                        () => _updateAppointmentStatus(
                                          context,
                                          doc.id,
                                          'accepted',
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFEBEE),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.cancel,
                                      color: Color(0xFFE53E3E),
                                      size: 18,
                                    ),
                                    tooltip: 'Reject Appointment',
                                    onPressed:
                                        () => _updateAppointmentStatus(
                                          context,
                                          doc.id,
                                          'cancelled',
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
