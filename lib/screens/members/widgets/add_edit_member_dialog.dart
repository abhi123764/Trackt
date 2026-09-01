import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/member.dart';
import '../../../providers/member_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/validators.dart';

class AddEditMemberDialog extends StatefulWidget {
  final Member? member;

  const AddEditMemberDialog({super.key, this.member});

  @override
  State<AddEditMemberDialog> createState() => _AddEditMemberDialogState();
}

class _AddEditMemberDialogState extends State<AddEditMemberDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;

  late String _gender;
  late String _status;
  int? _selectedPlanId;
  bool _isSubmitting = false;

  bool get _isEditing => widget.member != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.member?.name ?? '');
    _phoneController = TextEditingController(
      text: widget.member?.mobileNumber ?? '',
    );
    _emailController = TextEditingController(text: widget.member?.email ?? '');
    _addressController = TextEditingController(
      text: widget.member?.address ?? '',
    );
    _gender = widget.member?.gender ?? 'Male';
    _status = widget.member?.status ?? 'Active';
    _selectedPlanId = widget.member?.planId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final memberProvider = context.read<MemberProvider>();
    bool success;

    if (_isEditing) {
      final updatedMember = Member(
        id: widget.member!.id,
        name: _nameController.text.trim(),
        mobileNumber: _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        gender: _gender,
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        planId: _selectedPlanId,
        status: _status,
        joinDate: widget.member!.joinDate,
      );
      success = await memberProvider.updateMember(updatedMember);
    } else {
      success = await memberProvider.addMember(
        name: _nameController.text.trim(),
        mobileNumber: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        gender: _gender,
        address: _addressController.text.trim(),
        planId: _selectedPlanId,
        status: _status,
      );
    }

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Member updated successfully'
                : 'Member added successfully',
          ),
          backgroundColor: AppColors.accentGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            memberProvider.errorMessage ?? 'Failed to save member',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final membershipPlans = context.watch<MemberProvider>().membershipPlans;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isEditing ? 'Edit Member' : 'Add New Member',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.tealDark,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name *',
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    validator: (val) =>
                        AppValidators.validateRequired(val, 'Name'),
                  ),
                  const SizedBox(height: 14),

                  // Phone Field
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number *',
                      prefixIcon: Icon(
                        Icons.phone_outlined,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    validator: AppValidators.validatePhone,
                  ),
                  const SizedBox(height: 14),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icon(
                        Icons.mail_outline,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    validator: (val) {
                      if (val != null && val.trim().isNotEmpty) {
                        return AppValidators.validateEmail(val);
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Membership Plan Dropdown
                  DropdownButtonFormField<int?>(
                    initialValue: _selectedPlanId,
                    decoration: const InputDecoration(
                      labelText: 'Membership Plan',
                      prefixIcon: Icon(
                        Icons.card_membership_outlined,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('No Plan Assigned'),
                      ),
                      ...membershipPlans.map((plan) {
                        return DropdownMenuItem<int?>(
                          value: plan.id,
                          child: Text(
                            '${plan.name} Plan (₹${plan.price.toStringAsFixed(0)})',
                          ),
                        );
                      }),
                    ],
                    onChanged: (val) {
                      setState(() => _selectedPlanId = val);
                    },
                  ),
                  const SizedBox(height: 14),

                  // Gender & Status Row
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _gender,
                          decoration: const InputDecoration(
                            labelText: 'Gender',
                            prefixIcon: Icon(
                              Icons.wc_outlined,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Male',
                              child: Text('Male'),
                            ),
                            DropdownMenuItem(
                              value: 'Female',
                              child: Text('Female'),
                            ),
                            DropdownMenuItem(
                              value: 'Other',
                              child: Text('Other'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _gender = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _status,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            prefixIcon: Icon(
                              Icons.shield_outlined,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Active',
                              child: Text('Active'),
                            ),
                            DropdownMenuItem(
                              value: 'Inactive',
                              child: Text('Inactive'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _status = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Address Field
                  TextFormField(
                    controller: _addressController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      prefixIcon: Icon(
                        Icons.location_on_outlined,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _handleSubmit,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(_isEditing ? 'Save Changes' : 'Add Member'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
