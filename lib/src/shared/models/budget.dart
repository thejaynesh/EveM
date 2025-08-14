class Budget {
  final String id;
  final String eventId;
  final double totalBudget;
  final double totalSpent;

  Budget({
    required this.id,
    required this.eventId,
    required this.totalBudget,
    required this.totalSpent,
  });

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'totalBudget': totalBudget,
      'totalSpent': totalSpent,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map, String id) {
    return Budget(
      id: id,
      eventId: map['eventId'] ?? '',
      totalBudget: (map['totalBudget'] ?? 0.0).toDouble(),
      totalSpent: (map['totalSpent'] ?? 0.0).toDouble(),
    );
  }

  Budget copyWith({
    String? id,
    String? eventId,
    double? totalBudget,
    double? totalSpent,
  }) {
    return Budget(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      totalBudget: totalBudget ?? this.totalBudget,
      totalSpent: totalSpent ?? this.totalSpent,
    );
  }
}
