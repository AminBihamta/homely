import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/colors.dart';

class AppointmentDetailsProvider extends StatelessWidget {
  final Map<String, dynamic> appointment;

  const AppointmentDetailsProvider({super.key, required this.appointment});

  Future<Map<String, dynamic>?> _fetchHomeownerData(String? email) async {
    if (email == null || email.isEmpty) return null;
    final query =
        await FirebaseFirestore.instance
            .collection('user_data')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();
    if (query.docs.isEmpty) return null;
    return query.docs.first.data();
  }

  String _formatDateTime(dynamic dateTime) {
    if (dateTime == null) return '-';
    try {
      if (dateTime is Timestamp) {
        dateTime = dateTime.toDate();
      } else if (dateTime is String) {
        try {
          dateTime = DateTime.parse(dateTime);
        } catch (_) {
          dateTime = DateFormat('dd/MM/yyyy').parse(dateTime);
        }
      }
      return DateFormat('dd/MM/yyyy, h:mm a').format(dateTime);
    } catch (_) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? homeownerEmail = appointment['homeownerEmail'];
    final String serviceName = appointment['serviceName'] ?? 'Service';
    final String description =
        appointment['notes'] ?? appointment['description'] ?? '';
    final String? startTime = appointment['startTime'];
    final String? endTime = appointment['endTime'];
    final dynamic date = appointment['date'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Appointment Details',
          style: TextStyle(color: AppColors.background),
        ),
        iconTheme: const IconThemeData(color: AppColors.background),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchHomeownerData(homeownerEmail),
        builder: (context, snapshot) {
          final homeowner = snapshot.data;
          final requesterName =
              homeowner?['name'] ?? homeownerEmail ?? 'Unknown';
          final address = homeowner?['address'] ?? 'No address provided';
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service Name
                Text(
                  serviceName,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 24),
                // Profile + Requested By + Address
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.primary,
                      child: Icon(
                        Icons.person,
                        color: AppColors.background,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Requested By',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            requesterName,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            address,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColors.text,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Start and End Time
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Start',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDateTime(date) +
                                (startTime != null ? ' $startTime' : ''),
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.text,
                            ),
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'End',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDateTime(date) +
                                (endTime != null ? ' $endTime' : ''),
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.text,
                            ),
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Description
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(fontSize: 16, color: AppColors.text),
                ),
                const SizedBox(height: 40),
                // Cancel Button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement cancel logic
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.background,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Cancel Appointment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/appointment_details_provider':
        final args = settings.arguments as Map<String, dynamic>?;
        final appointment = args?['appointmentData'] as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder:
              (_) => AppointmentDetailsProvider(appointment: appointment ?? {}),
        );
      // ...other routes...
      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for \'${settings.name}\''),
                ),
              ),
        );
    }
  }
}
