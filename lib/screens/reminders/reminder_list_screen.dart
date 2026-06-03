import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/purchase_provider.dart';
import '../../providers/customer_provider.dart';
import '../../services/sms_service.dart';
import '../../services/whatsapp_service.dart';
import '../../utils/constants.dart';
import '../../widgets/medicine_card.dart';
import '../../models/purchase_model.dart';
import '../../config/app_config.dart';

class ReminderListScreen extends StatefulWidget {
  const ReminderListScreen({super.key});

  @override
  State<ReminderListScreen> createState() => _ReminderListScreenState();
}

class _ReminderListScreenState extends State<ReminderListScreen> {
  int _selectedTab = 0; // 0: Due Today, 1: Due This Week, 2: Pending

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Tab selector
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: _TabButton(
                      label: 'Due Today',
                      isSelected: _selectedTab == 0,
                      onPressed: () {
                        setState(() => _selectedTab = 0);
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _TabButton(
                      label: 'This Week',
                      isSelected: _selectedTab == 1,
                      onPressed: () {
                        setState(() => _selectedTab = 1);
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _TabButton(
                      label: 'Pending',
                      isSelected: _selectedTab == 2,
                      onPressed: () {
                        setState(() => _selectedTab = 2);
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Consumer<PurchaseProvider>(
                builder: (context, provider, _) {
                  final reminders = _getReminders(provider);

                  if (reminders.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 64,
                            color: AppColors.success,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            _getEmptyMessage(),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    itemCount: reminders.length,
                    itemBuilder: (context, index) {
                      final purchase = reminders[index];
                      return PurchaseCard(
                        purchase: purchase,
                        onSendReminder: () => _showReminderOptions(
                          context,
                          purchase,
                        ),
                        onRefill: () {
                          Navigator.pushNamed(context, '/add-purchase');
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Purchase> _getReminders(PurchaseProvider provider) {
    switch (_selectedTab) {
      case 0:
        return provider.purchasesDueToday;
      case 1:
        return provider.purchasesDueThisWeek;
      case 2:
        return provider.pendingReminders;
      default:
        return [];
    }
  }

  String _getEmptyMessage() {
    switch (_selectedTab) {
      case 0:
        return 'No reminders due today';
      case 1:
        return 'No reminders due this week';
      case 2:
        return 'No pending reminders';
      default:
        return '';
    }
  }

  void _showReminderOptions(BuildContext context, Purchase purchase) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Send Reminder to ${purchase.customerName}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            ListTile(
              leading: const Icon(Icons.sms),
              title: const Text('Send SMS'),
              subtitle: Text(
                'Message will be sent via SMS app',
              ),
              onTap: () {
                Navigator.pop(context);
                _sendSMSReminder(context, purchase);
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Send WhatsApp'),
              subtitle: const Text('Open WhatsApp to send message'),
              onTap: () {
                Navigator.pop(context);
                _sendWhatsAppReminder(context, purchase);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendSMSReminder(
      BuildContext context,
      Purchase purchase,
      ) async {
    try {
      // Get customer details from provider
      final customer = context
          .read<CustomerProvider>()
          .getCustomerById(purchase.customerId);

      if (customer == null) {
        throw Exception('Customer not found');
      }

      // Get customer phone number
      final phoneNumber = customer.phoneNumber;

      // Create SMS message
      final message = SMSService.createReminderMessage(
        customerName: purchase.customerName,
        medicineName: purchase.medicineName,
        medicineType: purchase.medicineType,
        storeName: AppConfig.storeName,
        storePhone: AppConfig.storePhone,
        storeAddress: AppConfig.storeAddress,
      );

      // Send SMS
      final success = await SMSService.sendSMS(
        phoneNumber: phoneNumber,
        message: message,
      );

      if (success && mounted) {
        // Mark reminder as sent
        await context.read<PurchaseProvider>().markReminderAsSent(purchase.id!);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SMS app opened with message'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _sendWhatsAppReminder(
      BuildContext context,
      Purchase purchase,
      ) async {
    try {
      // Get customer details from provider
      final customer = context
          .read<CustomerProvider>()
          .getCustomerById(purchase.customerId);

      if (customer == null) {
        throw Exception('Customer not found');
      }

      // Get customer phone number
      final phoneNumber = customer.phoneNumber;

      // Create WhatsApp message
      final message = WhatsAppService.createReminderMessage(
        customerName: purchase.customerName,
        medicineName: purchase.medicineName,
        medicineType: purchase.medicineType,
        storeName: AppConfig.storeName,
        storePhone: AppConfig.storePhone,
        storeAddress: AppConfig.storeAddress,
        daysRemaining: purchase.getDaysRemaining(),
      );

      // Send WhatsApp message
      final success = await WhatsAppService.sendWhatsAppMessage(
        phoneNumber: phoneNumber,
        message: message,
      );

      if (success && mounted) {
        // Mark reminder as sent
        await context.read<PurchaseProvider>().markReminderAsSent(purchase.id!);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('WhatsApp opened with message'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
