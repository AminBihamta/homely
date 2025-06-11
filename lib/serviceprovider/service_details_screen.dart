import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import '../theme/colors.dart';
import '../appointments/book_appointment_screen.dart'; // Import the BookAppointmentPage

class ServiceDetailsScreen extends StatelessWidget {
  final String serviceId;
  final String serviceName;
  final String companyName;
  final int rating;
  final int totalReviews;

  const ServiceDetailsScreen({
    super.key,
    required this.serviceId,
    required this.serviceName,
    required this.companyName,
    this.rating = 4,
    this.totalReviews = 129,
  });

  Future<String> _fetchProviderName(String serviceId) async {
    // Fetch the service document to get the user_id
    final serviceDoc =
        await FirebaseFirestore.instance
            .collection('services')
            .doc(serviceId)
            .get();
    final userId = serviceDoc.data()?['user_id'] ?? '';
    if (userId.isEmpty) return 'Unknown';
    // Fetch the user's name from the user_data collection (not users)
    final userDoc =
        await FirebaseFirestore.instance
            .collection('user_data')
            .doc(userId)
            .get();
    return userDoc.data()?['name'] ?? 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with image and back button
            Stack(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(30),
                    ),
                    color:
                        AppColors
                            .primary, // Use themed primary color for image placeholder
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: AppColors.background,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: AppColors.text),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Book button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service name wrapped in Expanded and Text with softWrap and maxLines
                      Expanded(
                        child: Text(
                          serviceName,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                          softWrap: true,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => BookAppointmentPage(
                                    serviceId: serviceId,
                                    providerId: '',
                                    serviceName: serviceName,
                                  ),
                            ),
                          );
                        },
                        child: const Text(
                          "Book Appointment",
                          style: TextStyle(color: AppColors.background),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Rating
                  Row(
                    children: [
                      Icon(Icons.star, color: AppColors.highlight, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '$rating ($totalReviews Reviews)',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Company Info
                  Row(
                    children: [
                      Icon(Icons.account_circle, color: AppColors.primary),
                      const SizedBox(width: 6),
                      FutureBuilder<String>(
                        future: _fetchProviderName(serviceId),
                        builder: (context, snapshot) {
                          final providerName = snapshot.data ?? '...';
                          return Text(
                            'by $providerName',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description Section
                  const SizedBox(height: 16),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: AppColors.text,
                    ),
                  ),
                  FutureBuilder<DocumentSnapshot>(
                    future:
                        FirebaseFirestore.instance
                            .collection('services')
                            .doc(serviceId)
                            .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      }
                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return const Text(
                          'No description available.',
                          style: TextStyle(color: Colors.grey),
                        );
                      }
                      final data =
                          snapshot.data!.data() as Map<String, dynamic>?;
                      final description =
                          data?['description'] ?? 'No description provided.';
                      final providerId = data?['user_id'] ?? '';
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              description,
                              style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          const Text(
                            'Other Services',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 170,
                            child: StreamBuilder<QuerySnapshot>(
                              stream:
                                  FirebaseFirestore.instance
                                      .collection('services')
                                      .where('user_id', isEqualTo: providerId)
                                      .snapshots(),
                              builder: (context, otherSnapshot) {
                                if (otherSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  );
                                }
                                if (!otherSnapshot.hasData ||
                                    otherSnapshot.data!.docs.isEmpty) {
                                  return const Text(
                                    'No other services available.',
                                    style: TextStyle(color: Colors.grey),
                                  );
                                }
                                final otherDocs =
                                    otherSnapshot.data!.docs
                                        .where((doc) => doc.id != serviceId)
                                        .toList();
                                if (otherDocs.isEmpty) {
                                  return const Text(
                                    'No other services available.',
                                    style: TextStyle(color: Colors.grey),
                                  );
                                }
                                return ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: otherDocs.length,
                                  separatorBuilder:
                                      (context, idx) =>
                                          const SizedBox(width: 12),
                                  itemBuilder: (context, idx) {
                                    final doc = otherDocs[idx];
                                    final d =
                                        doc.data() as Map<String, dynamic>;
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => ServiceDetailsScreen(
                                                  serviceId: doc.id,
                                                  serviceName: d['name'] ?? '',
                                                  companyName: '',
                                                ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: 180,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.07,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 4,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.work,
                                                    color: AppColors.primary,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      d['name'] ?? '',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15,
                                                        color: AppColors.text,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                d['description'] ?? '',
                                                style: const TextStyle(
                                                  color: AppColors.text,
                                                  fontSize: 13,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const Spacer(),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'RM${(d['hourly_rate'] ?? 0).toString()}',
                                                    style: const TextStyle(
                                                      color:
                                                          AppColors.highlight,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const Icon(
                                                    Icons.arrow_forward_ios,
                                                    size: 16,
                                                    color: AppColors.primary,
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
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
