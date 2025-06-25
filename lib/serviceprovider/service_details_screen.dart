import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import '../theme/colors.dart';
import '../appointments/book_appointment_screen.dart'; // Import the BookAppointmentPage
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/create_review_screen.dart';
import '../screens/update_review_screen.dart';
import '../services/review_service.dart';
import '../models/review_model.dart';

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

  Future<bool> _isProvider() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    final doc =
        await FirebaseFirestore.instance
            .collection('user_data')
            .doc(user.uid)
            .get();
    final data = doc.data() ?? {};
    return data['isProvider'] == true;
  }

  Widget _buildReviewTile(
    ReviewModel review,
    String userName,
    bool isMyReview,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isMyReview ? Colors.transparent : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: isMyReview ? null : Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Star rating
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < review.rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                userName,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isMyReview ? AppColors.primary : AppColors.text,
                ),
              ),
              const Spacer(),
              if (isMyReview) ...[
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => UpdateReviewScreen(
                                reviewId: review.id,
                                currentContent: review.content,
                                currentRating: review.rating,
                              ),
                        ),
                      );
                    } else if (value == 'delete') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Delete Review'),
                              content: const Text(
                                'Are you sure you want to delete this review?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                      );
                      if (confirm == true) {
                        await ReviewService.deleteReview(review.id);
                      }
                    }
                  },
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Colors.blue, size: 18),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red, size: 18),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                  child: const Icon(Icons.more_vert, size: 18),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.content,
            style: const TextStyle(fontSize: 14, color: AppColors.text),
          ),
          const SizedBox(height: 4),
          Text(
            _formatDate(review.createdAt),
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 32.0),
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
                        color: AppColors.primary,
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Service name
                          Text(
                            serviceName,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 16),
                          
                          // Average Rating Section
                          FutureBuilder<Map<String, dynamic>>(
                            future: ReviewService.getServiceRatingStats(serviceId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const SizedBox(height: 8);
                              }

                              if (!snapshot.hasData) {
                                return const SizedBox(height: 8);
                              }

                              final stats = snapshot.data!;
                              final averageRating =
                                  stats['averageRating'] as double;
                              final totalReviews = stats['totalReviews'] as int;

                              if (totalReviews == 0) {
                                return const Padding(
                                  padding: EdgeInsets.only(top: 8.0, bottom: 16.0),
                                  child: Text(
                                    'No reviews yet',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              }

                              return Padding(
                                padding: const EdgeInsets.only(
                                  top: 8.0,
                                  bottom: 16.0,
                                ),
                                child: Row(
                                  children: [
                                    // Star rating display
                                    Row(
                                      children: List.generate(5, (index) {
                                        return Icon(
                                          index < averageRating.floor()
                                              ? Icons.star
                                              : (index < averageRating &&
                                                  averageRating % 1 >= 0.5)
                                              ? Icons.star_half
                                              : Icons.star_border,
                                          color: Colors.amber,
                                          size: 20,
                                        );
                                      }),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${averageRating.toStringAsFixed(1)} ($totalReviews review${totalReviews == 1 ? '' : 's'})',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.text,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          
                          // Description Section
                          FutureBuilder<DocumentSnapshot>(
                            future:
                                FirebaseFirestore.instance
                                    .collection('services')
                                    .doc(serviceId)
                                    .get(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 0),
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                );
                              }
                              if (!snapshot.hasData || !snapshot.data!.exists) {
                                return const Text(
                                  'No description available.',
                                  style: TextStyle(color: Colors.grey),
                                );
                              }
                              final data = snapshot.data!.data() as Map<String, dynamic>?;
                              final description =
                                  data?['description'] ?? 'No description provided.';
                              return Text(
                                description,
                                style: const TextStyle(
                                  color: AppColors.text,
                                  fontSize: 15,
                                ),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Buttons Row
                          FutureBuilder<bool>(
                            future: _isProvider(),
                            builder: (context, snapshot) {
                              final isProvider = snapshot.data ?? false;
                              return Row(
                                children: [
                                  // Review Service button for non-providers
                                  if (!isProvider) ...[
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.highlight,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                        ),
                                        onPressed: () async {
                                          // Fetch providerId for the service
                                          final serviceDoc =
                                              await FirebaseFirestore.instance
                                                  .collection('services')
                                                  .doc(serviceId)
                                                  .get();
                                          final providerId =
                                              serviceDoc.data()?['user_id'] ?? '';
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => CreateReviewScreen(
                                                    serviceId: serviceId,
                                                    providerId: providerId,
                                                    serviceName: serviceName,
                                                  ),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          'Review Service',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                  ],
                                  // Book Appointment button
                                  Expanded(
                                    child: ElevatedButton(
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
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Reviews Section
                      const SizedBox(height: 8),
                      const Text(
                        'Reviews',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Reviews display with better handling
                      StreamBuilder<List<Map<String, dynamic>>>(
                        stream: ReviewService.getReviewsWithUserInfo(serviceId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            print('Error loading reviews: ${snapshot.error}');
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Text(
                                'Error loading reviews.',
                                style: TextStyle(color: Colors.red),
                              ),
                            );
                          }

                          final reviewsWithUserInfo = snapshot.data ?? [];
                          print(
                            'Loaded ${reviewsWithUserInfo.length} reviews for service $serviceId',
                          );

                          if (reviewsWithUserInfo.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Text(
                                'No reviews yet.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            );
                          }

                          final user = FirebaseAuth.instance.currentUser;

                          // Separate user's reviews from others
                          final myReviews =
                              reviewsWithUserInfo
                                  .where(
                                    (item) =>
                                        user != null &&
                                        (item['review'] as ReviewModel)
                                                .userId ==
                                            user.uid,
                                  )
                                  .toList();

                          final otherReviews =
                              reviewsWithUserInfo
                                  .where(
                                    (item) =>
                                        user == null ||
                                        (item['review'] as ReviewModel)
                                                .userId !=
                                            user.uid,
                                  )
                                  .toList();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // User's own reviews section
                              if (myReviews.isNotEmpty) ...[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.primary.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(
                                            Icons.person,
                                            color: AppColors.primary,
                                            size: 20,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Your Review',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      ...myReviews.map((item) {
                                        final review =
                                            item['review'] as ReviewModel;
                                        return _buildReviewTile(
                                          review,
                                          item['userName'],
                                          true,
                                          context,
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ],

                              // Other reviews section
                              if (otherReviews.isNotEmpty) ...[
                                if (myReviews.isNotEmpty)
                                  const Text(
                                    'Other Reviews',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: AppColors.text,
                                    ),
                                  ),
                                if (myReviews.isNotEmpty)
                                  const SizedBox(height: 12),
                                ...otherReviews.map((item) {
                                  final review = item['review'] as ReviewModel;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _buildReviewTile(
                                      review,
                                      item['userName'],
                                      false,
                                      context,
                                    ),
                                  );
                                }),
                              ],
                            ],
                          );
                        },
                      ),

                      // Other Services Section
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
                        child: FutureBuilder<DocumentSnapshot>(
                          future:
                              FirebaseFirestore.instance
                                  .collection('services')
                                  .doc(serviceId)
                                  .get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              );
                            }
                            if (!snapshot.hasData || !snapshot.data!.exists) {
                              return const Text(
                                'No other services available.',
                                style: TextStyle(color: Colors.grey),
                              );
                            }
                            final data = snapshot.data!.data() as Map<String, dynamic>?;
                            final providerId = data?['user_id'] ?? '';
                            
                            return StreamBuilder<QuerySnapshot>(
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
                                      (context, idx) => const SizedBox(width: 12),
                                  itemBuilder: (context, idx) {
                                    final doc = otherDocs[idx];
                                    final d = doc.data() as Map<String, dynamic>;
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
                                          borderRadius: BorderRadius.circular(16),
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
                                                      color: AppColors.highlight,
                                                      fontWeight: FontWeight.bold,
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
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
