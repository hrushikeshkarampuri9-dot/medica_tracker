import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

class WhatsAppService {
  // WhatsApp URL scheme constants
  static const String _whatsappWeb = 'https://web.whatsapp.com/send';
  static const String _whatsappApp = 'whatsapp://send';

  /// Send WhatsApp message to a single phone number
  /// Returns true if WhatsApp opened successfully
  static Future<bool> sendWhatsAppMessage({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      // Check and request permission if needed
      final permissionStatus = await Permission.contacts.request();

      if (!permissionStatus.isDenied) {
        // Format phone number with country code
        final formattedPhone = _formatPhoneNumber(phoneNumber);

        // Try to open WhatsApp app first
        final appUrl = Uri.parse('$_whatsappApp?phone=$formattedPhone&text=${Uri.encodeComponent(message)}');

        if (await canLaunchUrl(appUrl)) {
          await launchUrl(appUrl);
          return true;
        }

        // Fallback to WhatsApp Web
        final webUrl = Uri.parse('$_whatsappWeb?phone=$formattedPhone&text=${Uri.encodeComponent(message)}');
        if (await canLaunchUrl(webUrl)) {
          await launchUrl(webUrl);
          return true;
        }

        throw Exception('WhatsApp app or web is not available');
      } else {
        throw Exception('Permission denied to access contacts');
      }
    } catch (e) {
      throw Exception('Error sending WhatsApp message: $e');
    }
  }

  /// Send WhatsApp message to multiple phone numbers
  static Future<List<bool>> sendBulkWhatsAppMessage({
    required List<String> phoneNumbers,
    required String message,
  }) async {
    final results = <bool>[];

    for (final phoneNumber in phoneNumbers) {
      try {
        final result = await sendWhatsAppMessage(
          phoneNumber: phoneNumber,
          message: message,
        );
        results.add(result);

        // Add small delay between messages to avoid rate limiting
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        results.add(false);
      }
    }

    return results;
  }

  /// Check if WhatsApp is installed
  static Future<bool> isWhatsAppInstalled() async {
    try {
      final uri = Uri.parse('$_whatsappApp?phone=1');
      return await canLaunchUrl(uri);
    } catch (e) {
      return false;
    }
  }

  /// Open WhatsApp chat with a contact
  static Future<bool> openWhatsAppChat({
    required String phoneNumber,
  }) async {
    try {
      final formattedPhone = _formatPhoneNumber(phoneNumber);
      final uri = Uri.parse('$_whatsappApp?phone=$formattedPhone');

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Error opening WhatsApp chat: $e');
    }
  }

  /// Create reminder message for WhatsApp
  static String createReminderMessage({
    required String customerName,
    required String medicineName,
    required String medicineType,
    required String storeName,
    required String storePhone,
    required String storeAddress,
    required int daysRemaining,
  }) {
    return '''👋 Hi $customerName!

💊 *Medication Reminder*

Your medicine *$medicineName* (for $medicineType) will finish in $daysRemaining days.

📍 *Visit us for refill:*
$storeName
📌 $storeAddress
📱 $storePhone

Thank you for choosing us! ❤️''';
  }

  /// Create urgent reminder message
  static String createUrgentReminderMessage({
    required String customerName,
    required String medicineName,
    required String storeName,
  }) {
    return '''🚨 *URGENT - Medication Refill Needed!*

Hi $customerName,

Your medicine *$medicineName* is finishing TODAY! ⚠️

Please visit $storeName immediately to get your refill.

Don't delay your medication! 💪''';
  }

  /// Create product promotion message
  static String createPromoMessage({
    required String storeName,
    required String offer,
  }) {
    return '''🎉 *Special Offer from $storeName!*

$offer

Visit us today! 🏥

*Your Health, Our Priority* ❤️''';
  }

  /// Format phone number for WhatsApp (add country code if needed)
  static String _formatPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // If 10 digits, add +91 (India)
    if (cleaned.length == 10) {
      return '91$cleaned';
    }

    // If already has country code, return as is
    if (cleaned.length > 10) {
      return cleaned;
    }

    return cleaned;
  }

  /// Validate phone number for WhatsApp
  static bool isValidPhoneNumber(String phoneNumber) {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // Accept 10 digits (India) or more with country code
    if (cleaned.length == 10) {
      final firstDigit = int.parse(cleaned[0]);
      return firstDigit >= 6 && firstDigit <= 9;
    }

    return cleaned.length >= 11;
  }

  /// Share message via WhatsApp (open share dialog)
  static Future<bool> shareViaWhatsApp({
    required String message,
  }) async {
    try {
      final uri = Uri.parse('$_whatsappApp?text=${Uri.encodeComponent(message)}');

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Error sharing via WhatsApp: $e');
    }
  }

  /// Get WhatsApp contact list (requires special permissions)
  static Future<void> openWhatsAppContacts() async {
    try {
      final uri = Uri.parse(_whatsappApp);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      throw Exception('Error opening WhatsApp: $e');
    }
  }
}
