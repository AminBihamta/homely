import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String serviceId;
  final String userId;
  final String providerId;
  final String content;
  final int rating;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.serviceId,
    required this.userId,
    required this.providerId,
    required this.content,
    required this.rating,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serviceId': serviceId,
      'userId': userId,
      'providerId': providerId,
      'content': content,
      'rating': rating,
      'createdAt': createdAt,
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'],
      serviceId: map['serviceId'],
      userId: map['userId'],
      providerId: map['providerId'],
      content: map['content'],
      rating: map['rating'],
      createdAt:
          map['createdAt'] is Timestamp
              ? (map['createdAt'] as Timestamp).toDate()
              : map['createdAt'] is DateTime
              ? map['createdAt']
              : DateTime.now(), // fallback for missing timestamps
    );
  }
}
