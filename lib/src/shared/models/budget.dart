import 'package:cloud_firestore/cloud_firestore.dart';

class Budget {
  final double totalBudget;
  final List<Expense> expenses;
  double get totalSpent => expenses.fold(0, (currentSum, item) => currentSum + item.amount);
  double get budgetLeft => totalBudget - totalSpent;
  bool get isOverBudget => totalSpent > totalBudget;
  double get percentageSpent => totalBudget > 0 ? (totalSpent / totalBudget).clamp(0, 1) : 0;

  Budget({required this.totalBudget, this.expenses = const []});

  factory Budget.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    var expensesData = data['expenses'] as List<dynamic>?;
    List<Expense> expensesList = expensesData != null
        ? expensesData.map((e) => Expense.fromMap(e)).toList()
                : [];
    return Budget(
      totalBudget: (data['totalBudget'] as num).toDouble(),
      expenses: expensesList,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'totalBudget': totalBudget,
      'expenses': expenses.map((e) => e.toMap()).toList(),
    };
  }
}

class Expense {
  final String description;
  final double amount;
  final DateTime date;

  Expense({required this.description, required this.amount, required this.date});

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      description: map['description'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'amount': amount,
      'date': Timestamp.fromDate(date),
    };
  }
}
