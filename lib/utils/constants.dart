import 'package:flutter/material.dart';

/// App Colors
class AppColors {
  static const Color primary = Color(0xFF2563EB); // Professional Blue
  static const Color secondary = Color(0xFF10B981); // Fresh Green
  static const Color danger = Color(0xFFEF4444); // Alert Red
  static const Color warning = Color(0xFFF59E0B); // Warning Orange
  static const Color success = Color(0xFF10B981); // Success Green
  static const Color info = Color(0xFF3B82F6); // Info Blue

  static const Color background = Color(0xFFF9FAFB); // Light Gray
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color cardBackground = Color(0xFFF3F4F6); // Card Gray
  static const Color divider = Color(0xFFE5E7EB); // Divider Gray

  static const Color textPrimary = Color(0xFF111827); // Dark Text
  static const Color textSecondary = Color(0xFF6B7280); // Gray Text
  static const Color textTertiary = Color(0xFF9CA3AF); // Light Gray Text

  static const Color borderColor = Color(0xFFD1D5DB); // Border Gray
  static const Color errorBg = Color(0xFFFEE2E2); // Error Background
  static const Color successBg = Color(0xFDECF4EB); // Success Background
  static const Color warningBg = Color(0xFFFEF3C7); // Warning Background
}

/// App Typography Sizes
class AppTypography {
  static const double heading1 = 32.0;
  static const double heading2 = 28.0;
  static const double heading3 = 24.0;
  static const double heading4 = 20.0;
  static const double heading5 = 18.0;

  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;
  static const double caption = 11.0;
}

/// App Spacing
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
}

/// App Border Radius
class AppRadius {
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double full = 999.0;
}

/// App Strings
class AppStrings {
  // App Name
  static const String appName = 'Medical Tracker';
  static const String appTagline = 'Customer Medication Reminders';

  // Customer Management
  static const String addCustomer = 'Add Customer';
  static const String editCustomer = 'Edit Customer';
  static const String deleteCustomer = 'Delete Customer';
  static const String customerName = 'Customer Name';
  static const String phoneNumber = 'Phone Number';
  static const String address = 'Address';
  static const String age = 'Age';
  static const String gender = 'Gender';

  // Medicine Management
  static const String addMedicine = 'Add Medicine';
  static const String medicineName = 'Medicine Name';
  static const String medicineType = 'Medicine Type';
  static const String dosage = 'Dosage';
  static const String duration = 'Duration';
  static const String quantity = 'Quantity';

  // Purchase
  static const String addPurchase = 'Add Purchase';
  static const String purchaseDate = 'Purchase Date';
  static const String purchaseHistory = 'Purchase History';
  static const String refillReminder = 'Refill Reminder';

  // Reminders
  static const String reminders = 'Reminders';
  static const String sendReminder = 'Send Reminder';
  static const String sendSMS = 'Send SMS';
  static const String sendWhatsApp = 'Send WhatsApp';
  static const String dueToday = 'Due Today';
  static const String dueThisWeek = 'Due This Week';

  // Dashboard
  static const String dashboard = 'Dashboard';
  static const String totalCustomers = 'Total Customers';
  static const String totalMedicines = 'Total Medicines';
  static const String dueReminders = 'Due Reminders';
  static const String thisWeekReminders = 'This Week Reminders';

  // Buttons
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String search = 'Search';
  static const String clear = 'Clear';
  static const String submit = 'Submit';

  // Validation
  static const String fieldRequired = 'This field is required';
  static const String invalidPhone = 'Enter valid 10-digit phone number';
  static const String invalidEmail = 'Enter valid email address';

  // Messages
  static const String addedSuccessfully = 'Added successfully';
  static const String updatedSuccessfully = 'Updated successfully';
  static const String deletedSuccessfully = 'Deleted successfully';
  static const String reminderSentSuccessfully = 'Reminder sent successfully';
}

/// Medicine Types
class MedicineTypes {
  static const List<String> types = [
    'BP (Blood Pressure)',
    'Sugar (Diabetes)',
    'Heart',
    'Thyroid',
    'Pain Relief',
    'Antibiotic',
    'Vitamin',
    'Cough & Cold',
    'Other'
  ];
}

/// Duration Options (Days)
class DurationOptions {
  static const List<int> days = [4, 5, 10, 15, 20, 30, 45, 60];
}

/// Dosage Frequency
class DosageFrequency {
  static const List<String> frequency = [
    'Once Daily',
    'Twice Daily',
    'Thrice Daily',
    'Every 4 Hours',
    'Every 6 Hours',
    'Every 8 Hours',
    'As Needed'
  ];
}

/// Gender Options
class GenderOptions {
  static const List<String> genders = ['Male', 'Female', 'Other'];
}
