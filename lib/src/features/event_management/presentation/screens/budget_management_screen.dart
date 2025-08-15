import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../shared/models/budget.dart';
import '../../data/budget_service.dart';

class BudgetManagementScreen extends StatefulWidget {
  final String eventId;

  const BudgetManagementScreen({super.key, required this.eventId});

  @override
  State<BudgetManagementScreen> createState() => _BudgetManagementScreenState();
}

class _BudgetManagementScreenState extends State<BudgetManagementScreen> {
  late final BudgetService _budgetService;
  final _formKey = GlobalKey<FormState>();
  final _budgetController = TextEditingController();

  // Controllers for adding a new expense
  final _expenseDescriptionController = TextEditingController();
  final _expenseAmountController = TextEditingController();
  final _expenseFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _budgetService = Provider.of<BudgetService>(context, listen: false);
  }

  @override
  void dispose() {
    _budgetController.dispose();
    _expenseDescriptionController.dispose();
    _expenseAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Management'),
      ),
      body: StreamBuilder<Budget?>(
        stream: _budgetService.getBudgetStream(widget.eventId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final budget = snapshot.data;

          if (budget == null) {
            return _buildSetBudgetPrompt();
          }

          return _buildBudgetDetails(budget);
        },
      ),
      floatingActionButton: StreamBuilder<Budget?>(
        stream: _budgetService.getBudgetStream(widget.eventId),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return FloatingActionButton(
              onPressed: () => _showAddExpenseDialog(snapshot.data!),
              tooltip: 'Add Expense',
              child: const Icon(Icons.add),
            );
          }
          return const SizedBox.shrink(); // Hide FAB if no budget is set
        },
      ),
    );
  }

  Widget _buildSetBudgetPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'No budget set for this event yet.',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _showSetBudgetDialog(null),
            child: const Text('Set Event Budget'),
          ),
        ],
      ),
    );
  }

  void _showSetBudgetDialog(Budget? budget) {
    _budgetController.text = budget?.totalBudget.toString() ?? '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(budget == null ? 'Set Budget' : 'Update Budget'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: _budgetController,
              decoration: const InputDecoration(
                labelText: 'Total Budget',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a budget';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                if (double.parse(value) <= 0) {
                  return 'Budget must be greater than zero';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final totalBudget = double.parse(_budgetController.text);
                  _budgetService.setBudget(widget.eventId, totalBudget);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showAddExpenseDialog(Budget budget) {
    _expenseDescriptionController.clear();
    _expenseAmountController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Expense'),
          content: Form(
            key: _expenseFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _expenseDescriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    icon: Icon(Icons.description),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _expenseAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    icon: Icon(Icons.attach_money),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    if (double.parse(value) <= 0) {
                      return 'Amount must be greater than zero';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_expenseFormKey.currentState!.validate()) {
                  final newExpense = Expense(
                    description: _expenseDescriptionController.text,
                    amount: double.parse(_expenseAmountController.text),
                    date: DateTime.now(),
                  );
                  _budgetService.addExpense(widget.eventId, newExpense);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add Expense'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteExpense(Expense expense) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to remove this expense?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _budgetService.removeExpense(widget.eventId, expense);
                Navigator.of(context).pop();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBudgetDetails(Budget budget) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Budget Summary Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Budget:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(currencyFormat.format(budget.totalBudget), style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Spent:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                        currencyFormat.format(budget.totalSpent),
                        style: TextStyle(
                          color: budget.isOverBudget ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Budget Left:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                        currencyFormat.format(budget.budgetLeft),
                        style: TextStyle(
                          color: budget.budgetLeft < 0 ? Colors.red : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  LinearProgressIndicator(
                    value: budget.percentageSpent,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      budget.isOverBudget ? Colors.red : Colors.blue,
                    ),
                    minHeight: 10,
                  ),
                  const SizedBox(height: 5),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${(budget.percentageSpent * 100).toStringAsFixed(1)}% Spent',
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Update Budget'),
                      onPressed: () => _showSetBudgetDialog(budget),
                    ),
  ),
              ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Expenses List
          const Text(
            'Expenses',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          Expanded(
            child: _buildExpensesList(budget),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesList(Budget budget) {
    if (budget.expenses.isEmpty) {
      return const Center(
        child: Text(
          'No expenses recorded yet.\nClick the "+" button to add one!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    // Sort expenses by date, newest first
    final sortedExpenses = List<Expense>.from(budget.expenses)..sort((a, b) => b.date.compareTo(a.date));

    return ListView.builder(
      itemCount: sortedExpenses.length,
      itemBuilder: (context, index) {
        final expense = sortedExpenses[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            leading: const Icon(Icons.receipt_long, color: Colors.blueAccent),
            title: Text(expense.description, style: const TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text(DateFormat.yMMMd().add_jm().format(expense.date)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  NumberFormat.currency(symbol: '\$').format(expense.amount),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _confirmDeleteExpense(expense),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
