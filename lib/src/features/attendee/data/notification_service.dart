import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/models/notification.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendNotification(Notification notification) async {
    await _firestore.collection('notifications').add(notification.toMap());
  }

  Stream<List<Notification>> getNotificationsForEvent(String eventId) {
    return _firestore
        .collection('notifications')
        .where('eventId', isEqualTo: eventId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Notification.fromMap(doc.data(), id: doc.id);
          }).toList();
        });
  }

  Stream<List<Notification>> getAllNotifications() {
    return _firestore
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Notification.fromMap(doc.data(), id: doc.id);
          }).toList();
        });
  }
}
