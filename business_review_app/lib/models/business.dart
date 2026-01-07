/// Business model representing a business entity
class Business {
  final String id;
  final String name;
  final String type;
  final String? description;
  final String? imageUrl;
  
  Business({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    this.imageUrl,
  });
  
  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'image_url': imageUrl,
    };
  }
}

