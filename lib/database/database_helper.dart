import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/customer_model.dart';
import '../models/medicine_model.dart';
import '../models/purchase_model.dart';
import 'tables.dart';

class DatabaseHelper {
  // Singleton pattern
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'medical_tracker.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  /// Create tables on first run
  Future<void> _onCreate(Database db, int version) async {
    final queries = TableSchemas.getAllTableCreationQueries();
    for (final query in queries) {
      await db.execute(query);
    }
  }

  // ============ CUSTOMER OPERATIONS ============

  /// Add new customer
  Future<int> addCustomer(Customer customer) async {
    try {
      final db = await database;
      return await db.insert(
        Tables.customers,
        customer.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Error adding customer: $e');
    }
  }

  /// Get all customers
  Future<List<Customer>> getAllCustomers() async {
    try {
      final db = await database;
      final result = await db.query(
        Tables.customers,
        orderBy: 'name ASC',
      );
      return result.map((json) => Customer.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error fetching customers: $e');
    }
  }

  /// Get customer by ID
  Future<Customer?> getCustomerById(int id) async {
    try {
      final db = await database;
      final result = await db.query(
        Tables.customers,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (result.isEmpty) return null;
      return Customer.fromJson(result.first);
    } catch (e) {
      throw Exception('Error fetching customer: $e');
    }
  }

  /// Search customers by name or phone
  Future<List<Customer>> searchCustomers(String query) async {
    try {
      final db = await database;
      final result = await db.query(
        Tables.customers,
        where: 'name LIKE ? OR phoneNumber LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'name ASC',
      );
      return result.map((json) => Customer.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error searching customers: $e');
    }
  }

  /// Update customer
  Future<int> updateCustomer(Customer customer) async {
    try {
      final db = await database;
      return await db.update(
        Tables.customers,
        customer.copyWith(updatedAt: DateTime.now()).toJson(),
        where: 'id = ?',
        whereArgs: [customer.id],
      );
    } catch (e) {
      throw Exception('Error updating customer: $e');
    }
  }



  /// Delete customer
  Future<int> deleteCustomer(int id) async {
    try {
      final db = await database;
      return await db.delete(
        Tables.customers,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Error deleting customer: $e');
    }
  }

  /// Get total customer count
  Future<int> getTotalCustomerCount() async {
    try {
      final db = await database;
      final result = await db.rawQuery('SELECT COUNT(*) FROM ${Tables.customers}');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw Exception('Error getting customer count: $e');
    }
  }

  // ============ MEDICINE OPERATIONS ============

  /// Add new medicine
  Future<int> addMedicine(Medicine medicine) async {
    try {
      final db = await database;
      return await db.insert(
        Tables.medicines,
        medicine.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Error adding medicine: $e');
    }
  }

  /// Get all medicines
  Future<List<Medicine>> getAllMedicines() async {
    try {
      final db = await database;
      final result = await db.query(
        Tables.medicines,
        orderBy: 'name ASC',
      );
      return result.map((json) => Medicine.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error fetching medicines: $e');
    }
  }

  /// Get medicines by type
  Future<List<Medicine>> getMedicinesByType(String type) async {
    try {
      final db = await database;
      final result = await db.query(
        Tables.medicines,
        where: 'type = ?',
        whereArgs: [type],
        orderBy: 'name ASC',
      );
      return result.map((json) => Medicine.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error fetching medicines by type: $e');
    }
  }

  /// Get medicine by ID
  Future<Medicine?> getMedicineById(int id) async {
    try {
      final db = await database;
      final result = await db.query(
        Tables.medicines,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (result.isEmpty) return null;
      return Medicine.fromJson(result.first);
    } catch (e) {
      throw Exception('Error fetching medicine: $e');
    }
  }

  /// Search medicines
  Future<List<Medicine>> searchMedicines(String query) async {
    try {
      final db = await database;
      final result = await db.query(
        Tables.medicines,
        where: 'name LIKE ? OR type LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'name ASC',
      );
      return result.map((json) => Medicine.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error searching medicines: $e');
    }
  }

  /// Update medicine
  Future<int> updateMedicine(Medicine medicine) async {
    try {
      final db = await database;
      return await db.update(
        Tables.medicines,
        medicine.copyWith(updatedAt: DateTime.now()).toJson(),
        where: 'id = ?',
        whereArgs: [medicine.id],
      );
    } catch (e) {
      throw Exception('Error updating medicine: $e');
    }
  }

  /// Delete medicine
  Future<int> deleteMedicine(int id) async {
    try {
      final db = await database;
      return await db.delete(
        Tables.medicines,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Error deleting medicine: $e');
    }
  }

  /// Get total medicine count
  Future<int> getTotalMedicineCount() async {
    try {
      final db = await database;
      final result = await db.rawQuery('SELECT COUNT(*) FROM ${Tables.medicines}');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw Exception('Error getting medicine count: $e');
    }
  }

  // ============ PURCHASE OPERATIONS ============

  /// Add new purchase
  Future<int> addPurchase(Purchase purchase) async {
    try {
      final db = await database;
      return await db.insert(
        Tables.purchases,
        purchase.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Error adding purchase: $e');
    }
  }

  /// Get all purchases
  Future<List<Purchase>> getAllPurchases() async {
    try {
      final db = await database;
      final result = await db.query(
        Tables.purchases,
        orderBy: 'finishDate ASC',
      );
      return result.map((json) => Purchase.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error fetching purchases: $e');
    }
  }

  /// Get purchases by customer ID
  Future<List<Purchase>> getPurchasesByCustomerId(int customerId) async {
    try {
      final db = await database;
      final result = await db.query(
        Tables.purchases,
        where: 'customerId = ?',
        whereArgs: [customerId],
        orderBy: 'finishDate ASC',
      );
      return result.map((json) => Purchase.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error fetching purchases: $e');
    }
  }

  /// Get purchase by ID
  Future<Purchase?> getPurchaseById(int id) async {
    try {
      final db = await database;
      final result = await db.query(
        Tables.purchases,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (result.isEmpty) return null;
      return Purchase.fromJson(result.first);
    } catch (e) {
      throw Exception('Error fetching purchase: $e');
    }
  }

  /// Get purchases due today
  Future<List<Purchase>> getPurchasesDueToday() async {
    try {
      final db = await database;
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));

      final result = await db.query(
        Tables.purchases,
        where: 'finishDate <= ? AND finishDate > ? AND reminderSent = 0',
        whereArgs: [now.toIso8601String(), sevenDaysAgo.toIso8601String()],
        orderBy: 'finishDate ASC',
      );
      return result.map((json) => Purchase.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error fetching purchases due today: $e');
    }
  }

  /// Get purchases due this week
  Future<List<Purchase>> getPurchasesDueThisWeek() async {
    try {
      final db = await database;
      final now = DateTime.now();
      final weekFromNow = now.add(const Duration(days: 7));

      final result = await db.query(
        Tables.purchases,
        where: 'finishDate >= ? AND finishDate <= ? AND reminderSent = 0',
        whereArgs: [now.toIso8601String(), weekFromNow.toIso8601String()],
        orderBy: 'finishDate ASC',
      );
      return result.map((json) => Purchase.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error fetching purchases due this week: $e');
    }
  }

  /// Get purchases pending reminders (3 days before finish)
  Future<List<Purchase>> getPurchasesPendingReminders() async {
    try {
      final db = await database;
      final now = DateTime.now();
      final threeDaysFromNow = now.add(const Duration(days: 3));

      final result = await db.query(
        Tables.purchases,
        where: 'finishDate >= ? AND finishDate <= ? AND reminderSent = 0',
        whereArgs: [now.toIso8601String(), threeDaysFromNow.toIso8601String()],
        orderBy: 'finishDate ASC',
      );
      return result.map((json) => Purchase.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error fetching pending reminders: $e');
    }
  }

  /// Update purchase
  Future<int> updatePurchase(Purchase purchase) async {
    try {
      final db = await database;
      return await db.update(
        Tables.purchases,
        purchase.copyWith(updatedAt: DateTime.now()).toJson(),
        where: 'id = ?',
        whereArgs: [purchase.id],
      );
    } catch (e) {
      throw Exception('Error updating purchase: $e');
    }
  }

  /// Mark reminder as sent
  Future<int> markReminderAsSent(int purchaseId) async {
    try {
      final db = await database;
      return await db.update(
        Tables.purchases,
        {
          'reminderSent': 1,
          'reminderSentAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [purchaseId],
      );
    } catch (e) {
      throw Exception('Error marking reminder as sent: $e');
    }
  }

  /// Delete purchase
  Future<int> deletePurchase(int id) async {
    try {
      final db = await database;
      return await db.delete(
        Tables.purchases,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Error deleting purchase: $e');
    }
  }

  /// Get total purchase count
  Future<int> getTotalPurchaseCount() async {
    try {
      final db = await database;
      final result = await db.rawQuery('SELECT COUNT(*) FROM ${Tables.purchases}');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw Exception('Error getting purchase count: $e');
    }
  }

  /// Get pending reminders count
  Future<int> getPendingRemindersCount() async {
    try {
      final db = await database;
      final now = DateTime.now();
      final threeDaysFromNow = now.add(const Duration(days: 3));

      final result = await db.rawQuery(
        'SELECT COUNT(*) FROM ${Tables.purchases} '
            'WHERE finishDate >= ? AND finishDate <= ? AND reminderSent = 0',
        [now.toIso8601String(), threeDaysFromNow.toIso8601String()],
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw Exception('Error getting pending reminders count: $e');
    }
  }

  /// Clear all data (for testing)
  Future<void> clearAllData() async {
    try {
      final db = await database;
      await db.delete(Tables.purchases);
      await db.delete(Tables.medicines);
      await db.delete(Tables.customers);
    } catch (e) {
      throw Exception('Error clearing data: $e');
    }
  }

  /// Close database
  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
