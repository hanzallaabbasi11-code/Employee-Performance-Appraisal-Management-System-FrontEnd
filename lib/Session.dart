class Session {
  final int id;
  final String name;

  Session({required this.id, required this.name});

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'],
      name: json['name'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Session && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
