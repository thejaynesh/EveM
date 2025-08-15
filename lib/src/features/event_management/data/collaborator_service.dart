import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/models/collaborator.dart';

class CollaboratorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Collaborator>> getCollaboratorsForEvent(String eventId) {
    return _firestore
        .collection('collaborators')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return Collaborator.fromMap(data, doc.id);
          }).toList();
        });
  }

  Future<void> addCollaborator(Collaborator collaborator) async {
    await _firestore.collection('collaborators').add(collaborator.toMap());
  }

  Future<void> updateCollaborator(Collaborator collaborator) async {
    await _firestore
        .collection('collaborators')
        .doc(collaborator.id)
        .update(collaborator.toMap());
  }

  Future<void> deleteCollaborator(String collaboratorId) async {
    await _firestore.collection('collaborators').doc(collaboratorId).delete();
  }
}
