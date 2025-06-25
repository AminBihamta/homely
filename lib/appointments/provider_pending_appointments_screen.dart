import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../theme/colors.dart';
import '../widgets/homely_scaffold.dart';
import '../services/appointment_service.dart';
import 'appointment_details_provider.dart';

class ProviderPendingAppointmentsPage extends StatelessWidget {
  const ProviderPendingAppointmentsPage({super.key});

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

  Future<String> _getHomeownerName(String? homeownerEmail) async {
    if (homeownerEmail == null || homeownerEmail.isEmpty) return 'Unknown';

    try {
      final query =
          await FirebaseFirestore.instance
              .collection('user_data')
              .where('email', isEqualTo: homeownerEmail)
              .limit(1)
              .get();

      if (query.docs.isNotEmpty) {
        return query.docs.first.data()['name'] ?? 'Unknown';
      }
    } catch (e) {
      print('Error fetching homeowner name: $e');
    }
    return 'Unknown';
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
      selectedIndex: 1, // Calendar tab for providers
      body: Container(
        color: const Color(0xFFF5F5F5),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: AppointmentService.getProviderCurrentAppointments(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'No current appointments',
                  style: TextStyle(color: AppColors.text, fontSize: 16),
                ),
              );
            }

            final appointments = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appt = appointments[index];
                final serviceName = appt['serviceName'] ?? '';
                final notes = appt['notes'] ?? '';
                final appointmentId = appt['id'] as String;
                final homeownerEmail = appt['homeownerEmail'] as String?;

                return GestureDetector(
                  onTap: () {
                    // Navigate to booking details instead of service details
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AppointmentDetailsProvider(
                          appointment: appt,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
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
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    serviceName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1A1A1A),
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          const SizedBox(height: 8),

                          // Customer Info
                          FutureBuilder<String>(
                            future: _getHomeownerName(homeownerEmail),
                            builder: (context, homeownerSnapshot) {
                              final customerName =
                                  homeownerSnapshot.data ?? 'Loading...';
                              return Row(
                                children: [
                                  const Icon(
                                    Icons.person_outline,
                                    size: 16,
                                    color: Color(0xFF666666),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Customer: $customerName',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF666666),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              );
                            },
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
                                    decoration: BoxDecoration(
                                      color:
                                          appt['status'] == 'accepted'
                                              ? Colors.green
                                              : const Color(0xFF9E9E9E),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    appt['status'] == 'accepted'
                                        ? 'Accepted'
                                        : 'Pending',
                                    style: TextStyle(
                                      color:
                                          appt['status'] == 'accepted'
                                              ? Colors.green
                                              : const Color(0xFF9E9E9E),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              // Only show action buttons for pending appointments
                              if (appt['status'] == 'pending')
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
                                              appointmentId,
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
                                              appointmentId,
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
