import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../theme/colors.dart';

class UpdateReviewScreen extends StatefulWidget {
  final String reviewId;
  final String currentContent;
  final int currentRating;

  const UpdateReviewScreen({
    super.key,
    required this.reviewId,
    required this.currentContent,
    required this.currentRating,
  });

  @override
  State<UpdateReviewScreen> createState() => _UpdateReviewScreenState();
}

class _UpdateReviewScreenState extends State<UpdateReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _contentController;
  int _rating = 0;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.currentContent);
    _rating = widget.currentRating;
  }

  Future<void> _updateReview() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('reviews').doc(widget.reviewId).update({
        'content': _contentController.text,
        'rating': _rating,
        'updatedAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Review updated successfully")),
      );
      Navigator.pop(context);
    }
  }

  Widget _buildStarRating() {
    return Row(
      children: List.generate(
        5,
        (index) => IconButton(
          onPressed: () {
            setState(() {
              _rating = index + 1;
            });
          },
          icon: Icon(
            index < _rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Review'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildStarRating(),
              TextFormField(
                controller: _contentController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Update your review',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter content' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Update Review', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 