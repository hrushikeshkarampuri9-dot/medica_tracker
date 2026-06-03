class Customer {
  final int? id;
  final String name;
  final String phoneNumber;
  final String? address;
  final int? age;
  final String? gender;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Customer({
    this.id,
    required this.name,
    required this.phoneNumber,
    this.address,
    this.age,
    this.gender,
    required this.createdAt,
    this.updatedAt,
  });

  /// Convert Customer to JSON (for database storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'address': address,
      'age': age,
      'gender': gender,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create Customer from JSON (from database)
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as int?,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      address: json['address'] as String?,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Create a copy with modified fields
  Customer copyWith({
    int? id,
    String? name,
    String? phoneNumber,
    String? address,
    int? age,
    String? gender,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Validate customer data
  String? validate() {
    if (name.isEmpty) return 'Customer name is required';
    if (name.length < 2) return 'Customer name must be at least 2 characters';
    if (phoneNumber.isEmpty) return 'Phone number is required';
    if (phoneNumber.length != 10) return 'Phone number must be 10 digits';
    if (!RegExp(r'^[0-9]{10}$').hasMatch(phoneNumber)) {
      return 'Phone number must contain only digits';
    }
    if (age != null && (age! < 1 || age! > 120)) {
      return 'Age must be between 1 and 120';
    }
    return null;
  }

  /// Check if customer data is complete
  bool isComplete() {
    return id != null &&
        name.isNotEmpty &&
        phoneNumber.isNotEmpty &&
        address != null &&
        age != null &&
        gender != null;
  }

  /// Get display name with phone
  String getDisplayName() => '$name (${phoneNumber.substring(phoneNumber.length - 4)})';

  /// Get initials for avatar - FIXED VERSION
  String getInitials() {
    // Handle empty or whitespace-only names
    if (name.isEmpty || name.trim().isEmpty) {
      return '??';
    }

    // Split and filter out empty strings
    final names = name.trim().split(' ').where((n) => n.isNotEmpty).toList();

    // Handle no valid names after filtering
    if (names.isEmpty) {
      return '??';
    }

    // Two or more names: first initial + last initial
    if (names.length >= 2) {
      return (names.first[0] + names.last[0]).toUpperCase();
    }

    // Single name: take first 1 or 2 characters
    final singleName = names[0];
    if (singleName.length == 1) {
      return singleName[0].toUpperCase();
    }

    return singleName.substring(0, 2).toUpperCase();
  }

  @override
  String toString() {
    return 'Customer(id: $id, name: $name, phone: $phoneNumber, age: $age, gender: $gender)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Customer &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              name == other.name &&
              phoneNumber == other.phoneNumber;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ phoneNumber.hashCode;
}
