
class Collaborator {
  final String id;
  final String eventId;
  final String userId;
  final String email;
  final String role;

  Collaborator({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.email,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'userId': userId,
      'email': email,
      'role': role,
    };
  }

  factory Collaborator.fromMap(Map<String, dynamic> map, String id) {
    return Collaborator(
      id: id,
      eventId: map['eventId'] ?? '',
      userId: map['userId'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
    );
  }

  Collaborator copyWith({
    String? id,
    String? eventId,
    String? userId,
    String? email,
    String? role,
  }) {
    return Collaborator(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }
}
