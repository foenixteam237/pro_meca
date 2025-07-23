class Company {
  final String id;
  final String name;
  final String email;
  Company({required this.name, required this.email, required this.id});
  factory Company.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null && json['email'] == null) {
      return switch (json) {
        {'name': String name} => Company(name: name, email: '', id: ''),
        _ => throw Exception('Invalid JSON format for Company'),
      };
    } else {
      return switch (json) {
        {'name': String name, 'email': String email, 'id': String id} =>
          Company(name: name, email: email, id: id),
        _ => throw Exception('Invalid JSON format for Company'),
      };
    }
  }
  Map<String, dynamic> toJson() {
    return {"name": name, "email": email, "id": id};
  }
}
