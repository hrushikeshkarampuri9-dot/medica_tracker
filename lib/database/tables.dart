/// Database table names
class Tables {
  static const String customers = 'customers';
  static const String medicines = 'medicines';
  static const String purchases = 'purchases';
}

/// SQL table creation scripts
class TableSchemas {
  /// Customers table schema
  static const String createCustomersTable = '''
    CREATE TABLE IF NOT EXISTS ${Tables.customers} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      phoneNumber TEXT NOT NULL UNIQUE,
      address TEXT,
      age INTEGER,
      gender TEXT,
      createdAt TEXT NOT NULL,
      updatedAt TEXT
    );
  ''';

  /// Create index on phone number for faster search
  static const String createCustomersPhoneIndex = '''
    CREATE INDEX IF NOT EXISTS idx_customer_phone 
    ON ${Tables.customers}(phoneNumber);
  ''';

  /// Create index on name for search
  static const String createCustomersNameIndex = '''
    CREATE INDEX IF NOT EXISTS idx_customer_name 
    ON ${Tables.customers}(name);
  ''';

  /// Medicines table schema
  static const String createMedicinesTable = '''
    CREATE TABLE IF NOT EXISTS ${Tables.medicines} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL UNIQUE,
      type TEXT NOT NULL,
      description TEXT,
      dosageForm TEXT,
      price REAL,
      createdAt TEXT NOT NULL,
      updatedAt TEXT
    );
  ''';

  /// Create index on medicine type for filtering
  static const String createMedicinesTypeIndex = '''
    CREATE INDEX IF NOT EXISTS idx_medicine_type 
    ON ${Tables.medicines}(type);
  ''';

  /// Create index on medicine name for search
  static const String createMedicinesNameIndex = '''
    CREATE INDEX IF NOT EXISTS idx_medicine_name 
    ON ${Tables.medicines}(name);
  ''';

  /// Purchases table schema
  static const String createPurchasesTable = '''
    CREATE TABLE IF NOT EXISTS ${Tables.purchases} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      customerId INTEGER NOT NULL,
      medicineId INTEGER NOT NULL,
      customerName TEXT NOT NULL,
      medicineName TEXT NOT NULL,
      medicineType TEXT NOT NULL,
      purchaseDate TEXT NOT NULL,
      durationDays INTEGER NOT NULL,
      dosageFrequency TEXT NOT NULL,
      finishDate TEXT NOT NULL,
      quantity REAL,
      price REAL,
      notes TEXT,
      reminderSent INTEGER DEFAULT 0,
      reminderSentAt TEXT,
      createdAt TEXT NOT NULL,
      updatedAt TEXT,
      FOREIGN KEY (customerId) REFERENCES ${Tables.customers}(id) ON DELETE CASCADE,
      FOREIGN KEY (medicineId) REFERENCES ${Tables.medicines}(id) ON DELETE CASCADE
    );
  ''';

  /// Create index on customerId for faster queries
  static const String createPurchasesCustomerIndex = '''
    CREATE INDEX IF NOT EXISTS idx_purchase_customer 
    ON ${Tables.purchases}(customerId);
  ''';

  /// Create index on finishDate for reminder checks
  static const String createPurchasesFinishDateIndex = '''
    CREATE INDEX IF NOT EXISTS idx_purchase_finish_date 
    ON ${Tables.purchases}(finishDate);
  ''';

  /// Create index on reminder status for filtering
  static const String createPurchasesReminderIndex = '''
    CREATE INDEX IF NOT EXISTS idx_purchase_reminder_sent 
    ON ${Tables.purchases}(reminderSent);
  ''';

  /// Create index on medicineId
  static const String createPurchasesMedicineIndex = '''
    CREATE INDEX IF NOT EXISTS idx_purchase_medicine 
    ON ${Tables.purchases}(medicineId);
  ''';

  /// Get all table creation queries
  static List<String> getAllTableCreationQueries() {
    return [
      createCustomersTable,
      createCustomersPhoneIndex,
      createCustomersNameIndex,
      createMedicinesTable,
      createMedicinesTypeIndex,
      createMedicinesNameIndex,
      createPurchasesTable,
      createPurchasesCustomerIndex,
      createPurchasesFinishDateIndex,
      createPurchasesReminderIndex,
      createPurchasesMedicineIndex,
    ];
  }
}
