/// Model for a catching environment (where the snake was caught)
class CatchingEnvironment {
  final String id;
  final String name;
  final String? description;

  const CatchingEnvironment({
    required this.id,
    required this.name,
    this.description,
  });

  factory CatchingEnvironment.fromJson(Map<String, dynamic> json) {
    return CatchingEnvironment(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
    );
  }
}
