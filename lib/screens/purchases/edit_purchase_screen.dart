import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/purchase_provider.dart';
import '../../models/customer_model.dart';
import '../../models/purchase_model.dart';
import '../../utils/constants.dart';
import '../../utils/date_helper.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../database/database_helper.dart';

class EditPurchaseScreen extends StatefulWidget {
  final Purchase purchase;

  const EditPurchaseScreen({
    super.key,
    required this.purchase,
  });

  @override
  State<EditPurchaseScreen> createState() => _EditPurchaseScreenState();
}

class _EditPurchaseScreenState extends State<EditPurchaseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _medicineNameController;
  late TextEditingController _medicineTypeController;
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  late TextEditingController _notesController;
  late TextEditingController _finishDateController;

  Customer? _selectedCustomer;
  late DateTime _selectedPurchaseDate;
  late int _selectedDuration;
  late String _selectedDosageFrequency;

  List<Customer> _customers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize with existing purchase data
    _medicineNameController = TextEditingController(text: widget.purchase.medicineName);
    _medicineTypeController = TextEditingController(text: widget.purchase.medicineType);
    _quantityController = TextEditingController(
      text: widget.purchase.quantity?.toString() ?? '',
    );
    _priceController = TextEditingController(
      text: widget.purchase.price?.toString() ?? '',
    );
    _notesController = TextEditingController(text: widget.purchase.notes ?? '');
    _finishDateController = TextEditingController(
      text: DateHelper.formatDate(widget.purchase.finishDate),
    );

    _selectedPurchaseDate = widget.purchase.purchaseDate;
    _selectedDuration = widget.purchase.durationDays;
    _selectedDosageFrequency = widget.purchase.dosageFrequency;

    _loadData();
  }

  Future<void> _loadData() async {
    final customers = context.read<CustomerProvider>().customers;
    setState(() {
      _customers = customers;
      _selectedCustomer = customers.firstWhere(
            (c) => c.id == widget.purchase.customerId,
        orElse: () => customers.first,
      );
    });
  }

  @override
  void dispose() {
    _medicineNameController.dispose();
    _medicineTypeController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    _finishDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Purchase'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.danger),
            onPressed: () => _showDeleteConfirm(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer selection
              Text(
                'Select Customer *',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<Customer>(
                value: _selectedCustomer,
                items: _customers
                    .map((customer) => DropdownMenuItem(
                  value: customer,
                  child: Text(customer.name),
                ))
                    .toList(),
                onChanged: (customer) {
                  setState(() {
                    _selectedCustomer = customer;
                  });
                },
                validator: (value) =>
                value == null ? 'Please select a customer' : null,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Medicine Name
              CustomTextField(
                label: 'Medicine Name',
                hint: 'e.g., Aspirin, Paracetamol',
                controller: _medicineNameController,
                prefixIcon: Icons.medical_services,
                required: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Medicine name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Medicine Type
              CustomDropdownField<String>(
                label: 'Medicine Type',
                value: _medicineTypeController.text.isEmpty
                    ? null
                    : _medicineTypeController.text,
                items: MedicineTypes.types,
                itemLabel: (type) => type,
                onChanged: (type) {
                  setState(() => _medicineTypeController.text = type ?? '');
                },
                required: true,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Purchase date
              CustomTextField(
                label: 'Purchase Date *',
                controller: TextEditingController(
                  text: DateHelper.formatDate(_selectedPurchaseDate),
                ),
                readOnly: true,
                onTap: () => _selectDate(),
                prefixIcon: Icons.calendar_today,
                required: true,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Duration
              CustomDropdownField<int>(
                label: 'Duration (Days) *',
                value: _selectedDuration,
                items: DurationOptions.days,
                itemLabel: (days) => '$days days',
                onChanged: (days) {
                  setState(() {
                    _selectedDuration = days!;
                    final finishDate = DateHelper.calculateFinishDate(
                      _selectedPurchaseDate,
                      days,
                    );
                    _finishDateController.text =
                        DateHelper.formatDate(finishDate);
                  });
                },
                required: true,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Finish date (auto-calculated)
              CustomTextField(
                label: 'Expected Finish Date',
                controller: _finishDateController,
                readOnly: true,
                prefixIcon: Icons.event_available,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Dosage frequency
              CustomDropdownField<String>(
                label: 'Dosage Frequency *',
                value: _selectedDosageFrequency,
                items: DosageFrequency.frequency,
                itemLabel: (freq) => freq,
                onChanged: (freq) {
                  setState(() {
                    _selectedDosageFrequency = freq!;
                  });
                },
                required: true,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Quantity
              CustomTextField(
                label: 'Quantity',
                hint: 'e.g., 1 strip, 2 bottles',
                controller: _quantityController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Price
              CustomTextField(
                label: 'Price (₹)',
                hint: 'Enter price',
                controller: _priceController,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Notes
              CustomTextField(
                label: 'Notes',
                hint: 'Add any special notes',
                controller: _notesController,
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Submit button
              CustomButton(
                label: 'Update Purchase',
                onPressed: _isLoading ? () {} : _submitForm,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedPurchaseDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedPurchaseDate = picked;
        final finishDate = DateHelper.calculateFinishDate(
          _selectedPurchaseDate,
          _selectedDuration,
        );
        _finishDateController.text = DateHelper.formatDate(finishDate);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a customer')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final quantity = _quantityController.text.isEmpty
          ? null
          : double.tryParse(_quantityController.text);
      final price = _priceController.text.isEmpty
          ? null
          : double.tryParse(_priceController.text);

      // Create updated purchase
      final updatedPurchase = Purchase(
        id: widget.purchase.id, // Keep same ID
        customerId: _selectedCustomer!.id!,
        medicineId: widget.purchase.medicineId,
        customerName: _selectedCustomer!.name,
        medicineName: _medicineNameController.text,
        medicineType: _medicineTypeController.text,
        purchaseDate: _selectedPurchaseDate,
        durationDays: _selectedDuration,
        dosageFrequency: _selectedDosageFrequency,
        finishDate: DateHelper.calculateFinishDate(
          _selectedPurchaseDate,
          _selectedDuration,
        ),
        quantity: quantity,
        price: price,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        reminderSent: widget.purchase.reminderSent,
        createdAt: widget.purchase.createdAt,
        updatedAt: DateTime.now(),
      );

      // Update in database
      final dbHelper = DatabaseHelper();
      await dbHelper.updatePurchase(updatedPurchase);

      // Refresh purchase data
      if (mounted) {
        await context.read<PurchaseProvider>().refreshPurchases();
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchase updated successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showDeleteConfirm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Purchase'),
        content: const Text(
          'Are you sure you want to delete this purchase record?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final dbHelper = DatabaseHelper();
              await dbHelper.deletePurchase(widget.purchase.id!);
              await context.read<PurchaseProvider>().refreshPurchases();
              if (mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close edit screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Purchase deleted')),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}
