import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/models/budget.dart';

class BudgetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<Budget?> getBudgetStream(String eventId) {
    return _firestore.collection('events').doc(eventId).collection('budget').doc('summary').snapshots().map((snapshot) {
      if (snapshot.exists) {
        return Budget.fromFirestore(snapshot);
      }
      return null;
    });
  }

  Future<void> setBudget(String eventId, double totalBudget) async {
    final budgetRef = _firestore.collection('events').doc(eventId).collection('budget').doc('summary');
    
    // Use set with merge: true to create or update the document
    return await budgetRef.set({
      'totalBudget': totalBudget,
    }, SetOptions(merge: true));
  }

  Future<void> addExpense(String eventId, Expense newExpense) async {
    final budgetRef = _firestore.collection('events').doc(eventId).collection('budget').doc('summary');
    
    return await budgetRef.update({
      'expenses': FieldValue.arrayUnion([newExpense.toMap()])
    });
  }

  Future<void> removeExpense(String eventId, Expense expenseToRemove) async {
    final budgetRef = _firestore.collection('events').doc(eventId).collection('budget').doc('summary');

    return await budgetRef.update({
      'expenses': FieldValue.arrayRemove([expenseToRemove.toMap()])
    });
  }

  Future<void> updateExpense(String eventId, Expense updatedExpense, int expenseIndex) async {
    final budgetDoc = await _firestore.collection('events').doc(eventId).collection('budget').doc('summary').get();
    if (budgetDoc.exists) {
      var budget = Budget.fromFirestore(budgetDoc);
      if (expenseIndex >= 0 && expenseIndex < budget.expenses.length) {
        budget.expenses[expenseIndex] = updatedExpense;
        await _firestore.collection('events').doc(eventId).collection('budget').doc('summary').update({
          'expenses': budget.expenses.map((e) => e.toMap()).toList(),
        });
      }
    }
  }

  Future<void> deleteExpense(String eventId, int expenseIndex) async {
    final budgetDoc = await _firestore.collection('events').doc(eventId).collection('budget').doc('summary').get();
    if (budgetDoc.exists) {
      var budget = Budget.fromFirestore(budgetDoc);
      if (expenseIndex >= 0 && expenseIndex < budget.expenses.length) {
        budget.expenses.removeAt(expenseIndex);
        await _firestore.collection('events').doc(eventId).collection('budget').doc('summary').update({
          'expenses': budget.expenses.map((e) => e.toMap()).toList(),
        });
      }
    }
  }
}
