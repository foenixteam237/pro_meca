class Role {
  final int id;
  final String name;
  final String companyId;
  Role({required this.id, required this.name, required this.companyId});
  factory Role.fromJson(Map<String, dynamic> json) {

    return switch (json) {
      {'id': int id, 'name': String name, 'companyId': String companyId} =>
        Role(id: id, name: name, companyId: companyId),
      _ => throw Exception('Invalid JSON format for Role'),
    };
  }
  factory Role.fromRoleJson(Map<String, dynamic> json){
    return switch (json) {
      {'id': int id, 'name': String name} =>
          Role(id: id, name: name, companyId: ""),
      _ => throw Exception('Invalid JSON format for Role'),
    };
  }
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'companyId': companyId};
  }
  Map<String, dynamic> toRoleJson(String companyId) {
    return {'id': id, 'name': name, 'companyId': companyId};
  }
}
