class Doctor {
  final String id;
  final String name;
  final String specialization;
  final String email;
  final double fees;
  final double rating;
  final int reviewCount;
  final String? imageUrl;

  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.email,
    required this.fees,
    required this.rating,
    required this.reviewCount,
    this.imageUrl,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      specialization: json['specialization'] ?? '',
      email: json['email'] ?? '',
      fees: (json['fees'] ?? 0.0).toDouble(),
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialization': specialization,
      'email': email,
      'fees': fees,
      'rating': rating,
      'reviewCount': reviewCount,
      'imageUrl': imageUrl,
    };
  }

  @override
  String toString() {
    return 'Doctor(id: $id, name: $name, specialization: $specialization, email: $email, fees: $fees, rating: $rating, reviewCount: $reviewCount)';
  }
}
