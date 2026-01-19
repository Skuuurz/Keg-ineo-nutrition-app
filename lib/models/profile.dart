class Profile {
  final String id;
  final String name;
  final String description;

  const Profile({
    required this.id,
    required this.name,
    required this.description,
  });

  Profile copyWith({String? name, String? description}) => Profile(
    id: id,
    name: name ?? this.name,
    description: description ?? this.description,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
  };

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    id: json['id'] as String,
    name: json['name'] as String? ?? '',
    description: json['description'] as String? ?? '',
  );
}
