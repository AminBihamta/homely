import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class ReviewService {
  static final CollectionReference reviewsRef = FirebaseFirestore.instance
      .collection('reviews');

  // Create a review
  static Future<void> addReview(ReviewModel review) async {
    await reviewsRef.doc(review.id).set(review.toMap());
  }

  // Read reviews for a specific service
  static Stream<List<ReviewModel>> getReviewsByService(String serviceId) {
    return reviewsRef
        .where('serviceId', isEqualTo: serviceId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) =>
                    ReviewModel.fromMap(doc.data() as Map<String, dynamic>),
              )
              .toList();
        });
  }

  // Update a review
  static Future<void> updateReview(ReviewModel review) async {
    await reviewsRef.doc(review.id).update(review.toMap());
  }

  // Delete a review
  static Future<void> deleteReview(String id) async {
    await reviewsRef.doc(id).delete();
  }

  // Get average rating and total reviews for a service
  static Future<Map<String, dynamic>> getServiceRatingStats(
    String serviceId,
  ) async {
    final snapshot =
        await reviewsRef.where('serviceId', isEqualTo: serviceId).get();

    if (snapshot.docs.isEmpty) {
      return {'averageRating': 0.0, 'totalReviews': 0};
    }

    final reviews =
        snapshot.docs
            .map(
              (doc) => ReviewModel.fromMap(doc.data() as Map<String, dynamic>),
            )
            .toList();

    final totalRating = reviews.fold<int>(
      0,
      (sum, review) => sum + review.rating,
    );
    final averageRating = totalRating / reviews.length;

    return {'averageRating': averageRating, 'totalReviews': reviews.length};
  }

  // Get reviews for a service with user information
  static Stream<List<Map<String, dynamic>>> getReviewsWithUserInfo(
    String serviceId,
  ) {
    return reviewsRef
        .where('serviceId', isEqualTo: serviceId)
        .snapshots()
        .asyncMap((snapshot) async {
          List<Map<String, dynamic>> reviewsWithUserInfo = [];

          for (var doc in snapshot.docs) {
            final reviewData = doc.data() as Map<String, dynamic>;
            try {
              final review = ReviewModel.fromMap(reviewData);

              // Fetch user information
              try {
                final userDoc =
                    await FirebaseFirestore.instance
                        .collection('user_data')
                        .doc(review.userId)
                        .get();

                final userName =
                    userDoc.exists
                        ? (userDoc.data()?['name'] ?? 'Anonymous')
                        : 'Anonymous';

                reviewsWithUserInfo.add({
                  'review': review,
                  'userName': userName,
                });
              } catch (e) {
                // If user fetch fails, still include the review with anonymous name
                reviewsWithUserInfo.add({
                  'review': review,
                  'userName': 'Anonymous',
                });
              }
            } catch (e) {
              print('Error parsing review from document ${doc.id}: $e');
              // Skip this review if it can't be parsed
              continue;
            }
          }

          // Sort by creation date, newest first
          reviewsWithUserInfo.sort((a, b) {
            final aDate = (a['review'] as ReviewModel).createdAt;
            final bDate = (b['review'] as ReviewModel).createdAt;
            return bDate.compareTo(aDate);
          });

          return reviewsWithUserInfo;
        });
  }
}
