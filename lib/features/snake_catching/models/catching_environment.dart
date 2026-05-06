/// Model for a catching environment (where the snake was caught)
class CatchingEnvironment {
  final String id;
  final String name;
  final String? description;
  final double? price;
  final String? currency;

  const CatchingEnvironment({
    required this.id,
    required this.name,
    this.description,
    this.price,
    this.currency,
  });

  factory CatchingEnvironment.fromJson(Map<String, dynamic> json) {
    return CatchingEnvironment(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      price: json['price'] != null
          ? double.tryParse(json['price'].toString())
          : null,
      currency: json['currency']?.toString(),
    );
  }
}
