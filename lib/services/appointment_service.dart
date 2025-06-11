import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppointmentService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _appointments =
      _firestore.collection('appointments');

  /// Add a new appointment for the current user
  static Future<void> addAppointment(Map<String, dynamic> data) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not logged in');

    await FirebaseFirestore.instance.collection('appointments').add({
      ...data,
      'homeownerId': user.uid,
      'homeownerEmail': user.email,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update an existing appointment by ID
  static Future<void> updateAppointment(String id, Map<String, dynamic> data) async {
    await _appointments.doc(id).update(data);
  }

  /// Stream all appointments for the currently logged-in user
  static Stream<List<Map<String, dynamic>>> getUserAppointments() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return _appointments
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>,
                })
            .toList());
  }

  /// Delete an appointment by its document ID
  static Future<void> deleteAppointment(String id) async {
    await _appointments.doc(id).delete();
  }
}
