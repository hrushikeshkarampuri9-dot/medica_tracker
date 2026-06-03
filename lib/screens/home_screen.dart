import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/customer_provider.dart';
import '../providers/purchase_provider.dart';
import '../services/reminder_service.dart';
import '../utils/constants.dart';
import '../widgets/custom_button.dart';
import 'customers/customer_list_screen.dart';
import 'reminders/reminder_list_screen.dart';
import 'purchases/purchase_history_screen.dart';
import 'about_screen.dart'; // ✅ Import About Screen
import '../models/purchase_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await context.read<CustomerProvider>().initialize();
      await context.read<PurchaseProvider>().initialize();

      await ReminderService.initialize();
      await ReminderService.startDailyReminderChecks();

      if (mounted) {
        setState(() => _initialized = true);
        print('✅ App initialized successfully');
      }
    } catch (e) {
      print('❌ Initialization error: $e');
      if (mounted) {
        setState(() => _initialized = true);
      }
    }
  }

  void _navigateToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Initializing Medical Tracker...',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.appName),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        actions: [
          // ✅ Add Info Icon Button
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AboutScreen(),
                ),
              );
            },
            tooltip: 'About Us',
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _DashboardView(onNavigate: _navigateToTab),
          const CustomerListScreen(),
          const ReminderListScreen(),
          const PurchaseHistoryScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Customers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Reminders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}

// ... (Rest of your existing code remains the same - _DashboardView, _StatCard, etc.)


class _DashboardView extends StatelessWidget {
  final Function(int) onNavigate;

  const _DashboardView({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<CustomerProvider>().refreshCustomers();
        await context.read<PurchaseProvider>().refreshPurchases();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'WELCOME TO MEDITRACKER',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Keep your customers healthy with timely reminders',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Statistics Cards
            Consumer2<CustomerProvider, PurchaseProvider>(
              builder: (context, customerProvider, purchaseProvider, _) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: AppStrings.totalCustomers,
                            value: customerProvider.totalCustomers.toString(),
                            icon: Icons.people,
                            color: AppColors.primary,
                            onTap: () => onNavigate(1),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: _StatCard(
                            title: 'Total Medicines',
                            value: purchaseProvider.totalPurchases.toString(),
                            icon: Icons.medical_services,
                            color: AppColors.secondary,
                            onTap: () => onNavigate(3),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: AppStrings.dueToday,
                            value: purchaseProvider.purchasesDueToday.length
                                .toString(),
                            icon: Icons.today,
                            color: AppColors.danger,
                            onTap: () => onNavigate(2),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: _StatCard(
                            title: AppStrings.dueThisWeek,
                            value: purchaseProvider.purchasesDueThisWeek.length
                                .toString(),
                            icon: Icons.calendar_today,
                            color: AppColors.warning,
                            onTap: () => onNavigate(2),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),

            // Quick Actions Section
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/add-customer');
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.person_add, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Add Customer',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/add-purchase');
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.add_shopping_cart, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Add Purchase',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // ✅ UPDATED: All Pending Reminders Section (Due Today + This Week + Pending)
            Consumer<PurchaseProvider>(
              builder: (context, purchaseProvider, _) {
                // Combine all reminders
                final allReminders = <Purchase>[
                  ...purchaseProvider.purchasesDueToday,
                  ...purchaseProvider.purchasesDueThisWeek,
                  ...purchaseProvider.pendingReminders,
                ];

                // Remove duplicates based on purchase ID
                final uniqueReminders = <int, Purchase>{};
                for (var reminder in allReminders) {
                  if (reminder.id != null) {
                    uniqueReminders[reminder.id!] = reminder;
                  }
                }

                // Sort by days remaining (urgent first)
                final sortedReminders = uniqueReminders.values.toList()
                  ..sort((a, b) => a.getDaysRemaining().compareTo(b.getDaysRemaining()));

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'All Pending Reminders',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (sortedReminders.isNotEmpty)
                          TextButton(
                            onPressed: () => onNavigate(2),
                            child: const Text('View All'),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    if (sortedReminders.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Column(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 64,
                                color: AppColors.success,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'No pending reminders',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                'All customers are up to date!',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Column(
                        children: [
                          // Summary badges
                          Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.sm,
                              children: [
                                if (purchaseProvider.purchasesDueToday.isNotEmpty)
                                  _SummaryBadge(
                                    label: 'Due Today',
                                    count: purchaseProvider.purchasesDueToday.length,
                                    color: AppColors.danger,
                                  ),
                                if (purchaseProvider.purchasesDueThisWeek.isNotEmpty)
                                  _SummaryBadge(
                                    label: 'This Week',
                                    count: purchaseProvider.purchasesDueThisWeek.length,
                                    color: AppColors.warning,
                                  ),
                                if (purchaseProvider.pendingReminders.isNotEmpty)
                                  _SummaryBadge(
                                    label: 'Pending',
                                    count: purchaseProvider.pendingReminders.length,
                                    color: AppColors.primary,
                                  ),
                              ],
                            ),
                          ),
                          // Reminder tiles (show first 10)
                          ...sortedReminders
                              .take(10)
                              .map((purchase) => _ReminderTile(purchase))
                              .toList(),
                          if (sortedReminders.length > 10)
                            Padding(
                              padding: const EdgeInsets.only(top: AppSpacing.md),
                              child: Center(
                                child: TextButton.icon(
                                  onPressed: () => onNavigate(2),
                                  icon: const Icon(Icons.arrow_forward),
                                  label: Text(
                                    'View ${sortedReminders.length - 10} more reminders',
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: color.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ NEW: Summary Badge Widget
class _SummaryBadge extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SummaryBadge({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              count.toString(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  final Purchase purchase;

  const _ReminderTile(this.purchase);

  Color _getStatusColor() {
    final daysLeft = purchase.getDaysRemaining();
    if (daysLeft < 0) return AppColors.danger;
    if (daysLeft <= 3) return AppColors.danger;
    if (daysLeft <= 7) return AppColors.warning;
    return AppColors.primary;
  }

  IconData _getStatusIcon() {
    final daysLeft = purchase.getDaysRemaining();
    if (daysLeft < 0) return Icons.error;
    if (daysLeft <= 3) return Icons.warning_amber;
    if (daysLeft <= 7) return Icons.schedule;
    return Icons.notifications_active;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final daysRemaining = purchase.getDaysRemaining();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: statusColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Status Icon
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                _getStatusIcon(),
                color: statusColor,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Customer and Medicine Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    purchase.customerName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    purchase.medicineName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    purchase.medicineType,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Days Remaining Badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                children: [
                  Text(
                    daysRemaining < 0
                        ? 'Overdue'
                        : daysRemaining == 0
                        ? 'Today'
                        : '$daysRemaining',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (daysRemaining > 0)
                    Text(
                      daysRemaining == 1 ? 'day' : 'days',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: statusColor,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
