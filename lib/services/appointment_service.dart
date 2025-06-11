import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppointmentService {
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

  static Stream<List<Map<String, dynamic>>> getUserAppointments() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('appointments')
        .where('homeownerId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  ...doc.data(),
                  'id': doc.id,
                })
            .toList());
  }

  static Future<void> editAppointment(String appointmentId, Map<String, dynamic> newData) async {
    await FirebaseFirestore.instance
        .collection('appointments')
        .doc(appointmentId)
        .update(newData);
  }

  static Future<void> deleteAppointment(String appointmentId) async {
    await FirebaseFirestore.instance
        .collection('appointments')
        .doc(appointmentId)
        .delete();
  }
}
