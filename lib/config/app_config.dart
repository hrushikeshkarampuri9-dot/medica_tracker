/// Application Configuration
/// Centralized settings for the entire app
class AppConfig {
  // API & Backend Configuration
  static const String appName = 'MEDIT TRACKER';
  static const String appVersion = '1.0.0';
  static const String appBuild = '1';

  // Database Configuration
  static const String databaseName = 'medical_tracker.db';
  static const int databaseVersion = 1;

  // Reminder Configuration
  static const int reminderDaysBeforeExpiry = 3; // Send reminder 3 days before
  static const String reminderCheckTime = '09:00'; // Check reminders at 9 AM daily
  static const String reminderCheckTimeHour = '9';
  static const String reminderCheckTimeMinute = '0';

  // SMS Configuration
  static const String smsPrefix = 'Aaradhya Plus Pharma';
  static const bool enableSmsReminders = true;
  static const bool enableWhatsAppReminders = true;

  // Store Configuration
  static String storeName = 'Aaradhya Plus Pharma';
  static String storePhone = '9309702774';
  static String storeAddress = 'VVP POLYTECHNIC ';

  // UI Configuration
  static const bool enableDarkMode = false;
  static const String defaultLanguage = 'en';

  // Notification Configuration
  static const String notificationChannelId = 'medical_tracker_channel';
  static const String notificationChannelName = 'Medical Tracker Reminders';
  static const String notificationChannelDescription =
      'Notifications for medication reminders';

  // Validation Configuration
  static const int minCustomerNameLength = 2;
  static const int maxCustomerNameLength = 100;
  static const int phoneNumberLength = 10;
  static const int minCustomerAge = 1;
  static const int maxCustomerAge = 120;

  // Duration Constraints (in days)
  static const int minMedicineDuration = 10;
  static const int maxMedicineDuration = 90;

  // Cache Configuration
  static const Duration cacheExpiration = Duration(hours: 24);

  // Feature Flags
  static const bool enableAnalytics = false;
  static const bool enableErrorReporting = true;
  static const bool enableOfflineMode = true;

  // Pagination
  static const int pageSize = 20;
  static const int initialPageLoadSize = 10;

  // Timeout Configuration
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration dbQueryTimeout = Duration(seconds: 10);

  // Rate Limiting
  static const int maxReminderAttempts = 3;
  static const Duration reminderRetryDelay = Duration(minutes: 5);

  // Set store configuration
  static void setStoreConfig({
    required String name,
    required String phone,
    required String address,
  }) {
    storeName = name;
    storePhone = phone;
    storeAddress = address;
  }

  // Get full store info
  static String getStoreInfo() {
    return '$storeName\n$storeAddress\n$storePhone';
  }

  // Debug mode
  static const bool debugMode = true;

  static void printConfig() {
    if (debugMode) {
      print('=== App Configuration ===');
      print('App Name: $appName');
      print('Version: $appVersion (Build $appBuild)');
      print('Database: $databaseName (v$databaseVersion)');
      print('Reminder Days: $reminderDaysBeforeExpiry');
      print('Check Time: $reminderCheckTime');
      print('Store: $storeName');
      print('========================');
    }
  }
}
