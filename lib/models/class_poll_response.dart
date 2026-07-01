class ClassPollResponse {
  final String? id;
  final String? submittedBy;
  final String name;
  final double weight;
  final double height;
  final String shirtSize;
  final double shoeSize;
  final String bloodType;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ClassPollResponse({
    this.id,
    this.submittedBy,
    required this.name,
    required this.weight,
    required this.height,
    required this.shirtSize,
    required this.shoeSize,
    required this.bloodType,
    this.createdAt,
    this.updatedAt,
  });

  ClassPollResponse copyWith({
    String? id,
    String? submittedBy,
    String? name,
    double? weight,
    double? height,
    String? shirtSize,
    double? shoeSize,
    String? bloodType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClassPollResponse(
      id: id ?? this.id,
      submittedBy: submittedBy ?? this.submittedBy,
      name: name ?? this.name,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      shirtSize: shirtSize ?? this.shirtSize,
      shoeSize: shoeSize ?? this.shoeSize,
      bloodType: bloodType ?? this.bloodType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ClassPollResponse.fromSupabase(Map<String, dynamic> row) {
    return ClassPollResponse(
      id: row['id']?.toString(),
      submittedBy: row['submitted_by']?.toString(),
      name: row['respondent_name']?.toString() ?? '',
      weight: (row['weight_kg'] as num).toDouble(),
      height: (row['height_cm'] as num).toDouble(),
      shirtSize: row['shirt_size']?.toString() ?? 'M',
      shoeSize: (row['shoe_size'] as num).toDouble(),
      bloodType: row['blood_type']?.toString() ?? 'O',
      createdAt: DateTime.tryParse(row['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(row['updated_at']?.toString() ?? ''),
    );
  }

  Map<String, Object> toSupabase() {
    return {
      'respondent_name': name.trim(),
      'weight_kg': weight,
      'height_cm': height,
      'shirt_size': shirtSize,
      'shoe_size': shoeSize,
      'blood_type': bloodType,
    };
  }
}
