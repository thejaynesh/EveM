import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/models/notification.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'notifications';

  Future<void> sendNotification(Notification notification) async {
    await _firestore.collection(_collectionPath).add(notification.toMap());
  }

  Stream<List<Notification>> getNotificationsForEvent(String eventId) {
    return _firestore
        .collection(_collectionPath)
        .where('eventId', isEqualTo: eventId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return Notification.fromMap(data, id: doc.id);
          }).toList();
        });
  }

  Stream<List<Notification>> getAllNotifications() {
    return _firestore
        .collection(_collectionPath)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return Notification.fromMap(data, id: doc.id);
          }).toList();
        });
  }

  /// Fetches notifications specifically for the logged-in user.
  Stream<List<Notification>> getUserNotifications(String userId) {
    return _firestore
        .collection(_collectionPath)
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return Notification.fromMap(data, id: doc.id);
          }).toList();
        });
  }

  /// Deletes a notification by its ID.
  Future<void> deleteNotification(String notificationId) async {
    await _firestore.collection(_collectionPath).doc(notificationId).delete();
  }
}
