import 'medicine_model.dart';

/// Temporary model for holding medicine details before creating Purchase
class MedicineItem {
  final Medicine medicine;
  final int durationDays;
  final String dosageFrequency;
  final double? quantity;
  final double? price;
  final String? notes;

  MedicineItem({
    required this.medicine,
    required this.durationDays,
    required this.dosageFrequency,
    this.quantity,
    this.price,
    this.notes,
  });

  /// Validate medicine item
  String? validate() {
    if (durationDays < 10 || durationDays > 90) {
      return 'Duration must be between 10 and 90 days';
    }
    if (dosageFrequency.isEmpty) {
      return 'Dosage frequency is required';
    }
    if (quantity != null && quantity! <= 0) {
      return 'Quantity must be greater than 0';
    }
    if (price != null && price! < 0) {
      return 'Price cannot be negative';
    }
    return null;
  }

  /// Create a copy with modified fields
  MedicineItem copyWith({
    Medicine? medicine,
    int? durationDays,
    String? dosageFrequency,
    double? quantity,
    double? price,
    String? notes,
  }) {
    return MedicineItem(
      medicine: medicine ?? this.medicine,
      durationDays: durationDays ?? this.durationDays,
      dosageFrequency: dosageFrequency ?? this.dosageFrequency,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'MedicineItem(medicine: ${medicine.name}, duration: $durationDays days)';
  }
}
