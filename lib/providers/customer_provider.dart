import 'package:flutter/foundation.dart';
import '../models/customer_model.dart';
import '../database/database_helper.dart';

class CustomerProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Customer> _customers = [];
  List<Customer> _filteredCustomers = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  // Getters
  List<Customer> get customers => _customers;
  List<Customer> get filteredCustomers =>
      _searchQuery.isEmpty ? _customers : _filteredCustomers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  int get totalCustomers => _customers.length;

  /// Initialize provider and load customers
  Future<void> initialize() async {
    await loadCustomers();
  }

  /// Load all customers from database
  Future<void> loadCustomers() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _customers = await _dbHelper.getAllCustomers();
      _filteredCustomers = _customers;

      _isLoading = false;
      notifyListeners();

      print('✅ Loaded ${_customers.length} customers');
    } catch (e) {
      _error = 'Error loading customers: $e';
      _isLoading = false;
      print('❌ $_error');
      notifyListeners();
    }
  }

  /// Add new customer
  Future<bool> addCustomer(Customer customer) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Validate customer data
      final validationError = customer.validate();
      if (validationError != null) {
        _error = validationError;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Check for duplicate phone number
      final existingCustomer = _customers
          .where((c) => c.phoneNumber == customer.phoneNumber)
          .firstOrNull;
      if (existingCustomer != null) {
        _error = 'Customer with this phone number already exists';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final id = await _dbHelper.addCustomer(customer);
      final newCustomer = customer.copyWith(id: id as int?);

      _customers.add(newCustomer);
      _filteredCustomers = _customers;

      _isLoading = false;
      _error = null;
      notifyListeners();

      print('✅ Customer added: ${customer.name}');
      return true;
    } catch (e) {
      _error = 'Error adding customer: $e';
      _isLoading = false;
      print('❌ $_error');
      notifyListeners();
      return false;
    }
  }

  /// Get customer by ID
  Customer? getCustomerById(int id) {
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Update customer
  Future<bool> updateCustomer(Customer customer) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Validate customer data
      final validationError = customer.validate();
      if (validationError != null) {
        _error = validationError;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Check for duplicate phone number (excluding current customer)
      final existingCustomer = _customers
          .where((c) =>
      c.phoneNumber == customer.phoneNumber && c.id != customer.id)
          .firstOrNull;
      if (existingCustomer != null) {
        _error = 'Another customer with this phone number already exists';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await _dbHelper.updateCustomer(customer);

      final index = _customers.indexWhere((c) => c.id == customer.id);
      if (index != -1) {
        _customers[index] = customer;
        _filteredCustomers = _customers;
      }

      _isLoading = false;
      _error = null;
      notifyListeners();

      print('✅ Customer updated: ${customer.name}');
      return true;
    } catch (e) {
      _error = 'Error updating customer: $e';
      _isLoading = false;
      print('❌ $_error');
      notifyListeners();
      return false;
    }
  }

  /// Delete customer
  Future<bool> deleteCustomer(int customerId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _dbHelper.deleteCustomer(customerId);

      _customers.removeWhere((c) => c.id == customerId);
      _filteredCustomers = _customers;

      _isLoading = false;
      _error = null;
      notifyListeners();

      print('✅ Customer deleted');
      return true;
    } catch (e) {
      _error = 'Error deleting customer: $e';
      _isLoading = false;
      print('❌ $_error');
      notifyListeners();
      return false;
    }
  }

  /// Search customers by name or phone
  Future<void> searchCustomers(String query) async {
    try {
      _searchQuery = query;

      if (query.isEmpty) {
        _filteredCustomers = _customers;
      } else {
        _filteredCustomers =
        await _dbHelper.searchCustomers(query);
      }

      notifyListeners();
      print('🔍 Search completed: ${_filteredCustomers.length} results');
    } catch (e) {
      _error = 'Error searching customers: $e';
      print('❌ $_error');
      notifyListeners();
    }
  }

  /// Clear search
  void clearSearch() {
    _searchQuery = '';
    _filteredCustomers = _customers;
    notifyListeners();
  }

  /// Refresh customers list
  Future<void> refreshCustomers() async {
    await loadCustomers();
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Get customer count
  Future<int> getCustomerCount() async {
    try {
      return await _dbHelper.getTotalCustomerCount();
    } catch (e) {
      print('❌ Error getting customer count: $e');
      return 0;
    }
  }

  /// Get customers with upcoming reminders
  Future<List<Customer>> getCustomersWithUpcomingReminders() async {
    // This would be implemented with purchase data
    return _customers;
  }

  /// Export customers to JSON
  List<Map<String, dynamic>> exportToJSON() {
    return _customers.map((c) => c.toJson()).toList();
  }

  /// Clear all data (for testing)
  Future<void> clearAllData() async {
    try {
      _customers.clear();
      _filteredCustomers.clear();
      notifyListeners();
      print('✅ All customer data cleared');
    } catch (e) {
      print('❌ Error clearing data: $e');
    }
  }
}
