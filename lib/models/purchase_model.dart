class Purchase {
  final int? id;
  final int customerId;
  final int medicineId;
  final String customerName;
  final String medicineName;
  final String medicineType;
  final DateTime purchaseDate;
  final int durationDays; // 20 or 30 days
  final String dosageFrequency; // Once/Twice/Thrice daily
  final DateTime finishDate; // Auto-calculated
  final double? quantity;
  final double? price;
  final String? notes;
  final bool reminderSent;
  final DateTime? reminderSentAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Purchase({
    this.id,
    required this.customerId,
    required this.medicineId,
    required this.customerName,
    required this.medicineName,
    required this.medicineType,
    required this.purchaseDate,
    required this.durationDays,
    required this.dosageFrequency,
    required this.finishDate,
    this.quantity,
    this.price,
    this.notes,
    this.reminderSent = false,
    this.reminderSentAt,
    required this.createdAt,
    this.updatedAt,
  });

  /// Convert Purchase to JSON (for database storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'medicineId': medicineId,
      'customerName': customerName,
      'medicineName': medicineName,
      'medicineType': medicineType,
      'purchaseDate': purchaseDate.toIso8601String(),
      'durationDays': durationDays,
      'dosageFrequency': dosageFrequency,
      'finishDate': finishDate.toIso8601String(),
      'quantity': quantity,
      'price': price,
      'notes': notes,
      'reminderSent': reminderSent ? 1 : 0,
      'reminderSentAt': reminderSentAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create Purchase from JSON (from database)
  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'] as int?,
      customerId: json['customerId'] as int,
      medicineId: json['medicineId'] as int,
      customerName: json['customerName'] as String,
      medicineName: json['medicineName'] as String,
      medicineType: json['medicineType'] as String,
      purchaseDate: DateTime.parse(json['purchaseDate'] as String),
      durationDays: json['durationDays'] as int,
      dosageFrequency: json['dosageFrequency'] as String,
      finishDate: DateTime.parse(json['finishDate'] as String),
      quantity: json['quantity'] as double?,
      price: json['price'] as double?,
      notes: json['notes'] as String?,
      reminderSent: (json['reminderSent'] as int?) == 1,
      reminderSentAt: json['reminderSentAt'] != null
          ? DateTime.parse(json['reminderSentAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Create a copy with modified fields
  Purchase copyWith({
    int? id,
    int? customerId,
    int? medicineId,
    String? customerName,
    String? medicineName,
    String? medicineType,
    DateTime? purchaseDate,
    int? durationDays,
    String? dosageFrequency,
    DateTime? finishDate,
    double? quantity,
    double? price,
    String? notes,
    bool? reminderSent,
    DateTime? reminderSentAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Purchase(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      medicineId: medicineId ?? this.medicineId,
      customerName: customerName ?? this.customerName,
      medicineName: medicineName ?? this.medicineName,
      medicineType: medicineType ?? this.medicineType,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      durationDays: durationDays ?? this.durationDays,
      dosageFrequency: dosageFrequency ?? this.dosageFrequency,
      finishDate: finishDate ?? this.finishDate,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      notes: notes ?? this.notes,
      reminderSent: reminderSent ?? this.reminderSent,
      reminderSentAt: reminderSentAt ?? this.reminderSentAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Validate purchase data
  String? validate() {
    if (customerId <= 0) return 'Invalid customer';
    if (medicineId <= 0) return 'Invalid medicine';
    if (durationDays < 10 || durationDays > 90) {
      return 'Duration must be between 10 and 90 days';
    }
    if (dosageFrequency.isEmpty) return 'Dosage frequency is required';
    return null;
  }

  /// Calculate days remaining until finish date
  int getDaysRemaining() {
    final now = DateTime.now();
    return finishDate.difference(now).inDays;
  }

  /// Check if reminder should be sent (3 days before finish)
  bool shouldSendReminder() {
    return getDaysRemaining() == 3 && !reminderSent;
  }

  /// Check if medicine is due today
  bool isDueToday() {
    final daysLeft = getDaysRemaining();
    return daysLeft <= 0 && daysLeft > -7;
  }

  /// Check if medicine is due this week
  bool isDueThisWeek() {
    final daysLeft = getDaysRemaining();
    return daysLeft >= 0 && daysLeft <= 7;
  }

  /// Get reminder status badge
  String getReminderStatus() {
    final daysLeft = getDaysRemaining();
    if (daysLeft < 0) return 'Overdue';
    if (daysLeft <= 3) return 'Urgent';
    if (daysLeft <= 7) return 'Due Soon';
    return 'Active';
  }

  /// Get reminder status color (as hex string)
  String getReminderStatusColor() {
    final daysLeft = getDaysRemaining();
    if (daysLeft < 0) return 'FF0000'; // Red
    if (daysLeft <= 3) return 'FF9800'; // Orange
    if (daysLeft <= 7) return 'FFC107'; // Amber
    return '4CAF50'; // Green
  }

  /// Get display text for days remaining
  String getDaysRemainingText() {
    final days = getDaysRemaining();
    if (days < 0) return 'Overdue by ${(-days)} days';
    if (days == 0) return 'Due today';
    if (days == 1) return 'Due tomorrow';
    return 'Due in $days days';
  }

  /// Mark reminder as sent
  Purchase markReminderAsSent() {
    return copyWith(
      reminderSent: true,
      reminderSentAt: DateTime.now(),
    );
  }

  /// Get full purchase summary
  String getSummary() {
    return '$customerName - $medicineName ($medicineType)\n'
        'Duration: $durationDays days | Frequency: $dosageFrequency\n'
        'Due: ${getDaysRemainingText()}';
  }

  @override
  String toString() {
    return 'Purchase(id: $id, customer: $customerName, medicine: $medicineName, '
        'daysRemaining: ${getDaysRemaining()})';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Purchase &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              customerId == other.customerId &&
              medicineId == other.medicineId;

  @override
  int get hashCode =>
      id.hashCode ^ customerId.hashCode ^ medicineId.hashCode;
}
