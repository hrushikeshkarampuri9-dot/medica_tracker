import 'package:flutter/material.dart';
import 'package:medical_tracker/screens/purchases/edit_purchase_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/purchase_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/medicine_card.dart';
import '../../models/purchase_model.dart';
import '../../utils/date_helper.dart';

class PurchaseHistoryScreen extends StatefulWidget {
  const PurchaseHistoryScreen({super.key});

  @override
  State<PurchaseHistoryScreen> createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends State<PurchaseHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by customer or medicine...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
                onChanged: (_) {
                  setState(() {});
                },
              ),
            ),
            // Purchase history list
            Expanded(
              child: Consumer<PurchaseProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final purchases = provider.purchases.where((p) {
                    final query = _searchController.text.toLowerCase();
                    return p.customerName.toLowerCase().contains(query) ||
                        p.medicineName.toLowerCase().contains(query);
                  }).toList();

                  if (purchases.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 64,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            'No purchase history',
                            style: Theme
                                .of(context)
                                .textTheme
                                .bodyMedium,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    itemCount: purchases.length,
                    itemBuilder: (context, index) {
                      final purchase = purchases[index];
                      return PurchaseCard(
                        purchase: purchase,
                        onTap: () {
                          // Show purchase details
                          _showPurchaseDetails(context, purchase);
                        },
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

  void _showPurchaseDetails(BuildContext context, Purchase purchase) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Purchase Details'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DetailRow('Customer', purchase.customerName),
                  _DetailRow('Medicine', purchase.medicineName),
                  _DetailRow('Type', purchase.medicineType),
                  _DetailRow('Dosage', purchase.dosageFrequency),
                  _DetailRow('Duration', '${purchase.durationDays} days'),
                  _DetailRow('Purchase Date',
                      DateHelper.formatDate(purchase.purchaseDate)),
                  _DetailRow('Finish Date',
                      DateHelper.formatDate(purchase.finishDate)),
                  if (purchase.price != null)
                    _DetailRow('Price', '₹${purchase.price}'),
                  if (purchase.notes != null)
                    _DetailRow('Notes', purchase.notes!),
                  _DetailRow(
                    'Status',
                    purchase.getReminderStatus(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditPurchaseScreen(purchase: purchase),
                    ),
                  );
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

// Add imports at top
