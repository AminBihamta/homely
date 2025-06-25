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
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => {...doc.data(), 'id': doc.id})
                  .toList(),
        );
  }

  static Future<void> editAppointment(
    String appointmentId,
    Map<String, dynamic> newData,
  ) async {
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

  // Mark appointment as completed
  static Future<void> completeAppointment(String appointmentId) async {
    await FirebaseFirestore.instance
        .collection('appointments')
        .doc(appointmentId)
        .update({
          'status': 'completed',
          'completedAt': FieldValue.serverTimestamp(),
        });
  }

  // Get appointments that need auto-completion (accepted appointments older than 1 month)
  static Future<void> autoCompleteOldAppointments() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final oneMonthAgo = DateTime.now().subtract(const Duration(days: 30));

    final snapshot =
        await FirebaseFirestore.instance
            .collection('appointments')
            .where('homeownerId', isEqualTo: user.uid)
            .where('status', isEqualTo: 'accepted')
            .get();

    final batch = FirebaseFirestore.instance.batch();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final dateField = data['date'];
      DateTime? appointmentDate;

      try {
        if (dateField is Timestamp) {
          appointmentDate = dateField.toDate();
        } else if (dateField is DateTime) {
          appointmentDate = dateField;
        } else if (dateField is String) {
          appointmentDate = DateTime.parse(dateField);
        }

        if (appointmentDate != null && appointmentDate.isBefore(oneMonthAgo)) {
          batch.update(doc.reference, {
            'status': 'completed',
            'completedAt': FieldValue.serverTimestamp(),
            'autoCompleted': true,
          });
        }
      } catch (e) {
        // Skip appointments with invalid dates
        print('Error parsing date for appointment ${doc.id}: $e');
        continue;
      }
    }

    await batch.commit();
  }

  // Get completed appointments for recent appointments screen
  static Stream<List<Map<String, dynamic>>> getCompletedAppointments() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('appointments')
        .where('homeownerId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'completed')
        .snapshots()
        .map((snapshot) {
          final appointments = snapshot.docs
              .map((doc) => {...doc.data(), 'id': doc.id})
              .toList();
          
          // Sort by completedAt date, newest first
          appointments.sort((a, b) {
            try {
              final aCompletedAt = a['completedAt'];
              final bCompletedAt = b['completedAt'];
              
              if (aCompletedAt == null && bCompletedAt == null) return 0;
              if (aCompletedAt == null) return 1;
              if (bCompletedAt == null) return -1;
              
              DateTime aDate, bDate;
              
              if (aCompletedAt is Timestamp) {
                aDate = aCompletedAt.toDate();
              } else if (aCompletedAt is DateTime) {
                aDate = aCompletedAt;
              } else {
                return 1;
              }
              
              if (bCompletedAt is Timestamp) {
                bDate = bCompletedAt.toDate();
              } else if (bCompletedAt is DateTime) {
                bDate = bCompletedAt;
              } else {
                return -1;
              }
              
              return bDate.compareTo(aDate); // Newest first
            } catch (e) {
              print('Error sorting appointments: $e');
              return 0;
            }
          });
          
          return appointments;
        });
  }
}
