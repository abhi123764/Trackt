import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/payment_provider.dart';
import '../../../theme/app_theme.dart';

class PaymentFilterSheet extends StatefulWidget {
  const PaymentFilterSheet({super.key});

  @override
  State<PaymentFilterSheet> createState() => _PaymentFilterSheetState();
}

class _PaymentFilterSheetState extends State<PaymentFilterSheet> {
  // Local copies of filter state so changes aren't applied until "Apply"
  String? _selectedPlan;
  String _selectedDate = 'All';
  DateTime? _customFrom;
  DateTime? _customTo;
  String? _selectedMethod;

  static const List<String> _plans = ['Elite', 'Premium', 'Normal'];
  static const List<String> _dateRanges = [
    'All',
    'Today',
    'This Week',
    'This Month',
    'Custom',
  ];
  static const List<String> _methods = [
    'UPI',
    'Cash',
    'Card',
    'Net Banking',
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill from current provider state
    final provider = context.read<PaymentProvider>();
    _selectedPlan = provider.planFilter;
    _selectedDate = provider.dateFilter;
    _customFrom = provider.customFromDate;
    _customTo = provider.customToDate;
    _selectedMethod = provider.methodFilter;
  }

  bool get _anyActive =>
      _selectedPlan != null ||
      _selectedDate != 'All' ||
      _selectedMethod != null;

  Future<void> _pickCustomFrom() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _customFrom ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme:
              const ColorScheme.light(primary: AppColors.tealPrimary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _customFrom = picked);
  }

  Future<void> _pickCustomTo() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _customTo ?? DateTime.now(),
      firstDate: _customFrom ?? DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme:
              const ColorScheme.light(primary: AppColors.tealPrimary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _customTo = picked);
  }

  void _apply() {
    final provider = context.read<PaymentProvider>();
    provider.setPlanFilter(_selectedPlan);
    provider.setDateFilter(
      _selectedDate,
      from: _customFrom,
      to: _customTo,
    );
    provider.setMethodFilter(_selectedMethod);
    Navigator.of(context).pop();
  }

  void _reset() {
    setState(() {
      _selectedPlan = null;
      _selectedDate = 'All';
      _customFrom = null;
      _customTo = null;
      _selectedMethod = null;
    });
  }

  String _fmt(DateTime? d) {
    if (d == null) return 'Pick date';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Handle ──────────────────────────────────────────────────
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

            // ── Title row ───────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter Payments',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF054446),
                  ),
                ),
                if (_anyActive)
                  TextButton(
                    onPressed: _reset,
                    child: const Text(
                      'Reset All',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD92D20),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 22),

            // ── BY MEMBERSHIP PLAN ───────────────────────────────────────
            _sectionLabel('BY MEMBERSHIP PLAN'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip('All Plans', _selectedPlan == null, () {
                  setState(() => _selectedPlan = null);
                }),
                ..._plans.map((plan) => _planChip(plan)),
              ],
            ),
            const SizedBox(height: 22),

            // ── BY DATE RANGE ────────────────────────────────────────────
            _sectionLabel('BY DATE RANGE'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _dateRanges
                  .map(
                    (range) => _chip(range, _selectedDate == range, () {
                      setState(() {
                        _selectedDate = range;
                        if (range != 'Custom') {
                          _customFrom = null;
                          _customTo = null;
                        }
                      });
                    }),
                  )
                  .toList(),
            ),

            // Custom date range pickers (only shown when Custom is selected)
            if (_selectedDate == 'Custom') ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _datePicker(
                      label: 'From',
                      value: _fmt(_customFrom),
                      onTap: _pickCustomFrom,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _datePicker(
                      label: 'To',
                      value: _fmt(_customTo),
                      onTap: _pickCustomTo,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 22),

            // ── BY PAYMENT METHOD ────────────────────────────────────────
            _sectionLabel('BY PAYMENT METHOD'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip('All Methods', _selectedMethod == null, () {
                  setState(() => _selectedMethod = null);
                }),
                ..._methods.map((m) => _chip(m, _selectedMethod == m, () {
                      setState(() => _selectedMethod = m);
                    })),
              ],
            ),
            const SizedBox(height: 28),

            // ── APPLY BUTTON ─────────────────────────────────────────────
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
                onPressed: _apply,
                child: Text(
                  _anyActive ? 'Apply Filters' : 'Close',
                  style: const TextStyle(
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
    );
  }

  // ── HELPERS ──────────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: Color(0xFF667085),
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF054446) : const Color(0xFFF2F4F7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? const Color(0xFF054446)
                : const Color(0xFFEAECF0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : const Color(0xFF344054),
          ),
        ),
      ),
    );
  }

  Widget _planChip(String plan) {
    final selected = _selectedPlan == plan;
    Color accentBg;
    Color accentFg;

    switch (plan) {
      case 'Elite':
        accentBg = selected ? const Color(0xFF00B8D9) : const Color(0xFFE0F7FA);
        accentFg = selected ? Colors.white : const Color(0xFF006B7D);
        break;
      case 'Premium':
        accentBg = selected ? const Color(0xFF7B5EA7) : const Color(0xFFF3EEFF);
        accentFg = selected ? Colors.white : const Color(0xFF4A2D7B);
        break;
      default: // Normal
        accentBg = selected ? const Color(0xFF344054) : const Color(0xFFF2F4F7);
        accentFg = selected ? Colors.white : const Color(0xFF344054);
    }

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = selected ? null : plan),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: accentBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accentBg),
        ),
        child: Text(
          plan,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: accentFg,
          ),
        ),
      ),
    );
  }

  Widget _datePicker({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEAECF0)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: Color(0xFF667085),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF98A2B3),
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF344054),
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
