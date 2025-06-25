import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/colors.dart';
import '../widgets/homely_scaffold.dart';
import '../services/review_service.dart';
import 'service_reviews_detail_screen.dart';

class ProviderServicesReviewsScreen extends StatefulWidget {
  const ProviderServicesReviewsScreen({super.key});

  @override
  State<ProviderServicesReviewsScreen> createState() =>
      _ProviderServicesReviewsScreenState();
}

class _ProviderServicesReviewsScreenState
    extends State<ProviderServicesReviewsScreen> {
  String? userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
  }

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor()
              ? Icons.star
              : (index < rating && rating % 1 >= 0.5)
              ? Icons.star_half
              : Icons.star_border,
          color: Colors.amber,
          size: 16,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return HomelyScaffold(
        selectedIndex: 3, // Reviews tab
        body: const Center(
          child: Text(
            'User not logged in.',
            style: TextStyle(color: AppColors.text),
          ),
        ),
        showLogout: false,
      );
    }

    return HomelyScaffold(
      selectedIndex: 3, // Reviews tab
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'My Service Reviews',
          style: TextStyle(color: AppColors.background),
        ),
        iconTheme: const IconThemeData(color: AppColors.background),
        elevation: 2,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('services')
                  .where('user_id', isEqualTo: userId)
                  .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading services: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.business_center_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No services available.',
                      style: TextStyle(color: AppColors.text, fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            final services = snapshot.data!.docs;

            return ListView.builder(
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                final serviceData = service.data() as Map<String, dynamic>;
                final serviceId = service.id;
                final serviceName = serviceData['name'] ?? 'Unknown Service';

                return Card(
                  color: AppColors.background,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ServiceReviewsDetailScreen(
                                serviceId: serviceId,
                                serviceName: serviceName,
                              ),
                        ),
                      );
                    },
                    title: Text(
                      serviceName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          serviceData['description'] ?? 'No description',
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        FutureBuilder<Map<String, dynamic>>(
                          future: ReviewService.getServiceRatingStats(
                            serviceId,
                          ),
                          builder: (context, reviewSnapshot) {
                            if (reviewSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const SizedBox(
                                height: 20,
                                child: Text(
                                  'Loading reviews...',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            }

                            if (!reviewSnapshot.hasData) {
                              return const Text(
                                'No reviews yet',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              );
                            }

                            final stats = reviewSnapshot.data!;
                            final averageRating =
                                stats['averageRating'] as double;
                            final totalReviews = stats['totalReviews'] as int;

                            if (totalReviews == 0) {
                              return const Text(
                                'No reviews yet',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              );
                            }

                            return Row(
                              children: [
                                _buildStarRating(averageRating),
                                const SizedBox(width: 8),
                                Text(
                                  '${averageRating.toStringAsFixed(1)} ($totalReviews review${totalReviews == 1 ? '' : 's'})',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.text,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.primary,
                      size: 16,
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
