import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../theme/colors.dart';
import '../widgets/homely_scaffold.dart';
import '../services/appointment_service.dart';
import '../screens/create_review_screen.dart';
import '../serviceprovider/service_details_screen.dart';

class RecentAppointmentsPage extends StatefulWidget {
  const RecentAppointmentsPage({super.key});

  @override
  State<RecentAppointmentsPage> createState() => _RecentAppointmentsPageState();
}

class _RecentAppointmentsPageState extends State<RecentAppointmentsPage> {
  @override
  void initState() {
    super.initState();
    // Auto-complete old appointments when screen loads
    _autoCompleteOldAppointments();
  }

  Future<void> _autoCompleteOldAppointments() async {
    try {
      await AppointmentService.autoCompleteOldAppointments();
    } catch (e) {
      print('Error auto-completing old appointments: $e');
    }
  }

  String _formatDate(dynamic dateField) {
    try {
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
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return '-';
    }
  }

  String _formatCompletedDate(dynamic completedAtField) {
    try {
      if (completedAtField == null) return 'Unknown';

      DateTime date;
      if (completedAtField is Timestamp) {
        date = completedAtField.toDate();
      } else if (completedAtField is DateTime) {
        date = completedAtField;
      } else if (completedAtField is String) {
        date = DateTime.parse(completedAtField);
      } else {
        return 'Unknown';
      }
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return HomelyScaffold(
      selectedIndex: 3,
      body: Container(
        color: const Color(0xFFF5F5F5), // Light grey background
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: AppointmentService.getCompletedAppointments(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading appointments: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            final completedAppointments = snapshot.data ?? [];

            if (completedAppointments.isEmpty) {
              return const Center(
                child: Text(
                  'No completed appointments yet',
                  style: TextStyle(color: AppColors.text, fontSize: 16),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: completedAppointments.length,
              itemBuilder: (context, index) {
                final appt = completedAppointments[index];
                final serviceName = appt['serviceName'] ?? 'Service';
                final notes = appt['notes'] ?? '';
                final isAutoCompleted = appt['autoCompleted'] == true;

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
                        if (notes.isNotEmpty)
                          Text(
                            notes,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF666666),
                            ),
                          ),

                        const SizedBox(height: 12),

                        // Status and Completion Info
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Completed Status
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Color(
                                          0xFF4CAF50,
                                        ), // Green for completed
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'Completed',
                                      style: TextStyle(
                                        color: Color(0xFF4CAF50),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (isAutoCompleted) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Text(
                                          'Auto',
                                          style: TextStyle(
                                            color: Colors.orange,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),

                                // Review Button
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => CreateReviewScreen(
                                              serviceId:
                                                  appt['serviceId'] ?? '',
                                              providerId:
                                                  appt['providerId'] ?? '',
                                              serviceName: serviceName,
                                            ),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Review',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.highlight,
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    minimumSize: const Size(0, 32),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Completion Date
                            Text(
                              'Completed: ${_formatCompletedDate(appt['completedAt'])}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF888888),
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
          },
        ),
      ),
    );
  }
}
