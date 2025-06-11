import 'package:cloud_firestore/cloud_firestore.dart';
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return const Color(0xFF4CAF50); // Green
      case 'to be accepted':
      case 'pending':
        return const Color(0xFF9E9E9E); // Grey
      case 'cancelled':
        return const Color(0xFFF44336); // Red
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  String _getDisplayStatus(String status) {
    switch (status.toLowerCase()) {
      case 'to be accepted':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    return HomelyScaffold(
      selectedIndex: 2,
      body: Container(
        color: const Color(0xFFF5F5F5), // Light grey background
        child: StreamBuilder<List<Map<String, dynamic>>>(
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
                  style: TextStyle(color: AppColors.text, fontSize: 16),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: upcoming.length,
              itemBuilder: (context, index) {
                final appt = upcoming[index];
                final status = (appt['status'] ?? 'to be accepted').toString();
                final serviceName = appt['serviceName'] ?? '';
                final displayStatus = _getDisplayStatus(status);
                final statusColor = _getStatusColor(status);
                final isEditable = status.toLowerCase() != 'accepted';

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
                        // Service Name
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

                        // Date and Time
                        Text(
                          '${_formatDate(appt['date'])} — ${appt['startTime']} to ${appt['endTime']}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Notes
                        if (appt['notes'] != null &&
                            appt['notes'].toString().isNotEmpty)
                          Text(
                            appt['notes'].toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF666666),
                            ),
                          ),

                        const SizedBox(height: 12),

                        // Status and Action Buttons Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Status
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  displayStatus,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                            // Action Buttons
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Edit Button (only show if not accepted)
                                if (status.toLowerCase() != 'accepted')
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F5F5),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Color(0xFF8B4513), // Brown color
                                        size: 18,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => EditAppointmentPage(
                                                  appointment: appt,
                                                ),
                                          ),
                                        );
                                      },
                                      tooltip: 'Edit appointment',
                                    ),
                                  ),
                                // Cancel Button (always shown)
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFEBEE),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Color(0xFFE53E3E),
                                      size: 18,
                                    ),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder:
                                            (context) => AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              backgroundColor:
                                                  AppColors.background,
                                              title: const Text(
                                                'Cancel Appointment',
                                                style: TextStyle(
                                                  color: AppColors.text,
                                                ),
                                              ),
                                              content: const Text(
                                                'Are you sure you want to cancel this appointment?',
                                                style: TextStyle(
                                                  color: AppColors.text,
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                        false,
                                                      ),
                                                  child: const Text(
                                                    'No',
                                                    style: TextStyle(
                                                      color: AppColors.text,
                                                    ),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                        true,
                                                      ),
                                                  child: Text(
                                                    'Yes',
                                                    style: TextStyle(
                                                      color: Color(
                                                        0xFFE53E3E,
                                                      ), // fallback error color
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                      );
                                      if (confirm == true) {
                                        await AppointmentService.deleteAppointment(
                                          appt['id'],
                                        );
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Appointment cancelled',
                                              ),
                                              backgroundColor: Color(
                                                0xFF4CAF50,
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
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
