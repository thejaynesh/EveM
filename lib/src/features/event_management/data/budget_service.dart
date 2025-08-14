import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/models/budget.dart';

class BudgetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<Budget?> getBudgetForEvent(String eventId) {
    return _firestore
        .collection('budgets')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return Budget.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
      } else {
        return null;
      }
    });
  }

  Future<void> setBudget(Budget budget) async {
    await _firestore.collection('budgets').doc(budget.id).update(budget.toMap());
    }
}
