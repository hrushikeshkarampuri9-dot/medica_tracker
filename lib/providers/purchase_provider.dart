import 'package:flutter/foundation.dart';
import '../models/purchase_model.dart';
import '../models/customer_model.dart';
import '../models/medicine_model.dart';
import '../database/database_helper.dart';
import '../utils/date_helper.dart';

class PurchaseProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Purchase> _purchases = [];
  List<Purchase> _purchasesDueToday = [];
  List<Purchase> _purchasesDueThisWeek = [];
  List<Purchase> _pendingReminders = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Purchase> get purchases => _purchases;
  List<Purchase> get purchasesDueToday => _purchasesDueToday;
  List<Purchase> get purchasesDueThisWeek => _purchasesDueThisWeek;
  List<Purchase> get pendingReminders => _pendingReminders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalPurchases => _purchases.length;
  int get totalPendingReminders => _pendingReminders.length;

  /// Initialize provider and load data
  Future<void> initialize() async {
    await loadPurchases();
  }

  /// Load all purchases
  Future<void> loadPurchases() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _purchases = await _dbHelper.getAllPurchases();
      await _filterPurchases();

      _isLoading = false;
      notifyListeners();

      print('✅ Loaded ${_purchases.length} purchases');
    } catch (e) {
      _error = 'Error loading purchases: $e';
      _isLoading = false;
      print('❌ $_error');
      notifyListeners();
    }
  }

  /// Filter purchases into categories
  Future<void> _filterPurchases() async {
    try {
      _purchasesDueToday = await _dbHelper.getPurchasesDueToday();
      _purchasesDueThisWeek = await _dbHelper.getPurchasesDueThisWeek();
      _pendingReminders = await _dbHelper.getPurchasesPendingReminders();
    } catch (e) {
      print('❌ Error filtering purchases: $e');
    }
  }

  /// Add new purchase
  Future<bool> addPurchase(
      Customer customer,
      Medicine medicine,
      int durationDays,
      String dosageFrequency,
      DateTime purchaseDate, {
        double? quantity,
        double? price,
        String? notes,
      }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Calculate finish date
      final finishDate = DateHelper.calculateFinishDate(
        purchaseDate,
        durationDays,
      );

      // Create purchase object
      final purchase = Purchase(
        customerId: customer.id!,
        medicineId: medicine.id!,
        customerName: customer.name,
        medicineName: medicine.name,
        medicineType: medicine.type,
        purchaseDate: purchaseDate,
        durationDays: durationDays,
        dosageFrequency: dosageFrequency,
        finishDate: finishDate,
        quantity: quantity,
        price: price,
        notes: notes,
        createdAt: DateTime.now(),
      );

      // Validate
      final validationError = purchase.validate();
      if (validationError != null) {
        _error = validationError;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Add to database
      final id = await _dbHelper.addPurchase(purchase);
      final newPurchase = purchase.copyWith(id: id as int?);

      _purchases.add(newPurchase);
      await _filterPurchases();

      _isLoading = false;
      _error = null;
      notifyListeners();

      print('✅ Purchase added: ${medicine.name} for ${customer.name}');
      return true;
    } catch (e) {
      _error = 'Error adding purchase: $e';
      _isLoading = false;
      print('❌ $_error');
      notifyListeners();
      return false;
    }
  }

  /// Get purchases for customer
  Future<List<Purchase>> getPurchasesByCustomer(int customerId) async {
    try {
      return await _dbHelper.getPurchasesByCustomerId(customerId);
    } catch (e) {
      print('❌ Error getting customer purchases: $e');
      return [];
    }
  }

  /// Update purchase
  Future<bool> updatePurchase(Purchase purchase) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Validate
      final validationError = purchase.validate();
      if (validationError != null) {
        _error = validationError;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await _dbHelper.updatePurchase(purchase);

      final index = _purchases.indexWhere((p) => p.id == purchase.id);
      if (index != -1) {
        _purchases[index] = purchase;
      }

      await _filterPurchases();

      _isLoading = false;
      _error = null;
      notifyListeners();

      print('✅ Purchase updated');
      return true;
    } catch (e) {
      _error = 'Error updating purchase: $e';
      _isLoading = false;
      print('❌ $_error');
      notifyListeners();
      return false;
    }
  }

  /// Delete purchase
  Future<bool> deletePurchase(int purchaseId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _dbHelper.deletePurchase(purchaseId);

      _purchases.removeWhere((p) => p.id == purchaseId);
      await _filterPurchases();

      _isLoading = false;
      _error = null;
      notifyListeners();

      print('✅ Purchase deleted');
      return true;
    } catch (e) {
      _error = 'Error deleting purchase: $e';
      _isLoading = false;
      print('❌ $_error');
      notifyListeners();
      return false;
    }
  }

  /// Mark reminder as sent
  Future<bool> markReminderAsSent(int purchaseId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _dbHelper.markReminderAsSent(purchaseId);

      final index = _purchases.indexWhere((p) => p.id == purchaseId);
      if (index != -1) {
        _purchases[index] = _purchases[index].markReminderAsSent();
      }

      await _filterPurchases();

      _isLoading = false;
      _error = null;
      notifyListeners();

      print('✅ Reminder marked as sent');
      return true;
    } catch (e) {
      _error = 'Error marking reminder as sent: $e';
      _isLoading = false;
      print('❌ $_error');
      notifyListeners();
      return false;
    }
  }

  /// Get dashboard summary
  Future<Map<String, dynamic>> getDashboardSummary() async {
    try {
      final totalCount = await _dbHelper.getTotalPurchaseCount();
      final pendingCount = await _dbHelper.getPendingRemindersCount();
      final todayCount = _purchasesDueToday.length;
      final weekCount = _purchasesDueThisWeek.length;

      return {
        'totalPurchases': totalCount,
        'pendingReminders': pendingCount,
        'dueToday': todayCount,
        'dueThisWeek': weekCount,
      };
    } catch (e) {
      print('❌ Error getting dashboard summary: $e');
      return {
        'totalPurchases': 0,
        'pendingReminders': 0,
        'dueToday': 0,
        'dueThisWeek': 0,
      };
    }
  }

  /// Refresh purchases
  Future<void> refreshPurchases() async {
    await loadPurchases();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Get purchase statistics
  Map<String, dynamic> getPurchaseStatistics() {
    int overdue = 0;
    int thisWeek = 0;
    int nextWeek = 0;
    int future = 0;

    final now = DateTime.now();

    for (final purchase in _purchases) {
      final daysLeft = purchase.getDaysRemaining();

      if (daysLeft < 0) {
        overdue++;
      } else if (daysLeft <= 7) {
        thisWeek++;
      } else if (daysLeft <= 14) {
        nextWeek++;
      } else {
        future++;
      }
    }

    return {
      'overdue': overdue,
      'thisWeek': thisWeek,
      'nextWeek': nextWeek,
      'future': future,
    };
  }

  /// Export purchases to JSON
  List<Map<String, dynamic>> exportToJSON() {
    return _purchases.map((p) => p.toJson()).toList();
  }
  /// Add multiple purchases at once (for bulk entry)
  Future<bool> addBulkPurchases(List<Purchase> purchasesList) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Validate all purchases first
      for (final purchase in purchasesList) {
        final validationError = purchase.validate();
        if (validationError != null) {
          _error = 'Validation failed: $validationError';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      // Add all purchases to database
      for (final purchase in purchasesList) {
        final id = await _dbHelper.addPurchase(purchase);
        final newPurchase = purchase.copyWith(id: id as int?);
        _purchases.add(newPurchase);
      }

      await _filterPurchases();
      _isLoading = false;
      _error = null;
      notifyListeners();

      print('✅ ${purchasesList.length} purchases added successfully');
      return true;
    } catch (e) {
      _error = 'Error adding bulk purchases: $e';
      _isLoading = false;
      print('❌ $_error');
      notifyListeners();
      return false;
    }
  }


  /// Clear all data (for testing)
  Future<void> clearAllData() async {
    try {
      _purchases.clear();
      _purchasesDueToday.clear();
      _purchasesDueThisWeek.clear();
      _pendingReminders.clear();
      notifyListeners();
      print('✅ All purchase data cleared');
    } catch (e) {
      print('❌ Error clearing data: $e');
    }
  }
}
