import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/purchase_provider.dart';
import '../../models/customer_model.dart';
import '../../models/medicine_model.dart';
import '../../utils/constants.dart';
import '../../utils/date_helper.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../database/database_helper.dart';
import '../../models/purchase_model.dart';

class AddPurchaseScreen extends StatefulWidget {
  final Customer? customer;
  final Medicine? medicine;

  const AddPurchaseScreen({
    super.key,
    this.customer,
    this.medicine,
  });

  @override
  State<AddPurchaseScreen> createState() => _AddPurchaseScreenState();
}

class _AddPurchaseScreenState extends State<AddPurchaseScreen> {
  final _formKey = GlobalKey<FormState>();

  Customer? _selectedCustomer;
  DateTime _selectedPurchaseDate = DateTime.now();
  List<Customer> _customers = [];
  bool _isLoading = false;

  // List to store multiple medicines
  List<MedicineEntry> _medicineEntries = [];

  @override
  void initState() {
    super.initState();
    _selectedCustomer = widget.customer;
    _loadData();

    // Add first medicine entry
    _addMedicineEntry();
  }

  Future<void> _loadData() async {
    final customers = context.read<CustomerProvider>().customers;
    setState(() {
      _customers = customers;
    });
  }

  void _addMedicineEntry() {
    setState(() {
      _medicineEntries.add(MedicineEntry());
    });
  }

  void _removeMedicineEntry(int index) {
    setState(() {
      _medicineEntries[index].dispose();
      _medicineEntries.removeAt(index);
    });
  }

  @override
  void dispose() {
    for (var entry in _medicineEntries) {
      entry.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Purchase'),
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
                    .map((customer) => DropdownMenuItem<Customer>(
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
              const SizedBox(height: AppSpacing.xl),

              // Medicines Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Medicines',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    '${_medicineEntries.length} medicine(s)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Medicine Entries
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _medicineEntries.length,
                itemBuilder: (context, index) {
                  return _buildMedicineCard(index);
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              // Add More Medicine Button
              OutlinedButton.icon(
                onPressed: _addMedicineEntry,
                icon: const Icon(Icons.add),
                label: const Text('Add Another Medicine'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  side: BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Submit button
              CustomButton(
                label: 'Add All Purchases',
                onPressed: _isLoading ? () {} : _submitForm,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicineCard(int index) {
    final entry = _medicineEntries[index];
    final canRemove = _medicineEntries.length > 1;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Text(
                      '#${index + 1}',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Medicine ${index + 1}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (canRemove)
                IconButton(
                  onPressed: () => _removeMedicineEntry(index),
                  icon: const Icon(Icons.delete_outline),
                  color: AppColors.danger,
                  tooltip: 'Remove medicine',
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Medicine Name
          CustomTextField(
            label: 'Medicine Name',
            hint: 'e.g., Aspirin, Paracetamol',
            controller: entry.nameController,
            prefixIcon: Icons.medical_services,
            required: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Medicine name is required';
              }
              if (value.length < 2) {
                return 'Medicine name must be at least 2 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Medicine Type
          CustomDropdownField<String>(
            label: 'Medicine Type',
            value: entry.selectedType,
            items: MedicineTypes.types,
            itemLabel: (type) => type,
            onChanged: (type) {
              setState(() => entry.selectedType = type);
            },
            required: true,
          ),
          const SizedBox(height: AppSpacing.md),

          // Duration and Dosage in a Row
          Row(
            children: [
              Expanded(
                child: CustomDropdownField<int>(
                  label: 'Duration (Days)',
                  value: entry.selectedDuration,
                  items: DurationOptions.days,
                  itemLabel: (days) => '$days days',
                  onChanged: (days) {
                    setState(() {
                      entry.selectedDuration = days;
                      if (days != null) {
                        final finishDate = DateHelper.calculateFinishDate(
                          _selectedPurchaseDate,
                          days,
                        );
                        entry.finishDateController.text =
                            DateHelper.formatDate(finishDate);
                      }
                    });
                  },
                  required: true,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: CustomDropdownField<String>(
                  label: 'Dosage',
                  value: entry.selectedDosage,
                  items: DosageFrequency.frequency,
                  itemLabel: (freq) => freq,
                  onChanged: (freq) {
                    setState(() => entry.selectedDosage = freq);
                  },
                  required: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Finish Date (Read-only)
          CustomTextField(
            label: 'Expected Finish Date',
            controller: entry.finishDateController,
            readOnly: true,
            prefixIcon: Icons.event_available,
          ),
          const SizedBox(height: AppSpacing.md),

          // Quantity and Price in a Row
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Quantity',
                  hint: 'e.g., 30 tablets',
                  controller: entry.quantityController,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: CustomTextField(
                  label: 'Price (₹)',
                  hint: 'Enter price',
                  controller: entry.priceController,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Notes
          CustomTextField(
            label: 'Notes (Optional)',
            hint: 'Add any special instructions',
            controller: entry.notesController,
            maxLines: 2,
          ),
        ],
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
        // Update all finish dates
        for (var entry in _medicineEntries) {
          if (entry.selectedDuration != null) {
            final finishDate = DateHelper.calculateFinishDate(
              _selectedPurchaseDate,
              entry.selectedDuration!,
            );
            entry.finishDateController.text = DateHelper.formatDate(finishDate);
          }
        }
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

    // Validate all medicine entries
    for (int i = 0; i < _medicineEntries.length; i++) {
      final entry = _medicineEntries[i];
      if (entry.selectedType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select type for Medicine ${i + 1}')),
        );
        return;
      }
      if (entry.selectedDuration == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Please select duration for Medicine ${i + 1}')),
        );
        return;
      }
      if (entry.selectedDosage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Please select dosage for Medicine ${i + 1}')),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final dbHelper = DatabaseHelper();
      int successCount = 0;

      // Add each medicine as a separate purchase
      for (var entry in _medicineEntries) {
        final quantity = entry.quantityController.text.isEmpty
            ? null
            : double.tryParse(entry.quantityController.text);
        final price = entry.priceController.text.isEmpty
            ? null
            : double.tryParse(entry.priceController.text);

        final purchase = Purchase(
          customerId: _selectedCustomer!.id!,
          medicineId: 0, // Temporary ID
          customerName: _selectedCustomer!.name,
          medicineName: entry.nameController.text,
          medicineType: entry.selectedType!,
          purchaseDate: _selectedPurchaseDate,
          durationDays: entry.selectedDuration!,
          dosageFrequency: entry.selectedDosage!,
          finishDate: DateHelper.calculateFinishDate(
            _selectedPurchaseDate,
            entry.selectedDuration!,
          ),
          quantity: quantity,
          price: price,
          notes: entry.notesController.text.isEmpty
              ? null
              : entry.notesController.text,
          createdAt: DateTime.now(),
        );

        await dbHelper.addPurchase(purchase);
        successCount++;
      }

      // Refresh purchase data
      if (mounted) {
        await context.read<PurchaseProvider>().refreshPurchases();

        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$successCount medicine(s) added successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isLoading = false);

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

// Helper class to manage medicine entry data
class MedicineEntry {
  final TextEditingController nameController;
  final TextEditingController quantityController;
  final TextEditingController priceController;
  final TextEditingController notesController;
  final TextEditingController finishDateController;

  String? selectedType;
  int? selectedDuration;
  String? selectedDosage;

  MedicineEntry()
      : nameController = TextEditingController(),
        quantityController = TextEditingController(),
        priceController = TextEditingController(),
        notesController = TextEditingController(),
        finishDateController = TextEditingController();

  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    priceController.dispose();
    notesController.dispose();
    finishDateController.dispose();
  }
}
