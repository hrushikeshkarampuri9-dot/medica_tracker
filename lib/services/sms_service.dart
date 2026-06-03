import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

class SMSService {
  /// Send SMS to a single phone number
  /// Returns true if SMS app opened successfully
  static Future<bool> sendSMS({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      // Check and request SMS permission
      final permissionStatus = await Permission.sms.request();

      if (!permissionStatus.isGranted) {
        throw Exception('SMS permission not granted');
      }

      // Create SMS URI
      final uri = Uri(
        scheme: 'sms',
        path: phoneNumber,
        queryParameters: {'body': message},
      );

      // Check if SMS app is available
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return true;
      } else {
        throw Exception('SMS app not available on this device');
      }
    } catch (e) {
      throw Exception('Error sending SMS: $e');
    }
  }

  /// Send SMS to multiple phone numbers
  static Future<List<bool>> sendBulkSMS({
    required List<String> phoneNumbers,
    required String message,
  }) async {
    final results = <bool>[];

    for (final phoneNumber in phoneNumbers) {
      try {
        final result = await sendSMS(
          phoneNumber: phoneNumber,
          message: message,
        );
        results.add(result);
      } catch (e) {
        results.add(false);
      }
    }

    return results;
  }

  /// Check if SMS permission is granted
  static Future<bool> hasSMSPermission() async {
    final status = await Permission.sms.status;
    return status.isGranted;
  }

  /// Request SMS permission
  static Future<bool> requestSMSPermission() async {
    final status = await Permission.sms.request();
    return status.isGranted;
  }

  /// Create reminder message template
  static String createReminderMessage({
    required String customerName,
    required String medicineName,
    required String medicineType,
    required String storeName,
    required String storePhone,
    required String storeAddress,
  }) {
    return '''Hello $customerName,
This is a reminder from $storeName. Your medicine $medicineName (for $medicineType) will finish soon.
Please visit us to get your refill.
📍 $storeAddress
📱 $storePhone
Thank you!''';
  }

  /// Create custom message
  static String createCustomMessage({
    required String customerName,
    required String medicineName,
    required String storeName,
    required String daysRemaining,
  }) {
    return '''Hi $customerName,
Your $medicineName will finish in $daysRemaining days. Time for a refill!
Visit us at $storeName today.
Thank you!''';
  }

  /// Validate phone number (Indian format)
  static bool isValidPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // Check if it's 10 digits (Indian mobile number)
    if (cleaned.length != 10) {
      return false;
    }

    // Check if it starts with valid digit (6-9 for Indian mobile)
    final firstDigit = int.parse(cleaned[0]);
    return firstDigit >= 6 && firstDigit <= 9;
  }

  /// Format phone number for SMS (add country code if needed)
  static String formatPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // If 10 digits, add +91 (India)
    if (cleaned.length == 10) {
      return '+91$cleaned';
    }

    // If already has country code, return as is
    if (cleaned.length > 10) {
      return '+$cleaned';
    }

    return cleaned;
  }

  /// Get SMS delivery status (Note: Most SMS apps don't provide real-time status)
  static Future<void> openSMSApp() async {
    try {
      // Try to open default SMS app
      final uri = Uri(scheme: 'sms', path: '');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      throw Exception('Error opening SMS app: $e');
    }
  }
}
