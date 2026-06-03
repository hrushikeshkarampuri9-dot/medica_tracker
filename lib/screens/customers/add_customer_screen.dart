import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/customer_provider.dart';
import '../../models/customer_model.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddCustomerScreen extends StatefulWidget {
  final Customer? customer;

  const AddCustomerScreen({super.key, this.customer});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _ageController;
  String? _selectedGender;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer?.name ?? '');
    _phoneController =
        TextEditingController(text: widget.customer?.phoneNumber ?? '');
    _addressController =
        TextEditingController(text: widget.customer?.address ?? '');
    _ageController =
        TextEditingController(text: widget.customer?.age?.toString() ?? '');
    _selectedGender = widget.customer?.gender;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.customer != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? AppStrings.editCustomer : AppStrings.addCustomer),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                label: AppStrings.customerName,
                hint: 'Enter customer name',
                controller: _nameController,
                required: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.fieldRequired;
                  }
                  if (value.length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              PhoneNumberField(
                label: AppStrings.phoneNumber,
                controller: _phoneController,
              ),
              const SizedBox(height: AppSpacing.lg),
              CustomTextField(
                label: AppStrings.address,
                hint: 'Enter address',
                controller: _addressController,
                maxLines: 2,
              ),
              const SizedBox(height: AppSpacing.lg),
              CustomTextField(
                label: AppStrings.age,
                hint: 'Enter age',
                controller: _ageController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.lg),
              // Gender Dropdown - Simple version
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.gender,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      border: Border.all(color: AppColors.borderColor),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      underline: const SizedBox(),
                      value: _selectedGender,
                      hint: const Text('Select Gender'),
                      items: GenderOptions.genders
                          .map((gender) => DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              CustomButton(
                label: isEditing ? 'Update Customer' : AppStrings.addCustomer,
                onPressed: _isLoading ? () {} : _submitForm,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final age = _ageController.text.isEmpty ? null : int.parse(_ageController.text);

    final customer = Customer(
      id: widget.customer?.id,
      name: _nameController.text,
      phoneNumber: _phoneController.text,
      address: _addressController.text.isEmpty ? null : _addressController.text,
      age: age,
      gender: _selectedGender,
      createdAt: widget.customer?.createdAt ?? DateTime.now(),
    );

    final isEditing = widget.customer != null;
    final provider = context.read<CustomerProvider>();

    final success = isEditing
        ? await provider.updateCustomer(customer)
        : await provider.addCustomer(customer);

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing
                ? AppStrings.updatedSuccessfully
                : AppStrings.addedSuccessfully),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error ?? 'Error occurred')),
        );
      }
    }
  }
}
