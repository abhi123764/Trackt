import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/member.dart';
import '../../../models/membership_plan.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/member_provider.dart';
import '../../../providers/payment_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/formatters.dart';

class AddPaymentSheet extends StatefulWidget {
  const AddPaymentSheet({super.key});

  @override
  State<AddPaymentSheet> createState() => _AddPaymentSheetState();
}

class _AddPaymentSheetState extends State<AddPaymentSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  Member? _selectedMember;
  MembershipPlan? _selectedPlan;
  late final TextEditingController _amountController;
  late final TextEditingController _dateController;
  late final TextEditingController _transactionIdController;
  late final TextEditingController _notesController;

  String _paymentMethod = 'UPI';
  String _status = 'Paid';

  static const _methods = ['UPI', 'Cash', 'Card', 'Net Banking'];
  static const _statuses = ['Paid', 'Pending'];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _dateController = TextEditingController(
      text: DateTime.now().toIso8601String().split('T').first,
    );
    _transactionIdController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    _transactionIdController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.tealPrimary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = picked.toIso8601String().split('T').first;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMember == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a member'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount greater than 0'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await context.read<PaymentProvider>().addPayment(
          memberId: _selectedMember!.id,
          planId: _selectedPlan?.id,
          amount: amount,
          paymentDate: _dateController.text.trim(),
          paymentMethod: _paymentMethod,
          status: _status,
          transactionId: _transactionIdController.text.trim().isNotEmpty
              ? _transactionIdController.text.trim()
              : null,
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      context.read<DashboardProvider>().loadDashboard();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment of ₹${AppFormatters.formatAmount(amount)} recorded successfully!'),
          backgroundColor: AppColors.tealPrimary,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to record payment. Please try again.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final members = context.watch<MemberProvider>().members;
    final plans = context.watch<MemberProvider>().membershipPlans;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAECF0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add Payment Details',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF054446),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF667085)),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Record a fee collection or pending invoice.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.5,
                    color: Color(0xFF667085),
                  ),
                ),
                const SizedBox(height: 18),

                // Member Dropdown
                _buildLabel('Select Member *'),
                DropdownButtonFormField<Member>(
                  initialValue: _selectedMember,
                  hint: const Text('Choose member', style: TextStyle(fontFamily: 'Poppins', fontSize: 13.5)),
                  isExpanded: true,
                  decoration: _inputDecoration(Icons.person_outline),
                  items: members.map((m) {
                    return DropdownMenuItem<Member>(
                      value: m,
                      child: Text(
                        '${m.name} (${m.mobileNumber})',
                        style: const TextStyle(fontFamily: 'Poppins', fontSize: 13.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedMember = val;
                      if (val?.planId != null) {
                        try {
                          _selectedPlan = plans.firstWhere((p) => p.id == val!.planId);
                          _amountController.text = _selectedPlan!.price.toStringAsFixed(0);
                        } catch (_) {}
                      }
                    });
                  },
                  validator: (v) => v == null ? 'Please select a member' : null,
                ),
                const SizedBox(height: 14),

                // Plan (Optional)
                _buildLabel('Membership Plan'),
                DropdownButtonFormField<MembershipPlan>(
                  initialValue: _selectedPlan,
                  hint: const Text('Select plan (optional)', style: TextStyle(fontFamily: 'Poppins', fontSize: 13.5)),
                  isExpanded: true,
                  decoration: _inputDecoration(Icons.card_membership_outlined),
                  items: plans.map((p) {
                    return DropdownMenuItem<MembershipPlan>(
                      value: p,
                      child: Text(
                        '${p.name} - ₹${AppFormatters.formatAmount(p.price)}',
                        style: const TextStyle(fontFamily: 'Poppins', fontSize: 13.5),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedPlan = val;
                      if (val != null) {
                        _amountController.text = val.price.toStringAsFixed(0);
                      }
                    });
                  },
                ),
                const SizedBox(height: 14),

                // Amount & Date Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Amount (₹) *'),
                          TextFormField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                            decoration: _inputDecoration(Icons.currency_rupee),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Required';
                              if (double.tryParse(v.trim()) == null) return 'Invalid';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Payment Date *'),
                          InkWell(
                            onTap: _pickDate,
                            child: IgnorePointer(
                              child: TextFormField(
                                controller: _dateController,
                                style: const TextStyle(fontFamily: 'Poppins', fontSize: 13.5),
                                decoration: _inputDecoration(Icons.calendar_today_outlined),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Payment Method
                _buildLabel('Payment Method'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _methods.map((method) {
                    final selected = _paymentMethod == method;
                    return ChoiceChip(
                      label: Text(method),
                      selected: selected,
                      selectedColor: const Color(0xFF054446),
                      backgroundColor: const Color(0xFFF2F4F7),
                      labelStyle: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12.5,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected ? Colors.white : const Color(0xFF344054),
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _paymentMethod = method);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),

                // Status
                _buildLabel('Payment Status'),
                Row(
                  children: _statuses.map((status) {
                    final selected = _status == status;
                    final isPaid = status == 'Paid';
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ChoiceChip(
                        label: Text(status),
                        selected: selected,
                        selectedColor: isPaid ? const Color(0xFF12B76A) : const Color(0xFFD92D20),
                        backgroundColor: const Color(0xFFF2F4F7),
                        labelStyle: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: selected ? Colors.white : const Color(0xFF344054),
                        ),
                        onSelected: (val) {
                          if (val) setState(() => _status = status);
                        },
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),

                // Transaction ID (Optional)
                _buildLabel('Transaction / Reference ID (Optional)'),
                TextFormField(
                  controller: _transactionIdController,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 13.5),
                  decoration: _inputDecoration(Icons.receipt_long_outlined, hint: 'e.g. UPI-9238423984'),
                ),
                const SizedBox(height: 14),

                // Notes (Optional)
                _buildLabel('Notes (Optional)'),
                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 13.5),
                  decoration: _inputDecoration(Icons.edit_note_outlined, hint: 'Add payment remarks...'),
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF054446),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text(
                            'Save Payment',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: Color(0xFF344054),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(IconData icon, {String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 13,
        color: Color(0xFF98A2B3),
      ),
      prefixIcon: Icon(icon, color: const Color(0xFF667085), size: 20),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEAECF0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEAECF0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF054446), width: 1.5),
      ),
    );
  }
}
