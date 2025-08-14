import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/models/task.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Task>> getTasksForEvent(String eventId) {
    return _firestore
        .collection('tasks')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Task.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<void> addTask(Task task) async {
    await _firestore.collection('tasks').add(task.toMap());
  }

  Future<void> updateTask(Task task) async {
    await _firestore.collection('tasks').doc(task.id).update(task.toMap());
  }

  Future<void> deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
  }
}
