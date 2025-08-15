class Collaborator {
  final String id;
  final String name;
  final String role;

  Collaborator({
    required this.id,
    required this.name,
    required this.role,
  });

  Collaborator copyWith({
    String? id,
    String? name,
    String? role,
  }) {
    return Collaborator(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
    );
  }

  factory Collaborator.fromMap(Map<String, dynamic> map, String id) {
    return Collaborator(
      id: id,
      name: map['name'],
      role: map['role'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'role': role,
    };
  }
}
