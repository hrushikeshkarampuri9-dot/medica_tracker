class Medicine {
  final int? id;
  final String name;
  final String type; // BP, Sugar, Heart, etc.
  final String? description;
  final String? dosageForm; // Tablet, Syrup, Injection, etc.
  final double? price;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Medicine({
    this.id,
    required this.name,
    required this.type,
    this.description,
    this.dosageForm,
    this.price,
    required this.createdAt,
    this.updatedAt,
  });

  /// Convert Medicine to JSON (for database storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'dosageForm': dosageForm,
      'price': price,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create Medicine from JSON (from database)
  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'] as int?,
      name: json['name'] as String,
      type: json['type'] as String,
      description: json['description'] as String?,
      dosageForm: json['dosageForm'] as String?,
      price: json['price'] as double?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Create a copy with modified fields
  Medicine copyWith({
    int? id,
    String? name,
    String? type,
    String? description,
    String? dosageForm,
    double? price,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      dosageForm: dosageForm ?? this.dosageForm,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Validate medicine data
  String? validate() {
    if (name.isEmpty) return 'Medicine name is required';
    if (name.length < 2) return 'Medicine name must be at least 2 characters';
    if (type.isEmpty) return 'Medicine type is required';
    if (price != null && price! < 0) return 'Price cannot be negative';
    return null;
  }

  /// Check if medicine data is complete
  bool isComplete() {
    return id != null &&
        name.isNotEmpty &&
        type.isNotEmpty &&
        dosageForm != null &&
        price != null;
  }

  /// Get medicine category icon
  String getCategoryIcon() {
    switch (type.toLowerCase()) {
      case 'bp':
        return '❤️'; // Heart for BP
      case 'sugar':
        return '🩺'; // Medical for Sugar
      case 'heart':
        return '💊'; // Pill
      case 'thyroid':
        return '⚕️'; // Doctor
      case 'pain':
        return '💉'; // Injection
      case 'antibiotic':
        return '🧬'; // DNA
      default:
        return '💊'; // Default pill
    }
  }

  /// Get full medicine name with type
  String getFullName() => '$name ($type)';

  /// Get price formatted with rupees
  String getPriceFormatted() {
    if (price == null) return 'N/A';
    return '₹${price!.toStringAsFixed(2)}';
  }

  @override
  String toString() {
    return 'Medicine(id: $id, name: $name, type: $type, price: $price)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Medicine &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              name == other.name &&
              type == other.type;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ type.hashCode;
}
